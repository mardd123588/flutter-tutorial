import { execFileSync } from 'node:child_process';
import { appendFile, chmod, mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

import { repositoryRoot } from './project_catalog.mjs';

const chrome = process.env.CHROME_BINARY ?? 'google-chrome';
const versionOutput = execFileSync(chrome, ['--version'], { encoding: 'utf8' });
const version = versionOutput.match(/\d+\.\d+\.\d+\.\d+/)?.[0];
if (!version) throw new Error(`Cannot parse Chrome version from: ${versionOutput}`);
const build = version.split('.').slice(0, 3).join('.');
const metadataResponse = await fetch(
  'https://googlechromelabs.github.io/chrome-for-testing/latest-patch-versions-per-build-with-downloads.json',
);
if (!metadataResponse.ok) throw new Error('Cannot load Chrome for Testing metadata.');
const metadata = await metadataResponse.json();
const downloads = metadata.builds?.[build]?.downloads?.chromedriver;
const platform = process.platform === 'win32' ? 'win64' : 'linux64';
const download = downloads?.find((candidate) => candidate.platform === platform);
if (!download) throw new Error(`No ChromeDriver found for Chrome build ${build} on ${platform}.`);

const outputDirectory = resolve(repositoryRoot, 'build', 'chromedriver');
const archive = resolve(outputDirectory, 'chromedriver.zip');
await mkdir(outputDirectory, { recursive: true });
const archiveResponse = await fetch(download.url);
if (!archiveResponse.ok) throw new Error(`Cannot download ${download.url}.`);
await writeFile(archive, Buffer.from(await archiveResponse.arrayBuffer()));
execFileSync('unzip', ['-o', archive, '-d', outputDirectory], { stdio: 'inherit' });
const binaryDirectory = resolve(outputDirectory, `chromedriver-${platform}`);
if (process.platform !== 'win32') {
  await chmod(resolve(binaryDirectory, 'chromedriver'), 0o755);
}
if (process.env.GITHUB_PATH) {
  await appendFile(process.env.GITHUB_PATH, `${binaryDirectory}\n`, 'utf8');
}
process.stdout.write(`Chrome ${version}\nChromeDriver ${metadata.builds[build].version}\n${binaryDirectory}\n`);
