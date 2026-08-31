import { spawnSync } from 'node:child_process';
import { readFile, stat } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

import { findProject, loadProjectCatalog, repositoryRoot } from '../ci/project_catalog.mjs';

export async function buildProject({ slug, appEnvironment = 'demo', contentVersion = 'working-tree' }) {
  const projects = await loadProjectCatalog();
  const project = findProject(projects, slug);
  const projectDirectory = resolve(repositoryRoot, project.path);
  const baseHref = `/flutter-tutorial/previews/${project.slug}/`;
  const args = [
    'build',
    'web',
    '--release',
    '--pwa-strategy=none',
    '--no-web-resources-cdn',
    `--base-href=${baseHref}`,
    `--dart-define=APP_ENV=${appEnvironment}`,
    `--dart-define=CONTENT_VERSION=${contentVersion}`,
  ];
  const command = process.platform === 'win32' ? 'cmd.exe' : 'flutter';
  const spawnArgs = process.platform === 'win32'
    ? ['/d', '/s', '/c', 'flutter', ...args]
    : args;
  const result = spawnSync(command, spawnArgs, {
    cwd: projectDirectory,
    encoding: 'utf8',
    stdio: 'inherit',
  });
  if (result.status !== 0) {
    throw new Error(`Release build failed for ${project.slug}.`);
  }
  await validateProjectBuild(project);
  return { project, baseHref, output: resolve(projectDirectory, 'build', 'web') };
}

export async function validateProjectBuild(project) {
  const buildDirectory = resolve(repositoryRoot, project.path, 'build', 'web');
  await requireFile(resolve(buildDirectory, 'index.html'));
  await requireFile(resolve(buildDirectory, 'flutter_bootstrap.js'));
  const index = await readFile(resolve(buildDirectory, 'index.html'), 'utf8');
  const expectedBase = `/flutter-tutorial/previews/${project.slug}/`;
  if (!index.includes(`<base href="${expectedBase}">`)) {
    throw new Error(`${project.slug} was not built with ${expectedBase}.`);
  }
  const bootstrap = await readFile(resolve(buildDirectory, 'flutter_bootstrap.js'), 'utf8');
  if (!bootstrap.includes('"useLocalCanvasKit":true')) {
    throw new Error(`${project.slug} does not self-host CanvasKit.`);
  }
  const serviceWorker = resolve(buildDirectory, 'flutter_service_worker.js');
  const serviceWorkerSize = (await stat(serviceWorker)).size;
  if (serviceWorkerSize !== 0) {
    throw new Error(`${project.slug} generated an active Flutter service worker.`);
  }
  for (const asset of project.webAssets ?? []) {
    await requireFile(resolve(buildDirectory, asset));
  }
}

async function requireFile(path) {
  const metadata = await stat(path);
  if (!metadata.isFile()) throw new Error(`Expected file: ${path}`);
}

async function main() {
  const args = process.argv.slice(2);
  const slug = valueAfter(args, '--project');
  if (!slug) throw new Error('Use --project <slug>.');
  await buildProject({
    slug,
    appEnvironment: valueAfter(args, '--app-env') ?? 'demo',
    contentVersion: valueAfter(args, '--content-version') ?? 'working-tree',
  });
}

function valueAfter(args, name) {
  const index = args.indexOf(name);
  return index === -1 ? undefined : args[index + 1];
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  await main();
}
