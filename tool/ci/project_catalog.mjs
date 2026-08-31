import { readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const repositoryRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');

export async function loadProjectCatalog() {
  const catalogPath = resolve(repositoryRoot, 'tool', 'projects.json');
  const parsed = JSON.parse(await readFile(catalogPath, 'utf8'));
  if (parsed.schemaVersion !== 1 || !Array.isArray(parsed.projects)) {
    throw new Error('tool/projects.json must use schemaVersion 1 and contain projects.');
  }
  const slugs = new Set();
  const paths = new Set();
  for (const project of parsed.projects) {
    if (!project.slug || !project.path || !project.integrationTest) {
      throw new Error('Every project needs slug, path, and integrationTest.');
    }
    if (slugs.has(project.slug)) throw new Error(`Duplicate project slug: ${project.slug}`);
    if (paths.has(project.path)) throw new Error(`Duplicate project path: ${project.path}`);
    slugs.add(project.slug);
    paths.add(project.path);
  }
  if (parsed.projects.length !== 13) {
    throw new Error(`Expected 13 projects, found ${parsed.projects.length}.`);
  }
  return parsed.projects;
}

export function findProject(projects, slug) {
  const project = projects.find((candidate) => candidate.slug === slug);
  if (!project) throw new Error(`Unknown project slug: ${slug}`);
  return project;
}
