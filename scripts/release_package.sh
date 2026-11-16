#!/usr/bin/env bash
#
# release_package.sh - Publish a FHIR package to Simplifier via Firely Terminal CLI
#
# Extracts the version from sushi-config.yaml, builds release notes from
# CHANGELOG.md, downloads and validates the canonical GitHub Release asset,
# publishes it unchanged using `fhir`, and verifies the Simplifier checksum.
#
# Usage:
#   ./scripts/release_package.sh [--dry-run]
#
# Environment:
#   FHIR_EMAIL      Simplifier.net email (optional: without it, `fhir login` asks)
#   FHIR_PASSWORD   Simplifier.net password (optional: without it, `fhir login` asks)
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
LAST_PUBLISHED=$(curl -sf --connect-timeout 20 --max-time 60 "https://packages.simplifier.net/$PACKAGE_NAME" \
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

# ── Download canonical GitHub release package ────────────────────────────────
step "Downloading canonical GitHub release package"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

GITHUB_ASSET_URL="https://github.com/vzvznl/Koppeltaal-2.0-FHIR/releases/download/v${VERSION}/koppeltaalv2-${VERSION}.tgz"
RELEASE_TGZ="$WORK_DIR/koppeltaalv2-${VERSION}.tgz"

# GitHub is the canonical release source. Never extract, modify, or repack this
# archive here: macOS bsdtar can add AppleDouble and xattr metadata, and any
# transformation would make the Simplifier package differ from GitHub.
info "GitHub asset: $GITHUB_ASSET_URL"
curl -fL --retry 3 --connect-timeout 20 --max-time 300 --output "$RELEASE_TGZ" "$GITHUB_ASSET_URL"

RELEASE_SIZE=$(du -h "$RELEASE_TGZ" | cut -f1)
ok "Downloaded canonical package: $RELEASE_SIZE"

# ── Summary ──────────────────────────────────────────────────────────────────
step "Summary"
echo ""
echo "  GitHub asset:  $GITHUB_ASSET_URL"
python3 "$PROJECT_ROOT/scripts/release_artifact.py" inspect \
    "$RELEASE_TGZ" \
    --name "$PACKAGE_NAME" \
    --version "$VERSION" | sed 's/^/  /'
echo ""
echo "  Release notes:"
while IFS= read -r release_note_line; do
    printf '    %s\n' "$release_note_line"
done <<< "$RELEASE_NOTES"
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
command -v fhir &>/dev/null || { error "'fhir' CLI (Firely Terminal) not found in PATH"; exit 1; }

step "Publishing to Simplifier"

info "Authenticating..."
if [[ -n "${FHIR_EMAIL:-}" && -n "${FHIR_PASSWORD:-}" ]]; then
    fhir login email="$FHIR_EMAIL" password="$FHIR_PASSWORD"
else
    # Firely Terminal reuses a saved login or asks for the e-mail and password,
    # hiding the password, so neither ends up in the shell history.
    fhir login
fi
ok "Logged in"

info "Publishing ${PACKAGE_NAME} ${VERSION}..."
fhir publish-package "$RELEASE_TGZ"
ok "Published ${PACKAGE_NAME} ${VERSION}"

# ── Verify published bytes ───────────────────────────────────────────────────
step "Verifying GitHub and Simplifier package identity"

SIMPLIFIER_URL="https://packages.simplifier.net/${PACKAGE_NAME}/-/${PACKAGE_NAME}-${VERSION}.tgz"
SIMPLIFIER_TGZ="$WORK_DIR/simplifier-${PACKAGE_NAME}-${VERSION}.tgz"
SIMPLIFIER_DOWNLOADED=false

for attempt in {1..6}; do
    if curl -fsSL --connect-timeout 20 --max-time 120 --output "$SIMPLIFIER_TGZ" "$SIMPLIFIER_URL"; then
        SIMPLIFIER_DOWNLOADED=true
        break
    fi
    if [[ "$attempt" -lt 6 ]]; then
        warn "Published package is not available yet; retrying in 5 seconds"
        sleep 5
    fi
done

[[ "$SIMPLIFIER_DOWNLOADED" == "true" ]] || {
    error "Could not download published package for checksum verification: $SIMPLIFIER_URL"
    exit 1
}

python3 "$PROJECT_ROOT/scripts/release_artifact.py" compare \
    "$RELEASE_TGZ" \
    "$SIMPLIFIER_TGZ"
ok "GitHub and Simplifier packages are byte-identical"

echo ""
echo -e "${GREEN}Done!${NC} Published ${PACKAGE_NAME} ${VERSION}"
echo "  https://simplifier.net/packages/${PACKAGE_NAME}/${VERSION}"
