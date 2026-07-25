import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";

import type { Cache } from '../../../../../src/constants';

function collectPngs(dir: string, base: string): string[] {
  const results: string[] = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      results.push(...collectPngs(full, base));
    } else if (entry.endsWith('.png')) {
      results.push(relative(base, full).replace(/\\/g, '/'));
    }
  }
  return results;
}

export async function GET(req: Request) {
  const cachePath = join(process.cwd(), '..', 'cache.json');
  const configPath = join(process.cwd(), '..', 'config.json');

  const cache: Cache = JSON.parse(readFileSync(cachePath, "utf-8"));
  const config = JSON.parse(readFileSync(configPath, "utf-8"));

  const faithfulDir: string = config.directories.faithful;

  // cache.paths = x16 files (extracted from jars)
  const x16Set = new Set(cache.paths.map((p) => p.replace(/^assets\//, '').toLowerCase()));

  // collect all x32 files from faithful dir
  const x32Files = collectPngs(faithfulDir, faithfulDir);

  // x32 files that have no matching x16
  const extraFiles = x32Files
    .filter((rel) => !x16Set.has(rel.toLowerCase()))
    .map((rel) => `assets/${rel}`);

  return new Response(
    JSON.stringify({ paths: extraFiles }),
    { status: 200, headers: { 'Content-Type': 'application/json' } }
  );
}
