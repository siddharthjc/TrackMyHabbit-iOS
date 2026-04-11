#!/usr/bin/env node
/**
 * CSS token audit — CI-friendly.
 *
 * - Scans *.css under the repo (skips common build/vendor dirs).
 * - `tokens.css` is the only file allowed to define raw primitives (skipped).
 * - All other stylesheets must use var(--token) for visual values.
 *
 * Exit code: 1 if any ERROR; warnings do not fail the build.
 *
 * Usage: node scripts/token-audit.js
 */

const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");

const IGNORE_DIR_NAMES = new Set([
  "node_modules",
  "DerivedData",
  ".git",
  "build",
  "Pods",
  "Carthage",
]);

const TOKEN_FILE = "tokens.css";

/** @type {{ file: string; line: number; level: 'error' | 'warn'; message: string; suggestion?: string }[]} */
const findings = [];

function walkCssFiles(dir, out = []) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return out;
  }
  for (const ent of entries) {
    const full = path.join(dir, ent.name);
    if (ent.isDirectory()) {
      if (IGNORE_DIR_NAMES.has(ent.name)) continue;
      walkCssFiles(full, out);
    } else if (ent.isFile() && ent.name.endsWith(".css")) {
      out.push(full);
    }
  }
  return out;
}

function suggestForHex() {
  return "Move hex into tokens.css Layer 1 (--ds-*) or Layer 2 (--color-*), then use var(--color-…).";
}

function suggestForPx(prop) {
  return `Use var(--space-*) from tokens.css / AppTheme.Spacing for ${prop}.`;
}

function auditFile(absPath) {
  const rel = path.relative(ROOT, absPath);
  const base = path.basename(absPath);
  const isTokenFile = base === TOKEN_FILE;

  const raw = fs.readFileSync(absPath, "utf8");
  const lines = raw.split(/\r?\n/);

  lines.forEach((line, idx) => {
    const lineNo = idx + 1;
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("/*") || trimmed.startsWith("*") || trimmed.startsWith("//"))
      return;

    if (isTokenFile) return;

    // Hex colors not inside var( … )
    const hexMatch = line.match(/#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})\b/);
    if (hexMatch) {
      const inVar = /var\s*\([^)]*#/.test(line) || line.includes("/*");
      if (!inVar) {
        findings.push({
          file: rel,
          line: lineNo,
          level: "error",
          message: `Hardcoded hex color ${hexMatch[0]}`,
          suggestion: suggestForHex(),
        });
      }
    }

    const rgb = /\brgba?\(\s*[0-9.]/.test(line);
    if (rgb && !/var\s*\(/.test(line)) {
      findings.push({
        file: rel,
        line: lineNo,
        level: "error",
        message: "Hardcoded rgb/rgba (use tokens / var)",
        suggestion: "Define in tokens.css and reference var(--…).",
      });
    }

    const propMatch = line.match(
      /^\s*(padding|margin|gap|border-radius|font-size|font-weight|letter-spacing|line-height|width|height|max-width|min-height)\s*:\s*(.+?);?\s*$/i
    );
    if (propMatch) {
      const val = propMatch[2];
      if (!/var\s*\(/.test(val) && /[0-9.]+\s*(px|rem|em)/.test(val)) {
        findings.push({
          file: rel,
          line: lineNo,
          level: "error",
          message: `Hardcoded ${propMatch[1]}: ${val.trim()}`,
          suggestion: suggestForPx(propMatch[1].toLowerCase()),
        });
      }
    }

    if (/\btransition\s*:/i.test(line) && /[0-9]+(\.[0-9]+)?(ms|s)\b/.test(line) && !/var\s*\(/.test(line)) {
      findings.push({
        file: rel,
        line: lineNo,
        level: "warn",
        message: "Raw transition duration",
        suggestion: "Prefer var(--duration-*) from tokens.css.",
      });
    }

    if (/\bbox-shadow\s*:/i.test(line) && !/var\s*\(/.test(line) && /[0-9]/.test(line)) {
      findings.push({
        file: rel,
        line: lineNo,
        level: "error",
        message: "Hardcoded box-shadow",
        suggestion: "Use elevation tokens / var(--shadow-*).",
      });
    }

    if (/\bz-index\s*:/i.test(line) && /:\s*[0-9-]+/.test(line) && !/var\s*\(/.test(line)) {
      findings.push({
        file: rel,
        line: lineNo,
        level: "warn",
        message: "Numeric z-index without var",
        suggestion: "Use var(--z-*).",
      });
    }
  });
}

function main() {
  const cssFiles = walkCssFiles(ROOT);
  if (cssFiles.length === 0) {
    console.log("token-audit: no CSS files found under repo root.");
    process.exit(0);
  }

  for (const f of cssFiles) {
    auditFile(f);
  }

  const errors = findings.filter((f) => f.level === "error");
  const warnings = findings.filter((f) => f.level === "warn");

  for (const f of findings) {
    const tag = f.level.toUpperCase();
    console.log(`${tag} ${f.file}:${f.line}: ${f.message}`);
    if (f.suggestion) console.log(`       → ${f.suggestion}`);
  }

  console.log(
    `\ntoken-audit: ${cssFiles.length} CSS file(s) scanned; ${errors.length} error(s), ${warnings.length} warning(s).`
  );

  if (errors.length > 0) {
    process.exit(1);
  }
  process.exit(0);
}

main();
