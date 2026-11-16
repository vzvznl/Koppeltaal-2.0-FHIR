#!/usr/bin/env python3

import argparse
import copy
import gzip
import hashlib
import io
import json
import sys
import tarfile
import zlib
from dataclasses import dataclass
from pathlib import Path, PurePosixPath


MANIFEST_PATH = "package/package.json"


class ArchiveValidationError(ValueError):
    pass


@dataclass(frozen=True)
class ArchiveSummary:
    path: Path
    package_name: str
    package_version: str
    sha256: str
    compressed_bytes: int
    uncompressed_bytes: int
    members: int
    regular_files: int
    directories: int
    json_files: int
    macos_metadata: int


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as archive_file:
        for chunk in iter(lambda: archive_file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _verify_gzip_stream(path: Path) -> None:
    # Reading the tar headers stops at the end-of-archive marker, before the gzip
    # trailer, so only a full read checks the CRC-32 and catches a truncated file.
    try:
        with gzip.open(path, "rb") as stream:
            while stream.read(1024 * 1024):
                pass
    except (OSError, EOFError, zlib.error) as error:
        raise ArchiveValidationError(f"Corrupt gzip stream in {path}: {error}") from error


def _read_manifest(archive: tarfile.TarFile) -> dict:
    matches = [member for member in archive.getmembers() if member.name == MANIFEST_PATH]
    if len(matches) != 1 or not matches[0].isfile():
        raise ArchiveValidationError(
            f"Expected exactly one regular {MANIFEST_PATH}, found {len(matches)}"
        )

    manifest_file = archive.extractfile(matches[0])
    if manifest_file is None:
        raise ArchiveValidationError(f"Could not read {MANIFEST_PATH}")
    try:
        manifest = json.load(manifest_file)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ArchiveValidationError(f"Invalid {MANIFEST_PATH}: {error}") from error
    if not isinstance(manifest, dict):
        raise ArchiveValidationError(f"{MANIFEST_PATH} must contain a JSON object")
    return manifest


def _macos_metadata_issues(members: list[tarfile.TarInfo]) -> list[str]:
    issues = []
    for member in members:
        path_parts = PurePosixPath(member.name).parts
        if any(part.startswith("._") for part in path_parts):
            issues.append(f"AppleDouble member: {member.name}")
        if ".DS_Store" in path_parts:
            issues.append(f"Finder metadata member: {member.name}")
        if "__MACOSX" in path_parts:
            issues.append(f"macOS archive directory member: {member.name}")

        for key in member.pax_headers:
            normalized_key = key.lower()
            if "xattr" in normalized_key or "apple" in normalized_key:
                issues.append(
                    f"Apple extended attribute PAX header on {member.name}: {key}"
                )
    return issues


def inspect_archive(
    path: Path,
    expected_name: str,
    expected_version: str,
    require_publishable: bool = True,
) -> ArchiveSummary:
    path = Path(path)
    _verify_gzip_stream(path)
    try:
        with tarfile.open(path, "r:gz") as archive:
            members = archive.getmembers()
            metadata_issues = _macos_metadata_issues(members)
            if metadata_issues:
                details = "\n  - ".join(metadata_issues)
                raise ArchiveValidationError(
                    f"macOS metadata detected:\n  - {details}"
                )
            manifest = _read_manifest(archive)
    except (OSError, tarfile.TarError) as error:
        raise ArchiveValidationError(f"Invalid package archive {path}: {error}") from error

    package_name = manifest.get("name")
    package_version = manifest.get("version")
    if package_name != expected_name:
        raise ArchiveValidationError(
            f"Package name mismatch: expected {expected_name}, found {package_name}"
        )
    if package_version != expected_version:
        raise ArchiveValidationError(
            f"Package version mismatch: expected {expected_version}, found {package_version}"
        )
    if require_publishable and manifest.get("notForPublication") is True:
        raise ArchiveValidationError("package.json contains notForPublication: true")
    if require_publishable and str(manifest.get("url", "")).startswith("file://"):
        raise ArchiveValidationError("package.json contains a local file:// URL")

    return ArchiveSummary(
        path=path,
        package_name=package_name,
        package_version=package_version,
        sha256=_sha256(path),
        compressed_bytes=path.stat().st_size,
        uncompressed_bytes=sum(member.size for member in members),
        members=len(members),
        regular_files=sum(member.isfile() for member in members),
        directories=sum(member.isdir() for member in members),
        json_files=sum(
            member.isfile() and member.name.endswith(".json") for member in members
        ),
        macos_metadata=0,
    )


def prepare_archive(
    source: Path,
    output: Path,
    expected_name: str,
    expected_version: str,
) -> ArchiveSummary:
    source = Path(source)
    output = Path(output)
    inspect_archive(
        source,
        expected_name,
        expected_version,
        require_publishable=False,
    )

    output.parent.mkdir(parents=True, exist_ok=True)
    try:
        # A fixed gzip header (no file name, mtime 0) makes the same input yield the same bytes.
        with (
            tarfile.open(source, "r:gz") as source_archive,
            output.open("wb") as raw_output,
            gzip.GzipFile(filename="", mode="wb", fileobj=raw_output, mtime=0) as gzip_output,
            tarfile.open(fileobj=gzip_output, mode="w", format=tarfile.PAX_FORMAT) as output_archive,
        ):
            for source_member in source_archive.getmembers():
                output_member = copy.copy(source_member)
                file_object = source_archive.extractfile(source_member)
                content = file_object.read() if file_object is not None else None

                if source_member.name == MANIFEST_PATH:
                    manifest = json.loads(content.decode("utf-8"))
                    manifest.pop("notForPublication", None)
                    if str(manifest.get("url", "")).startswith("file://"):
                        manifest.pop("url")
                    content = (
                        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n"
                    ).encode("utf-8")
                    output_member.size = len(content)

                output_archive.addfile(
                    output_member,
                    io.BytesIO(content) if content is not None else None,
                )
    except (OSError, tarfile.TarError) as error:
        raise ArchiveValidationError(
            f"Could not prepare release archive {output}: {error}"
        ) from error

    return inspect_archive(output, expected_name, expected_version)


def compare_archives(expected: Path, actual: Path) -> tuple[str, str]:
    expected = Path(expected)
    actual = Path(actual)
    expected_digest = _sha256(expected)
    actual_digest = _sha256(actual)
    if expected_digest != actual_digest:
        raise ArchiveValidationError(
            "SHA-256 mismatch: "
            f"expected {expected_digest} for {expected}, "
            f"found {actual_digest} for {actual}"
        )
    return expected_digest, actual_digest


def print_summary(summary: ArchiveSummary) -> None:
    print(f"Package archive: {summary.path}")
    print(f"  Package: {summary.package_name}@{summary.package_version}")
    print(f"  SHA-256: {summary.sha256}")
    print(f"  Compressed bytes: {summary.compressed_bytes}")
    print(f"  Uncompressed bytes: {summary.uncompressed_bytes}")
    print(f"  Tar members: {summary.members}")
    print(f"  Regular files: {summary.regular_files}")
    print(f"  Directories: {summary.directories}")
    print(f"  JSON files: {summary.json_files}")
    print(f"  macOS metadata: {summary.macos_metadata}")


def _argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Prepare and validate canonical FHIR release archives"
    )
    commands = parser.add_subparsers(dest="command", required=True)

    prepare = commands.add_parser("prepare")
    prepare.add_argument("source", type=Path)
    prepare.add_argument("output", type=Path)
    prepare.add_argument("--name", required=True)
    prepare.add_argument("--version", required=True)

    inspect = commands.add_parser("inspect")
    inspect.add_argument("archive", type=Path)
    inspect.add_argument("--name", required=True)
    inspect.add_argument("--version", required=True)

    compare_command = commands.add_parser("compare")
    compare_command.add_argument("expected", type=Path)
    compare_command.add_argument("actual", type=Path)
    return parser


def main(argv=None) -> int:
    arguments = _argument_parser().parse_args(argv)
    try:
        if arguments.command == "prepare":
            summary = prepare_archive(
                arguments.source,
                arguments.output,
                arguments.name,
                arguments.version,
            )
            print_summary(summary)
        elif arguments.command == "inspect":
            summary = inspect_archive(
                arguments.archive,
                arguments.name,
                arguments.version,
            )
            print_summary(summary)
        else:
            expected_digest, actual_digest = compare_archives(
                arguments.expected, arguments.actual
            )
            print(f"GitHub SHA-256:    {expected_digest}")
            print(f"Simplifier SHA-256: {actual_digest}")
            print("Package archives are byte-identical")
    except ArchiveValidationError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
