#!/usr/bin/env python3
"""Render PlantUML diagram sources with the SAME PlantUML version the IG
Publisher uses, so locally generated SVGs match the published output.

The IG Publisher renders ``input/images-source/*.plantuml`` with the
``plantuml.jar`` bundled in the IG template chain (``kt.template`` ->
``fhir.base.template``), currently **PlantUML 1.2025.2**. A newer local
PlantUML (1.2026.x) renders a red "this syntax is deprecated" banner for the
``#colour:activity;`` prefix that 1.2025.2 accepts silently -- so rendering
locally with a newer version does NOT match CI.

This script pins the matching version: it prefers the jar the IG Publisher
expanded into ``template/scripts/plantuml.jar`` (present after a build);
otherwise it downloads the pinned release into ``.cache/``.

Usage:
    python3 scripts/render-diagrams.py                 # render all sources
    python3 scripts/render-diagrams.py -o /tmp/out     # render to another dir
    python3 scripts/render-diagrams.py input/images-source/foo.plantuml
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

# Keep in sync with the PlantUML bundled by fhir.base.template (the IG template).
PLANTUML_VERSION = "1.2025.2"
DOWNLOAD_URL = (
    f"https://github.com/plantuml/plantuml/releases/download/"
    f"v{PLANTUML_VERSION}/plantuml-{PLANTUML_VERSION}.jar"
)

REPO_ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = REPO_ROOT / "input" / "images-source"
TEMPLATE_JAR = REPO_ROOT / "template" / "scripts" / "plantuml.jar"
CACHE_JAR = REPO_ROOT / ".cache" / f"plantuml-{PLANTUML_VERSION}.jar"


def _download(url: str, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    print(f"Downloading PlantUML {PLANTUML_VERSION} -> {dest} ...")
    req = urllib.request.Request(url, headers={"User-Agent": "koppeltaal-render-diagrams"})
    with urllib.request.urlopen(req) as resp, open(dest, "wb") as fh:
        shutil.copyfileobj(resp, fh)


def resolve_jar() -> Path:
    """Prefer the exact jar the IG Publisher uses; fall back to a pinned download."""
    if TEMPLATE_JAR.is_file():
        return TEMPLATE_JAR
    if not CACHE_JAR.is_file():
        _download(DOWNLOAD_URL, CACHE_JAR)
    return CACHE_JAR


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Render PlantUML sources with the IG Publisher's PlantUML version."
    )
    parser.add_argument(
        "sources", nargs="*", type=Path,
        help="Specific .plantuml files (default: all in input/images-source).",
    )
    parser.add_argument(
        "-o", "--out", type=Path, default=SRC_DIR,
        help="Output directory for the generated SVGs (default: input/images-source).",
    )
    args = parser.parse_args()

    sources = args.sources or sorted(SRC_DIR.glob("*.plantuml"))
    if not sources:
        print("No .plantuml sources found.", file=sys.stderr)
        return 1

    jar = resolve_jar()
    out_dir = args.out.resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    version_line = subprocess.run(
        ["java", "-jar", str(jar), "-version"],
        capture_output=True, text=True,
    ).stdout.splitlines()
    print(version_line[0] if version_line else f"PlantUML {PLANTUML_VERSION}")

    cmd = [
        "java", "-jar", str(jar),
        "-nometadata", "-failfast2", "-tsvg",
        "-o", str(out_dir),
        *(str(s) for s in sources),
    ]
    result = subprocess.run(cmd)
    if result.returncode == 0:
        print(f"Rendered {len(sources)} diagram(s) -> {out_dir}")
    else:
        print(f"PlantUML failed (exit {result.returncode}).", file=sys.stderr)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
