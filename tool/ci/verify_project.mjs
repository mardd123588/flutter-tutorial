import { spawn, spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

import { readChromeVersion } from './chrome_version.mjs';
import { findProject, loadProjectCatalog, repositoryRoot } from './project_catalog.mjs';
import { buildProject } from '../release/build_project.mjs';

const args = process.argv.slice(2);
const slug = valueAfter(args, '--project');
if (!slug) throw new Error('Use --project <slug>.');
const projects = await loadProjectCatalog();
const project = findProject(projects, slug);
const projectDirectory = resolve(repositoryRoot, project.path);
const logDirectory = resolve(repositoryRoot, 'build', 'ci-logs', project.slug);
const chromedriver = resolveChromeDriver();
await mkdir(logDirectory, { recursive: true });

await writeMetadata();

await runFlutter(['analyze'], 'analyze.log');
await runFlutter(['test'], 'test.log');
if (args.includes('--integration')) await runIntegration();
if (args.includes('--build')) {
  await buildProject({
    slug: project.slug,
    appEnvironment: 'demo',
    contentVersion: process.env.GITHUB_SHA ?? 'working-tree',
  });
}

async function runFlutter(commandArgs, logName) {
  const executable = platformCommand('flutter', commandArgs);
  const result = spawnSync(executable.command, executable.args, {
    cwd: projectDirectory,
    encoding: 'utf8',
    maxBuffer: 32 * 1024 * 1024,
  });
  const output = `$ flutter ${commandArgs.join(' ')}\n\n${result.stdout ?? ''}${result.stderr ?? ''}${result.error ? `${result.error}\n` : ''}\nExit code: ${result.status ?? 'unknown'}\n`;
  process.stdout.write(output);
  await writeFile(resolve(logDirectory, logName), output, 'utf8');
  if (result.status !== 0) throw new Error(`${project.slug}: flutter ${commandArgs.join(' ')} failed.`);
}

async function runIntegration() {
  const driverPort = Number(process.env.CHROMEDRIVER_PORT ?? 4444);
  const webPort = Number(process.env.FLUTTER_WEB_PORT ?? 7357);
  const driver = spawn(chromedriver, [`--port=${driverPort}`], {
    cwd: projectDirectory,
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  let driverOutput = '';
  driver.stdout.on('data', (chunk) => (driverOutput += chunk.toString()));
  driver.stderr.on('data', (chunk) => (driverOutput += chunk.toString()));
  try {
    await waitForDriver(driverPort);
    const flutterArgs = [
      'drive',
      '--driver=test_driver/integration_test.dart',
      `--target=${project.integrationTest}`,
      '-d',
      'web-server',
      '--browser-name=chrome',
      '--headless',
      '--browser-dimension=1440x900',
      `--driver-port=${driverPort}`,
      `--web-port=${webPort}`,
    ];
    await runFlutter(flutterArgs, 'integration.log');
  } finally {
    driver.kill();
    await writeFile(resolve(logDirectory, 'chromedriver.log'), driverOutput, 'utf8');
  }
}

async function writeMetadata() {
  const commands = [
    ['flutter', ['--version']],
    ['dart', ['--version']],
    [chromedriver, ['--version']],
  ];
  const lines = [
    `project=${project.slug}`,
    `commit=${process.env.GITHUB_SHA ?? 'working-tree'}`,
    `chromedriver_port=${process.env.CHROMEDRIVER_PORT ?? '4444'}`,
    `flutter_web_port=${process.env.FLUTTER_WEB_PORT ?? '7357'}`,
    `chrome: ${readChromeVersion()}`,
  ];
  for (const [command, commandArgs] of commands) {
    const executable = existsSync(command)
      ? { command, args: commandArgs }
      : platformCommand(command, commandArgs);
    const result = spawnSync(executable.command, executable.args, {
      cwd: projectDirectory,
      encoding: 'utf8',
    });
    lines.push(`${command}: ${(result.stdout || result.stderr || 'unavailable').trim()}`);
  }
  await writeFile(resolve(logDirectory, 'environment.log'), `${lines.join('\n')}\n`, 'utf8');
}

function platformCommand(command, args) {
  return process.platform === 'win32'
    ? { command: 'cmd.exe', args: ['/d', '/s', '/c', command, ...args] }
    : { command, args };
}

function resolveChromeDriver() {
  if (process.env.CHROMEDRIVER_BINARY) return process.env.CHROMEDRIVER_BINARY;
  const executable = process.platform === 'win32' ? 'chromedriver.exe' : 'chromedriver';
  const platform = process.platform === 'win32' ? 'win64' : 'linux64';
  const installed = resolve(
    repositoryRoot,
    'build',
    'chromedriver',
    `chromedriver-${platform}`,
    executable,
  );
  return existsSync(installed) ? installed : executable;
}

async function waitForDriver(port) {
  for (let attempt = 0; attempt < 40; attempt += 1) {
    try {
      const response = await fetch(`http://127.0.0.1:${port}/status`);
      if (response.ok) return;
    } catch {
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 250));
    }
  }
  throw new Error(`ChromeDriver did not start on port ${port}.`);
}

function valueAfter(values, name) {
  const index = values.indexOf(name);
  return index === -1 ? undefined : values[index + 1];
}
