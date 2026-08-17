#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT_ROOT="$(pwd)"
MANIFEST_PATH="docs/PROJECT-MANIFEST.md"

EXPECTED_ROOT="$PROJECT_ROOT" node <<'NODE'
const fs = require("fs");
const path = require("path");

const expectedRoot = process.env.EXPECTED_ROOT;
const manifestPath = "docs/PROJECT-MANIFEST.md";
const root = process.cwd();
const failures = [];

function pass(message) {
  console.log(`PASS: ${message}`);
}

function fail(message) {
  failures.push(message);
}

function isInsideRoot(candidate) {
  const relative = path.relative(root, candidate);
  return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}

function manifestFiles() {
  const text = fs.readFileSync(manifestPath, "utf8");
  return text
    .split(/\r?\n/)
    .map((line) => {
      const match = line.match(/^\| `([^`]+)` \|/);
      return match ? match[1] : null;
    })
    .filter(Boolean);
}

if (root === expectedRoot) {
  pass("scope check is running at the declared project root");
} else {
  fail(`scope check running at ${root}, expected ${expectedRoot}`);
}

if (fs.existsSync(manifestPath)) {
  pass(`${manifestPath} exists`);
} else {
  fail(`${manifestPath} is missing`);
}

if (fs.existsSync(manifestPath)) {
  for (const file of manifestFiles()) {
    if (file.startsWith("/") || file.startsWith("~") || file.startsWith("../") || file.startsWith("./../")) {
      fail(`${manifestPath} contains non-project-local entry: ${file}`);
      continue;
    }

    const absolute = path.resolve(root, file);
    if (!isInsideRoot(absolute)) {
      fail(`${file} resolves outside project root`);
      continue;
    }

    if (fs.existsSync(absolute)) {
      pass(`manifest entry is project-local and exists: ${file}`);
    } else {
      fail(`manifest entry is missing on disk: ${file}`);
    }
  }
}

const localBuild = "scripts/local-build.sh";
if (fs.existsSync(localBuild)) {
  const text = fs.readFileSync(localBuild, "utf8");
  const calls = [...text.matchAll(/bash (scripts\/[A-Za-z0-9_-]+\.sh)/g)].map((match) => match[1]);
  for (const script of calls) {
    const absolute = path.resolve(root, script);
    if (isInsideRoot(absolute) && fs.existsSync(absolute)) {
      pass(`local-build script call stays project-local: ${script}`);
    } else {
      fail(`local-build script call is missing or outside project root: ${script}`);
    }
  }
}

if (failures.length) {
  for (const failure of failures) {
    console.error(`FAIL: ${failure}`);
  }
  console.error(`\n${failures.length} project-scope validation failure(s)`);
  process.exit(1);
}

console.log("\nProject-scope validation passed.");
NODE
