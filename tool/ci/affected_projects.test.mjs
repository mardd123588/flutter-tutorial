import assert from 'node:assert/strict';
import test from 'node:test';

import { parseNameStatus, selectAffectedProjects } from './affected_projects.mjs';

const projects = [
  {
    slug: 'alpha',
    path: 'examples/capstones/alpha',
    integrationTest: 'integration_test/alpha_test.dart',
  },
  {
    slug: 'beta',
    path: 'examples/focus/beta',
    integrationTest: 'integration_test/beta_test.dart',
  },
];

test('project-private files select only their project', () => {
  const result = selectAffectedProjects(
    ['examples/capstones/alpha/lib/main.dart'],
    projects,
  );
  assert.deepEqual(result.projects.map((project) => project.slug), ['alpha']);
  assert.equal(result.full, false);
});

test('rename paths select both source and destination projects', () => {
  const result = selectAffectedProjects(
    [
      'examples/capstones/alpha/lib/old.dart',
      'examples/focus/beta/lib/new.dart',
    ],
    projects,
  );
  assert.deepEqual(result.projects.map((project) => project.slug), [
    'alpha',
    'beta',
  ]);
});

test('git name-status parsing keeps both sides of renames', () => {
  assert.deepEqual(
    parseNameStatus(
      'M\0site/guide/index.md\0R100\0examples/capstones/alpha/lib/old.dart\0examples/focus/beta/lib/new.dart\0',
    ),
    [
      'site/guide/index.md',
      'examples/capstones/alpha/lib/old.dart',
      'examples/focus/beta/lib/new.dart',
    ],
  );
});

test('workspace and workflow inputs select every project', () => {
  for (const path of [
    'pubspec.lock',
    'analysis_options.yaml',
    '.github/workflows/verify.yml',
    'tool/release/assemble_pages.mjs',
  ]) {
    const result = selectAffectedProjects([path], projects);
    assert.equal(result.full, true, path);
    assert.equal(result.projects.length, 2, path);
  }
});

test('release and workflow changes also select the site', () => {
  for (const path of [
    'tool/release/assemble_pages.mjs',
    '.github/workflows/pages.yml',
  ]) {
    const result = selectAffectedProjects([path], projects);
    assert.equal(result.site, true, path);
    assert.equal(result.projects.length, 2, path);
  }
});

test('site-only changes do not schedule Flutter projects', () => {
  const result = selectAffectedProjects(['site/guide/part-08/08-01.md'], projects);
  assert.equal(result.site, true);
  assert.deepEqual(result.projects, []);
});

test('an unknown new example forces full verification', () => {
  const result = selectAffectedProjects(
    ['examples/capstones/new_project/pubspec.yaml'],
    projects,
  );
  assert.equal(result.full, true);
  assert.equal(result.projects.length, 2);
});
