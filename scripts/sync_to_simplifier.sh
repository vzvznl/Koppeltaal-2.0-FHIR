#!/usr/bin/env bash
#
# sync_to_simplifier.sh - Sync FHIR resources to Simplifier.net via ZIP API
#
# Replaces the fragile `fhir project clone/push` workflow with a simple
# download-modify-upload cycle using the Simplifier REST API.
#
# Modes:
#   sync (default) - Download project, replace resources, upload
#   restore        - Upload a backup ZIP to restore a previous state
#   backup         - Download and save the current project state
#
# Usage:
#   ./scripts/sync_to_simplifier.sh [--dry-run]
#   ./scripts/sync_to_simplifier.sh restore <backup.zip>
#   ./scripts/sync_to_simplifier.sh backup
#
# Environment:
#   FHIR_EMAIL      Simplifier.net email (required)
#   FHIR_PASSWORD   Simplifier.net password (required)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SIMPLIFIER_PROJECT="koppeltaalv2.0"
SIMPLIFIER_API="https://api.simplifier.net"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
WORK_DIR="$PROJECT_ROOT/.simplifier-sync"
BACKUP_DIR="$PROJECT_ROOT/backups"
DOCKER_IMAGE="koppeltaal-builder"
DRY_RUN=false

# ── Helpers ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
step()  { echo -e "\n${GREEN}=== $* ===${NC}"; }

check_credentials() {
    [[ -z "${FHIR_EMAIL:-}" || -z "${FHIR_PASSWORD:-}" ]] && {
        error "FHIR_EMAIL and FHIR_PASSWORD must be set"; exit 1
    }
    for tool in curl jq docker; do
        command -v "$tool" &>/dev/null || { error "'$tool' not found"; exit 1; }
    done
}

build_resources() {
    step "Building FHIR resources"

    # Build Docker image if it doesn't exist
    if ! docker image inspect "$DOCKER_IMAGE" &>/dev/null; then
        info "Docker image '$DOCKER_IMAGE' not found, building..."
        docker build "$PROJECT_ROOT" -t "$DOCKER_IMAGE"
        ok "Docker image built"
    else
        ok "Docker image '$DOCKER_IMAGE' exists"
    fi

    # Always do a fresh build
    info "Running build (this may take a few minutes)..."
    rm -rf "$PROJECT_ROOT/fsh-generated"
    docker run -v "$PROJECT_ROOT:/src" "$DOCKER_IMAGE" build-ig
    ok "Build complete"
}

get_token() {
    local token
    token=$(curl -sf -X POST "$SIMPLIFIER_API/token" \
        -H "Content-Type: application/json" \
        -d "{\"Email\": \"$FHIR_EMAIL\", \"Password\": \"$FHIR_PASSWORD\"}" \
        | jq -r '.token // empty')
    [[ -z "$token" ]] && { error "Authentication failed"; exit 1; }
    echo "$token"
}

download_project() {
    local token="$1" dest="$2"
    local http_code
    http_code=$(curl -s -o "$dest" -w "%{http_code}" \
        -H "Authorization: Bearer $token" \
        "$SIMPLIFIER_API/$SIMPLIFIER_PROJECT/zip")
    [[ "$http_code" -eq 200 ]] || { error "Download failed (HTTP $http_code)"; exit 1; }
}

upload_project() {
    local token="$1" zip_file="$2"
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X PUT \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/zip" \
        --data-binary "@$zip_file" \
        "$SIMPLIFIER_API/$SIMPLIFIER_PROJECT/zip")
    if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
        ok "Upload successful (HTTP $http_code)"
    else
        error "Upload failed (HTTP $http_code)"
        return 1
    fi
}

# ── Mode: backup ──────────────────────────────────────────────────────────────
do_backup() {
    check_credentials
    step "Downloading project backup"
    local token
    token=$(get_token)
    ok "Authenticated"

    mkdir -p "$BACKUP_DIR"
    local dest="$BACKUP_DIR/simplifier-backup-${TIMESTAMP}.zip"
    download_project "$token" "$dest"
    ok "Saved: $dest ($(du -h "$dest" | cut -f1))"
}

# ── Mode: restore ─────────────────────────────────────────────────────────────
do_restore() {
    local zip_file="$1"
    [[ -f "$zip_file" ]] || { error "File not found: $zip_file"; exit 1; }
    check_credentials

    echo ""
    echo -e "${RED}  RESTORE will overwrite the Simplifier project!${NC}"
    echo "  File: $zip_file ($(du -h "$zip_file" | cut -f1))"
    echo ""

    if [[ "${CI:-}" != "true" ]]; then
        read -rp "Type RESTORE to confirm: " confirm
        [[ "$confirm" == "RESTORE" ]] || { error "Aborted"; exit 1; }
    fi

    step "Restoring"
    local token
    token=$(get_token)
    upload_project "$token" "$zip_file"
    echo -e "\n${GREEN}Restored.${NC} Verify: https://simplifier.net/$SIMPLIFIER_PROJECT"
}

# ── Mode: sync (default) ─────────────────────────────────────────────────────
do_sync() {
    check_credentials

    # Build fresh unless CI provides pre-built resources via SKIP_BUILD
    if [[ "${SKIP_BUILD:-}" == "true" ]]; then
        info "Skipping build (SKIP_BUILD=true, using pre-built resources)"
    else
        build_resources
    fi

    local resources_dir="$PROJECT_ROOT/fsh-generated/resources"
    [[ -d "$resources_dir" ]] || { error "Build did not produce fsh-generated/resources/"; exit 1; }
    local resource_count
    resource_count=$(find "$resources_dir" -name "*.json" -type f | wc -l | tr -d ' ')
    local version
    version=$(grep '^version:' "$PROJECT_ROOT/sushi-config.yaml" | sed 's/version: //' | tr -d '[:space:]')
    ok "Build output: $resource_count resources, version $version"

    # Authenticate
    step "Authenticating"
    local token
    token=$(get_token)
    ok "Token obtained"

    # Download current project
    step "Downloading current project (backup)"
    mkdir -p "$WORK_DIR" "$BACKUP_DIR"
    local backup_zip="$BACKUP_DIR/simplifier-backup-${TIMESTAMP}.zip"
    download_project "$token" "$backup_zip"
    ok "Backup: $backup_zip ($(du -h "$backup_zip" | cut -f1))"

    # Unpack
    step "Preparing updated project"
    local unpack_dir="$WORK_DIR/project"
    mkdir -p "$unpack_dir"
    unzip -o -q "$backup_zip" -d "$unpack_dir"

    info "Current project structure:"
    find "$unpack_dir" -maxdepth 2 -type f | head -20 | sed "s|$unpack_dir/||"
    echo "  ..."

    # Remove stale dependency directory left by previous Simplifier CLI workflow
    if [[ -d "$unpack_dir/nl-core" ]]; then
        info "Removing stale directory: nl-core/"
        rm -rf "$unpack_dir/nl-core"
    fi

    # Detect resource location
    local resource_target
    if [[ -d "$unpack_dir/resources" ]]; then
        resource_target="$unpack_dir/resources"
        info "Resources location: resources/"
    else
        resource_target="$unpack_dir"
        info "Resources location: project root"
    fi

    # Remove old FHIR resources (only JSON files with a resourceType field)
    info "Removing old FHIR resources..."
    local removed=0
    while IFS= read -r -d '' file; do
        if python3 -c "
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    is_fhir = 'resourceType' in d
except Exception:
    is_fhir = False
sys.exit(0 if is_fhir else 1)
" "$file" 2>/dev/null; then
            rm "$file"
            ((removed++)) || true
        fi
    done < <(find "$resource_target" -maxdepth 1 -name "*.json" -type f -print0)
    info "Removed $removed old resources"

    # Copy new resources
    info "Copying $resource_count new resources..."
    cp "$resources_dir"/*.json "$resource_target/"

    # Update metadata
    cp "$PROJECT_ROOT/package.json" "$unpack_dir/"
    cp "$PROJECT_ROOT/README.md" "$unpack_dir/"
    cp "$PROJECT_ROOT/CHANGELOG.md" "$unpack_dir/"

    # Rewrite relative .html links to absolute GitHub Pages URLs.
    # FSH source uses relative links like [text](page.html) which work in the
    # IG Publisher output but break on Simplifier. This rewrites them to point
    # to the canonical IG on GitHub Pages.
    local ig_base_url="https://vzvznl.github.io/Koppeltaal-2.0-FHIR"
    info "Rewriting relative .html links to $ig_base_url/..."
    local rewritten=0
    while IFS= read -r -d '' file; do
        if grep -q ']([-a-zA-Z0-9_]*\.html)' "$file"; then
            sed -i.bak "s|](\([-a-zA-Z0-9_]*\.html\))|](${ig_base_url}/\1)|g" "$file"
            rm -f "${file}.bak"
            ((rewritten++)) || true
        fi
    done < <(find "$resource_target" -maxdepth 1 -name "*.json" -type f -print0)
    if [[ "$rewritten" -gt 0 ]]; then
        ok "Rewrote links in $rewritten resources"
    fi

    # Update existing IG pages with repo content
    local guides_dir="$unpack_dir/guides/koppeltaal"
    if [[ -d "$guides_dir" ]]; then
        info "Updating existing IG pages..."
        python3 "$SCRIPT_DIR/update_simplifier_ig_pages.py" \
            "$guides_dir" "$PROJECT_ROOT" "$ig_base_url"
    fi

    local final_count
    final_count=$(find "$resource_target" -maxdepth 1 -name "*.json" -type f | wc -l | tr -d ' ')
    ok "Project ready: $final_count JSON files"

    # Build upload ZIP
    step "Building upload ZIP"
    local upload_zip="$WORK_DIR/upload.zip"
    (cd "$unpack_dir" && zip -q -r "$upload_zip" .)
    local upload_size
    upload_size=$(du -h "$upload_zip" | cut -f1)
    ok "ZIP ready: $upload_size"

    # Summary
    step "Summary"
    echo ""
    echo "  Project:     $SIMPLIFIER_PROJECT"
    echo "  Version:     $version"
    echo "  Resources:   $removed removed, $resource_count added"
    echo "  Backup:      $backup_zip"
    echo "  Upload size: $upload_size"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        warn "Dry run — not uploading"
        trap - EXIT
        exit 0
    fi

    if [[ "${CI:-}" != "true" ]]; then
        read -rp "Upload to Simplifier.net? [y/N] " confirm
        [[ "$confirm" == "y" || "$confirm" == "Y" ]] || { error "Aborted"; exit 1; }
    fi

    # Upload
    info "Uploading to Simplifier.net..."
    if ! upload_project "$token" "$upload_zip"; then
        echo ""
        echo "  Backup is safe: $backup_zip"
        echo "  To restore: $0 restore $backup_zip"
        exit 1
    fi

    echo ""
    echo -e "${GREEN}Done!${NC} Verify: https://simplifier.net/$SIMPLIFIER_PROJECT"
    echo "  To restore: $0 restore $backup_zip"
}

# ── Cleanup ───────────────────────────────────────────────────────────────────
# Always start clean; also clean up on exit (unless dry-run)
rm -rf "$WORK_DIR"
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

# ── Main ──────────────────────────────────────────────────────────────────────
case "${1:-sync}" in
    sync)      do_sync ;;
    --dry-run) DRY_RUN=true; do_sync ;;
    backup)    do_backup ;;
    restore)
        [[ -z "${2:-}" ]] && { echo "Usage: $0 restore <backup.zip>"; exit 1; }
        do_restore "$2"
        ;;
    --help|-h)
        echo "Usage:"
        echo "  $0 [--dry-run]              Sync resources to Simplifier"
        echo "  $0 restore <backup.zip>     Restore project from backup"
        echo "  $0 backup                   Download project backup only"
        echo ""
        echo "Environment: FHIR_EMAIL, FHIR_PASSWORD"
        ;;
    *)
        error "Unknown command: $1"
        echo "Run $0 --help for usage"
        exit 1
        ;;
esac
