import { cp, mkdir, readFile, rm, stat, writeFile } from 'node:fs/promises';
import { relative, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

import { loadProjectCatalog, repositoryRoot } from '../ci/project_catalog.mjs';
import { validateProjectBuild } from './build_project.mjs';

const defaultStagingDirectory = resolve(repositoryRoot, 'build', 'pages-staging');

export async function assemblePages({ stagingDirectory = defaultStagingDirectory } = {}) {
  assertSafeStagingDirectory(stagingDirectory);
  const siteDirectory = resolve(repositoryRoot, 'site', '.vitepress', 'dist');
  await requireFile(resolve(siteDirectory, 'index.html'));
  await rm(stagingDirectory, { recursive: true, force: true });
  await mkdir(stagingDirectory, { recursive: true });
  await cp(siteDirectory, stagingDirectory, { recursive: true, errorOnExist: true });

  const projects = await loadProjectCatalog();
  const previewRoot = resolve(stagingDirectory, 'previews');
  await mkdir(previewRoot, { recursive: true });
  for (const project of projects) {
    await validateProjectBuild(project);
    const source = resolve(repositoryRoot, project.path, 'build', 'web');
    const destination = resolve(previewRoot, project.slug);
    await cp(source, destination, { recursive: true, errorOnExist: true });
    await requireFile(resolve(destination, 'index.html'));
  }

  const contentVersion = process.env.GITHUB_SHA ?? 'working-tree';
  await writeFile(
    resolve(stagingDirectory, 'release-manifest.json'),
    `${JSON.stringify(
      {
        contentVersion,
        previews: projects.map((project) => ({
          slug: project.slug,
          path: `/flutter-tutorial/previews/${project.slug}/`,
        })),
      },
      null,
      2,
    )}\n`,
    'utf8',
  );
  return stagingDirectory;
}

function assertSafeStagingDirectory(stagingDirectory) {
  const relativePath = relative(repositoryRoot, stagingDirectory).replaceAll('\\', '/');
  if (relativePath !== 'build/pages-staging') {
    throw new Error(`Refusing to replace unexpected staging directory: ${stagingDirectory}`);
  }
}

async function requireFile(path) {
  const metadata = await stat(path);
  if (!metadata.isFile()) throw new Error(`Expected file: ${path}`);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const output = await assemblePages();
  const manifest = JSON.parse(
    await readFile(resolve(output, 'release-manifest.json'), 'utf8'),
  );
  process.stdout.write(`Assembled ${manifest.previews.length} previews in ${output}\n`);
}
