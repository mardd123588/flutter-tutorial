import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import { createServer } from 'node:http';
import { extname, resolve, sep } from 'node:path';

import { loadProjectCatalog, repositoryRoot } from '../ci/project_catalog.mjs';

const stagingDirectory = resolve(repositoryRoot, 'build', 'pages-staging');
const mimeTypes = new Map([
  ['.html', 'text/html; charset=utf-8'],
  ['.js', 'text/javascript; charset=utf-8'],
  ['.json', 'application/json; charset=utf-8'],
  ['.wasm', 'application/wasm'],
  ['.css', 'text/css; charset=utf-8'],
  ['.png', 'image/png'],
  ['.svg', 'image/svg+xml'],
]);

const server = createServer(async (request, response) => {
  try {
    const url = new URL(request.url ?? '/', 'http://127.0.0.1');
    const requestedPath = decodeURIComponent(url.pathname)
      .replace(/^\/flutter-tutorial\/?/, '')
      .replace(/^\/+/, '');
    let filePath = resolve(stagingDirectory, requestedPath);
    if (!filePath.startsWith(`${stagingDirectory}${sep}`) && filePath !== stagingDirectory) {
      response.writeHead(400).end('Bad path');
      return;
    }
    const metadata = await stat(filePath);
    if (metadata.isDirectory()) filePath = resolve(filePath, 'index.html');
    const type = mimeTypes.get(extname(filePath)) ?? 'application/octet-stream';
    response.writeHead(200, { 'content-type': type, 'cache-control': 'no-store' });
    createReadStream(filePath).pipe(response);
  } catch {
    response.writeHead(404).end('Not found');
  }
});

await new Promise((resolvePromise) => server.listen(0, '127.0.0.1', resolvePromise));
const address = server.address();
if (!address || typeof address === 'string') throw new Error('Static server did not start.');
const root = `http://127.0.0.1:${address.port}/flutter-tutorial`;

try {
  const projects = await loadProjectCatalog();
  await expectResponse(`${root}/`, 'text/html');
  await expectResponse(`${root}/projects/`, 'text/html');
  await expectResponse(`${root}/release-manifest.json`, 'application/json');
  for (const project of projects) {
    const preview = `${root}/previews/${project.slug}/`;
    await expectResponse(preview, 'text/html');
    await expectResponse(`${preview}#/listings/r-001`, 'text/html');
    for (const asset of project.webAssets ?? []) {
      await expectResponse(`${preview}${asset}`, mimeTypes.get(extname(asset)));
    }
  }
  process.stdout.write(`Staging smoke passed for ${projects.length} previews.\n`);
} finally {
  await new Promise((resolvePromise, reject) =>
    server.close((error) => (error ? reject(error) : resolvePromise())),
  );
}

async function expectResponse(url, expectedType) {
  const response = await fetch(url, { redirect: 'error' });
  if (!response.ok) throw new Error(`${url} returned ${response.status}.`);
  const actualType = response.headers.get('content-type') ?? '';
  if (expectedType && !actualType.startsWith(expectedType)) {
    throw new Error(`${url} returned ${actualType}; expected ${expectedType}.`);
  }
  await response.arrayBuffer();
}
