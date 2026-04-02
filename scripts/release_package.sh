#!/usr/bin/env bash
#
# release_package.sh - Publish a FHIR package to Simplifier via Firely Terminal CLI
#
# Extracts the version from sushi-config.yaml, builds release notes from
# CHANGELOG.md, patches the IG Publisher output, and publishes using `fhir`.
#
# Usage:
#   ./scripts/release_package.sh [--dry-run]
#
# Environment:
#   FHIR_EMAIL      Simplifier.net email (required)
#   FHIR_PASSWORD   Simplifier.net password (required)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DRY_RUN=false

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# ── Helpers ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
step()  { echo -e "\n${GREEN}=== $* ===${NC}"; }

# ── Read version ─────────────────────────────────────────────────────────────
VERSION=$(grep '^version:' "$PROJECT_ROOT/sushi-config.yaml" | sed 's/version: //' | tr -d '[:space:]')
PACKAGE_NAME=$(grep '^id:' "$PROJECT_ROOT/sushi-config.yaml" | sed 's/id: //' | tr -d '[:space:]')

[[ -z "$VERSION" ]] && { error "Could not read version from sushi-config.yaml"; exit 1; }
[[ -z "$PACKAGE_NAME" ]] && { error "Could not read id from sushi-config.yaml"; exit 1; }

# ── Find last published version on Simplifier ────────────────────────────────
step "Checking published versions"
LAST_PUBLISHED=$(curl -sf "https://packages.simplifier.net/$PACKAGE_NAME" \
    | python3 -c "
import json, re, sys

def parse_ver(s):
    \"\"\"Parse version string into (major, minor, patch, pre) tuple for sorting.
    Pre-release versions sort before their release (e.g. 0.15.0-beta.9 < 0.15.0).\"\"\"
    m = re.match(r'(\d+)\.(\d+)\.(\d+)(?:-(.+))?', s)
    if not m: return None
    major, minor, patch = int(m[1]), int(m[2]), int(m[3])
    pre = m[4] if m[4] else None
    # No pre-release = (0,) which sorts after any (-1, 'beta.9')
    pre_tuple = (-1, pre) if pre else (0,)
    return (major, minor, patch, pre_tuple)

data = json.load(sys.stdin)
target = parse_ver(sys.argv[1])
best = None
best_str = ''
for v_str in data.get('versions', {}):
    v = parse_ver(v_str)
    if v and v < target:
        if best is None or v > best:
            best = v
            best_str = v_str
print(best_str)
" "$VERSION" 2>/dev/null || echo "")

if [[ -n "$LAST_PUBLISHED" ]]; then
    ok "Last published: $LAST_PUBLISHED"
    info "Collecting release notes from $LAST_PUBLISHED to $VERSION"
else
    warn "No prior version found — using notes for $VERSION only"
fi

# ── Extract release notes from CHANGELOG.md ──────────────────────────────────
RELEASE_NOTES=$(python3 -c "
import re, sys

def parse_ver(s):
    m = re.match(r'(\d+)\.(\d+)\.(\d+)(?:-(.+))?', s)
    if not m: return None
    major, minor, patch = int(m[1]), int(m[2]), int(m[3])
    pre = m[4] if m[4] else None
    pre_tuple = (-1, pre) if pre else (0,)
    return (major, minor, patch, pre_tuple)

target = parse_ver(sys.argv[1])
last_published = parse_ver(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[3] else None
changelog = open(sys.argv[2], encoding='utf-8').read()

# Parse all version sections
sections = re.split(r'^(## .+)$', changelog, flags=re.MULTILINE)

notes = []
i = 1
while i < len(sections) - 1:
    header = sections[i]
    body = sections[i + 1]

    m = re.match(r'^## (\S+)', header)
    if m:
        v = parse_ver(m.group(1))
        if v:
            include = v <= target
            if last_published:
                include = include and v > last_published
            if include:
                notes.append(header.strip() + '\n' + body.rstrip())
    i += 2

if not notes:
    print(f'ERROR: No changelog entries found', file=sys.stderr)
    sys.exit(1)

print('\n\n'.join(notes))
" "$VERSION" "$PROJECT_ROOT/CHANGELOG.md" "${LAST_PUBLISHED:-}")

# ── Locate package ───────────────────────────────────────────────────────────
PACKAGE_TGZ="$PROJECT_ROOT/output/package.tgz"
[[ -f "$PACKAGE_TGZ" ]] || { error "Package not found: $PACKAGE_TGZ (run a build first)"; exit 1; }

# Verify the package name and version inside the .tgz match
PACKAGE_JSON=$(tar -xzf "$PACKAGE_TGZ" -O package/package.json)
PKG_INNER_NAME=$(echo "$PACKAGE_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['name'])")
PKG_INNER_VERSION=$(echo "$PACKAGE_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['version'])")

[[ "$PKG_INNER_NAME" == "$PACKAGE_NAME" ]] || {
    error "Package name mismatch: sushi-config=$PACKAGE_NAME, package.tgz=$PKG_INNER_NAME"
    exit 1
}
[[ "$PKG_INNER_VERSION" == "$VERSION" ]] || {
    error "Version mismatch: sushi-config=$VERSION, package.tgz=$PKG_INNER_VERSION"
    exit 1
}

# ── Patch notForPublication flag ─────────────────────────────────────────────
step "Preparing package for publication"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

tar -xzf "$PACKAGE_TGZ" -C "$WORK_DIR"

python3 -c "
import json, sys, pathlib

pkg_file = pathlib.Path(sys.argv[1]) / 'package' / 'package.json'
pkg = json.loads(pkg_file.read_text(encoding='utf-8'))

changed = False

if pkg.get('notForPublication'):
    del pkg['notForPublication']
    changed = True
    print('Removed notForPublication flag')

if pkg.get('url', '').startswith('file://'):
    del pkg['url']
    changed = True
    print('Removed file:// url')

if not changed:
    print('No patches needed')

pkg_file.write_text(json.dumps(pkg, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
" "$WORK_DIR"

RELEASE_TGZ="$WORK_DIR/${PACKAGE_NAME}-${VERSION}.tgz"
(cd "$WORK_DIR" && tar -czf "$RELEASE_TGZ" package/)
RELEASE_SIZE=$(du -h "$RELEASE_TGZ" | cut -f1)
ok "Package ready: $RELEASE_SIZE"

# ── Summary ──────────────────────────────────────────────────────────────────
step "Summary"
echo ""
echo "  Package:       $PACKAGE_NAME"
echo "  Version:       $VERSION"
echo "  Size:          $RELEASE_SIZE"
echo ""
echo "  Release notes:"
echo "$RELEASE_NOTES" | sed 's/^/    /'
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    warn "Dry run — not publishing"
    echo ""
    echo "  To publish: $0"
    exit 0
fi

# ── Confirm ──────────────────────────────────────────────────────────────────
if [[ "${CI:-}" != "true" ]]; then
    read -rp "Publish to Simplifier.net? [y/N] " confirm
    [[ "$confirm" == "y" || "$confirm" == "Y" ]] || { error "Aborted"; exit 1; }
fi

# ── Authenticate and publish ─────────────────────────────────────────────────
[[ -z "${FHIR_EMAIL:-}" || -z "${FHIR_PASSWORD:-}" ]] && {
    error "FHIR_EMAIL and FHIR_PASSWORD must be set"; exit 1
}

command -v fhir &>/dev/null || { error "'fhir' CLI (Firely Terminal) not found in PATH"; exit 1; }

step "Publishing to Simplifier"

info "Authenticating..."
fhir login email="$FHIR_EMAIL" password="$FHIR_PASSWORD"
ok "Logged in"

info "Publishing ${PACKAGE_NAME} ${VERSION}..."
fhir publish-package "$RELEASE_TGZ"

echo ""
echo -e "${GREEN}Done!${NC} Published ${PACKAGE_NAME} ${VERSION}"
echo "  https://simplifier.net/packages/${PACKAGE_NAME}/${VERSION}"
