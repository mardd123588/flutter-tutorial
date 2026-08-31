import { execFileSync } from 'node:child_process';

import { loadProjectCatalog } from '../ci/project_catalog.mjs';
import { buildProject } from './build_project.mjs';

const projects = await loadProjectCatalog();
const contentVersion = process.env.GITHUB_SHA ?? execFileSync('git', ['rev-parse', 'HEAD'], { encoding: 'utf8' }).trim();
for (const project of projects) {
  process.stdout.write(`\nBuilding ${project.slug}\n`);
  await buildProject({
    slug: project.slug,
    appEnvironment: 'demo',
    contentVersion,
  });
}
