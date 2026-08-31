import { appendFile } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';

import { loadProjectCatalog } from './project_catalog.mjs';

const allProjectInputs = [
  'pubspec.yaml',
  'pubspec.lock',
  'analysis_options.yaml',
  'tool/projects.json',
];

const allProjectPrefixes = [
  '.github/workflows/',
  'tool/ci/',
  'tool/release/',
];

const sitePrefixes = ['site/', 'tool/site/'];
const siteInputs = ['package.json', 'pnpm-lock.yaml', '.npmrc'];

export function selectAffectedProjects(changedPaths, projects) {
  const normalized = changedPaths.map(normalizeGitPath).filter(Boolean);
  const full = normalized.some(
    (path) =>
      allProjectInputs.includes(path) ||
      allProjectPrefixes.some((prefix) => path.startsWith(prefix)) ||
      (path.startsWith('examples/') &&
        !projects.some((project) => isWithin(path, project.path))),
  );
  const affected = full
    ? projects
    : projects.filter((project) =>
        normalized.some((path) => isWithin(path, project.path)),
      );
  const site = normalized.some(
    (path) =>
      siteInputs.includes(path) ||
      sitePrefixes.some((prefix) => path.startsWith(prefix)) ||
      path.startsWith('docs/') ||
      path.startsWith('tool/release/') ||
      path.startsWith('.github/workflows/'),
  );
  return {
    full,
    site,
    projects: affected.map((project) => ({
      slug: project.slug,
      path: project.path,
      integrationTest: project.integrationTest,
    })),
  };
}

export function normalizeGitPath(path) {
  return path.replaceAll('\\', '/').replace(/^\.\//, '');
}

function isWithin(path, directory) {
  return path === directory || path.startsWith(`${directory}/`);
}

function readChangedPaths(base, head) {
  const output = execFileSync('git', ['diff', '--name-only', '-z', `${base}...${head}`], {
    encoding: 'buffer',
    maxBuffer: 16 * 1024 * 1024,
  });
  return output
    .toString('utf8')
    .split('\0')
    .filter(Boolean);
}

async function main() {
  const args = process.argv.slice(2);
  const projects = await loadProjectCatalog();
  const all = args.includes('--all');
  const base = valueAfter(args, '--base');
  const head = valueAfter(args, '--head');
  const githubOutput = valueAfter(args, '--github-output') ?? process.env.GITHUB_OUTPUT;
  const changedPaths = all
    ? ['pubspec.yaml']
    : base && head
    ? readChangedPaths(base, head)
    : [];
  const result = selectAffectedProjects(changedPaths, projects);
  const matrix = JSON.stringify({ include: result.projects });
  const output = {
    ...result,
    changedPaths,
    matrix: JSON.parse(matrix),
    hasProjects: result.projects.length > 0,
  };
  process.stdout.write(`${JSON.stringify(output, null, 2)}\n`);
  if (githubOutput) {
    await appendFile(
      githubOutput,
      `matrix=${matrix}\nhas_projects=${output.hasProjects}\nsite=${output.site}\n`,
      'utf8',
    );
  }
}

function valueAfter(args, name) {
  const index = args.indexOf(name);
  return index === -1 ? undefined : args[index + 1];
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  await main();
}
