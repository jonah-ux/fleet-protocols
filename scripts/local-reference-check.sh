#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

node <<'NODE'
const fs = require("fs");
const path = require("path");

const root = process.cwd();
const failures = [];

function walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const out = [];
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    const rel = path.relative(root, full);
    if (entry.isDirectory()) {
      if ([".git", ".prometheus"].includes(entry.name)) continue;
      out.push(...walk(full));
    } else if (entry.isFile()) {
      out.push(rel);
    }
  }
  return out.sort();
}

const files = walk(root);
const fileSet = new Set(files);

function pass(message) {
  console.log(`PASS: ${message}`);
}

function fail(source, ref, reason) {
  failures.push(`${source} references ${ref}: ${reason}`);
}

function isExternal(ref) {
  return (
    ref === "" ||
    ref.startsWith("#") ||
    ref.startsWith("~") ||
    ref.startsWith("/") ||
    ref.startsWith("../") ||
    ref.startsWith("./../") ||
    /^[a-z][a-z0-9+.-]*:/i.test(ref)
  );
}

function cleanRef(ref) {
  return ref
    .trim()
    .replace(/^<|>$/g, "")
    .replace(/[),.;:]+$/g, "")
    .replace(/^['"]|['"]$/g, "");
}

function stripAnchor(ref) {
  return ref.split("#")[0];
}

function resolveLocal(source, ref, rootRelative = false) {
  const withoutAnchor = stripAnchor(cleanRef(ref));
  if (withoutAnchor.includes("*")) return null;
  if (isExternal(withoutAnchor)) return null;
  const base = rootRelative || !source.includes(path.sep) ? "." : path.dirname(source);
  return path.normalize(path.join(base, withoutAnchor)).replace(/^\.\//, "");
}

function existsLocal(resolved) {
  return fileSet.has(resolved) || fs.existsSync(path.join(root, resolved));
}

function checkResolved(source, ref, options = {}) {
  const resolved = resolveLocal(source, ref, options.rootRelative || false);
  if (!resolved) return;
  if (resolved.startsWith("..")) return;
  if (existsLocal(resolved)) {
    pass(`${source} local reference exists: ${ref}`);
  } else {
    fail(source, ref, "missing project-local target");
  }
}

function checkMarkdownLinks(file, text) {
  const linkPattern = /\[[^\]]+\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g;
  for (const match of text.matchAll(linkPattern)) {
    checkResolved(file, match[1]);
  }
}

function looksLikeLocalPath(source, token) {
  if (fileSet.has(token)) return true;
  if (token.startsWith("scripts/") && !token.endsWith(".sh")) return false;
  if (!token.includes("/") && /^[A-Z0-9][A-Z0-9_.-]+\.(md|yaml|json)$/i.test(token)) {
    const sameDir = source.includes(path.sep) ? path.join(path.dirname(source), token) : token;
    return fileSet.has(sameDir);
  }
  return (
    token.startsWith("./") ||
    token.startsWith("docs/") ||
    token.startsWith("infra/") ||
    token.startsWith("scripts/")
  );
}

function checkCodeSpans(file, text) {
  const spanPattern = /`([^`\n]+)`/g;
  for (const match of text.matchAll(spanPattern)) {
    const tokens = match[1].split(/\s+/);
    for (const raw of tokens) {
      const token = cleanRef(raw);
      if (!looksLikeLocalPath(file, token)) continue;
      checkResolved(file, token, { rootRelative: token.includes("/") || fileSet.has(token) });
    }
  }
}

function checkScriptLiterals(file, text) {
  const literalPattern = /(?:^|[^A-Za-z0-9_.~/-])((?:docs|infra)\/[A-Za-z0-9_.\/-]+|scripts\/[A-Za-z0-9_.\/-]+\.sh|[A-Z0-9][A-Z0-9_.-]+\.(?:md|yaml|json))/gi;
  for (const match of text.matchAll(literalPattern)) {
    checkResolved(file, match[1], { rootRelative: true });
  }
}

for (const file of files) {
  if (file === "PROGRESS-2026-05-16.md") continue;
  const text = fs.readFileSync(path.join(root, file), "utf8");
  if (file.endsWith(".md")) {
    checkMarkdownLinks(file, text);
    checkCodeSpans(file, text);
  }
  if (file.startsWith("scripts/") && file.endsWith(".sh")) {
    checkScriptLiterals(file, text);
  }
}

if (failures.length) {
  for (const failure of failures) {
    console.error(`FAIL: ${failure}`);
  }
  console.error(`\n${failures.length} local reference validation failure(s)`);
  process.exit(1);
}

console.log("\nLocal reference validation passed.");
NODE
