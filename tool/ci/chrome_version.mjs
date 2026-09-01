import { execFileSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

export function resolveChrome() {
  if (process.env.CHROME_BINARY) return process.env.CHROME_BINARY;
  if (process.platform === 'win32') {
    const candidates = [
      process.env.PROGRAMFILES,
      process.env['PROGRAMFILES(X86)'],
      process.env.LOCALAPPDATA,
    ]
      .filter(Boolean)
      .map((root) => resolve(root, 'Google', 'Chrome', 'Application', 'chrome.exe'));
    const installed = candidates.find(existsSync);
    if (installed) return installed;
  }
  return 'google-chrome';
}

export function readChromeVersion(chrome = resolveChrome()) {
  if (process.platform === 'win32' && existsSync(chrome)) {
    const escaped = chrome.replaceAll("'", "''");
    const version = execFileSync(
      'powershell.exe',
      [
        '-NoProfile',
        '-Command',
        `(Get-Item -LiteralPath '${escaped}').VersionInfo.ProductVersion`,
      ],
      { encoding: 'utf8' },
    ).trim();
    return `Google Chrome ${version}`;
  }
  return execFileSync(chrome, ['--version'], { encoding: 'utf8' }).trim();
}
