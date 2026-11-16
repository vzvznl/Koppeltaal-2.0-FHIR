#!/usr/bin/env python3

import importlib.util
import io
import json
import os
import subprocess
import sys
import tarfile
import tempfile
import textwrap
import unittest
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]
MODULE_PATH = REPOSITORY / "scripts" / "release_artifact.py"


class ReleaseArtifactTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)

    def tearDown(self):
        self.temporary_directory.cleanup()

    def load_module(self):
        self.assertTrue(
            MODULE_PATH.exists(),
            "scripts/release_artifact.py must implement release archive handling",
        )
        spec = importlib.util.spec_from_file_location("release_artifact", MODULE_PATH)
        module = importlib.util.module_from_spec(spec)
        sys.modules[spec.name] = module
        spec.loader.exec_module(module)
        return module

    def create_archive(self, path, files, pax_headers=None):
        pax_headers = pax_headers or {}
        with tarfile.open(path, "w:gz") as archive:
            for name, content in files.items():
                member = tarfile.TarInfo(name)
                member.size = len(content)
                member.mode = 0o644
                member.pax_headers = pax_headers.get(name, {})
                archive.addfile(member, io.BytesIO(content))

    def publishable_manifest(self):
        return json.dumps(
            {
                "name": "koppeltaalv2.00",
                "version": "9.8.7",
            }
        ).encode()

    def write_publishable_archive(self, path):
        self.create_archive(
            path,
            {
                "package/package.json": self.publishable_manifest(),
                "package/Patient-synthetic.json": (
                    b'{"resourceType":"Patient","id":"synthetic"}\n'
                ),
            },
        )

    def test_inspect_rejects_corrupt_gzip_checksum(self):
        release_artifact = self.load_module()
        archive_path = self.root / "corrupt-checksum.tgz"
        self.write_publishable_archive(archive_path)
        data = bytearray(archive_path.read_bytes())
        # The gzip trailer is the CRC-32 followed by the uncompressed size, 4 bytes each.
        data[-8] ^= 0xFF
        archive_path.write_bytes(bytes(data))

        with self.assertRaisesRegex(release_artifact.ArchiveValidationError, "gzip"):
            release_artifact.inspect_archive(archive_path, "koppeltaalv2.00", "9.8.7")

    def test_inspect_rejects_truncated_gzip_trailer(self):
        release_artifact = self.load_module()
        archive_path = self.root / "truncated.tgz"
        self.write_publishable_archive(archive_path)
        archive_path.write_bytes(archive_path.read_bytes()[:-8])

        with self.assertRaisesRegex(release_artifact.ArchiveValidationError, "gzip"):
            release_artifact.inspect_archive(archive_path, "koppeltaalv2.00", "9.8.7")

    def test_prepare_archive_is_reproducible(self):
        release_artifact = self.load_module()
        source = self.root / "publisher.tgz"
        self.write_publishable_archive(source)
        first = self.root / "first" / "koppeltaalv2-9.8.7.tgz"
        second = self.root / "second-name.tgz"

        release_artifact.prepare_archive(source, first, "koppeltaalv2.00", "9.8.7")
        release_artifact.prepare_archive(source, second, "koppeltaalv2.00", "9.8.7")

        self.assertEqual(first.read_bytes(), second.read_bytes())
        # Header bytes: ID1 ID2 CM FLG, then MTIME (4 bytes); FLG bit 0x08 marks a file name.
        header = first.read_bytes()[:8]
        self.assertEqual(0, header[3] & 0x08)
        self.assertEqual(b"\x00\x00\x00\x00", header[4:8])

    def test_prepare_archive_creates_publishable_package_without_changing_resource(self):
        release_artifact = self.load_module()
        source = self.root / "publisher.tgz"
        output = self.root / "koppeltaalv2-9.8.7.tgz"
        resource = b'{"resourceType":"Patient","id":"synthetic"}\n'
        self.create_archive(
            source,
            {
                "package/package.json": json.dumps(
                    {
                        "name": "koppeltaalv2.00",
                        "version": "9.8.7",
                        "notForPublication": True,
                        "url": "file:///src/output",
                    }
                ).encode(),
                "package/Patient-synthetic.json": resource,
            },
        )

        summary = release_artifact.prepare_archive(
            source, output, "koppeltaalv2.00", "9.8.7"
        )

        with tarfile.open(output, "r:gz") as archive:
            manifest = json.load(archive.extractfile("package/package.json"))
            actual_resource = archive.extractfile(
                "package/Patient-synthetic.json"
            ).read()
        self.assertNotIn("notForPublication", manifest)
        self.assertNotIn("url", manifest)
        self.assertEqual(resource, actual_resource)
        self.assertEqual(2, summary.regular_files)
        self.assertEqual(0, summary.macos_metadata)

    def test_rejects_appledouble_member(self):
        release_artifact = self.load_module()
        archive_path = self.root / "appledouble.tgz"
        self.create_archive(
            archive_path,
            {
                "package/package.json": self.publishable_manifest(),
                "package/._Patient-synthetic.json": b"AppleDouble",
                "package/Patient-synthetic.json": b'{"resourceType":"Patient"}\n',
            },
        )

        with self.assertRaisesRegex(
            release_artifact.ArchiveValidationError, "AppleDouble"
        ):
            release_artifact.inspect_archive(
                archive_path, "koppeltaalv2.00", "9.8.7"
            )

    def test_rejects_apple_xattr_pax_header(self):
        release_artifact = self.load_module()
        archive_path = self.root / "xattr.tgz"
        resource_path = "package/Patient-synthetic.json"
        self.create_archive(
            archive_path,
            {
                "package/package.json": self.publishable_manifest(),
                resource_path: b'{"resourceType":"Patient"}\n',
            },
            {
                resource_path: {
                    "LIBARCHIVE.xattr.com.apple.provenance": "synthetic"
                }
            },
        )

        with self.assertRaisesRegex(
            release_artifact.ArchiveValidationError, "extended attribute"
        ):
            release_artifact.inspect_archive(
                archive_path, "koppeltaalv2.00", "9.8.7"
            )

    def test_rejects_ds_store_member(self):
        release_artifact = self.load_module()
        archive_path = self.root / "ds-store.tgz"
        self.create_archive(
            archive_path,
            {
                "package/package.json": self.publishable_manifest(),
                "package/.DS_Store": b"synthetic Finder metadata",
            },
        )

        with self.assertRaisesRegex(
            release_artifact.ArchiveValidationError, "Finder metadata"
        ):
            release_artifact.inspect_archive(
                archive_path, "koppeltaalv2.00", "9.8.7"
            )

    def test_rejects_macosx_directory_member(self):
        release_artifact = self.load_module()
        archive_path = self.root / "macosx-directory.tgz"
        self.create_archive(
            archive_path,
            {
                "package/package.json": self.publishable_manifest(),
                "__MACOSX/package/metadata": b"synthetic metadata",
            },
        )

        with self.assertRaisesRegex(
            release_artifact.ArchiveValidationError, "macOS archive directory"
        ):
            release_artifact.inspect_archive(
                archive_path, "koppeltaalv2.00", "9.8.7"
            )

    def test_inspect_reports_archive_summary(self):
        release_artifact = self.load_module()
        archive_path = self.root / "summary.tgz"
        self.create_archive(
            archive_path,
            {
                "package/package.json": self.publishable_manifest(),
                "package/Patient-synthetic.json": b'{"resourceType":"Patient"}\n',
            },
        )

        summary = release_artifact.inspect_archive(
            archive_path, "koppeltaalv2.00", "9.8.7"
        )

        self.assertEqual("koppeltaalv2.00", summary.package_name)
        self.assertEqual("9.8.7", summary.package_version)
        self.assertEqual(64, len(summary.sha256))
        self.assertEqual(2, summary.members)
        self.assertEqual(2, summary.regular_files)
        self.assertEqual(0, summary.directories)
        self.assertEqual(2, summary.json_files)

    def test_inspect_rejects_wrong_package_version(self):
        release_artifact = self.load_module()
        archive_path = self.root / "wrong-version.tgz"
        self.create_archive(
            archive_path,
            {"package/package.json": self.publishable_manifest()},
        )

        with self.assertRaisesRegex(
            release_artifact.ArchiveValidationError,
            "expected 9.8.6, found 9.8.7",
        ):
            release_artifact.inspect_archive(
                archive_path, "koppeltaalv2.00", "9.8.6"
            )

    def test_inspect_rejects_non_object_manifest(self):
        release_artifact = self.load_module()
        archive_path = self.root / "array-manifest.tgz"
        self.create_archive(
            archive_path,
            {"package/package.json": b"[]"},
        )

        try:
            release_artifact.inspect_archive(
                archive_path, "koppeltaalv2.00", "9.8.7"
            )
        except Exception as error:
            self.assertIsInstance(
                error,
                release_artifact.ArchiveValidationError,
                f"Unexpected validation exception: {error!r}",
            )
            self.assertIn("JSON object", str(error))
        else:
            self.fail("Non-object package.json was accepted")

    def test_compare_archives_accepts_byte_identical_files(self):
        release_artifact = self.load_module()
        self.assertTrue(
            hasattr(release_artifact, "compare_archives"),
            "compare_archives must verify distribution channel identity",
        )
        expected = self.root / "github.tgz"
        actual = self.root / "simplifier.tgz"
        expected.write_bytes(b"same canonical archive")
        actual.write_bytes(b"same canonical archive")

        expected_digest, actual_digest = release_artifact.compare_archives(
            expected, actual
        )

        self.assertEqual(expected_digest, actual_digest)
        self.assertEqual(64, len(expected_digest))

    def test_compare_archives_rejects_different_files(self):
        release_artifact = self.load_module()
        self.assertTrue(
            hasattr(release_artifact, "compare_archives"),
            "compare_archives must verify distribution channel identity",
        )
        expected = self.root / "github.tgz"
        actual = self.root / "simplifier.tgz"
        expected.write_bytes(b"github archive")
        actual.write_bytes(b"simplifier archive")

        with self.assertRaisesRegex(
            release_artifact.ArchiveValidationError, "SHA-256 mismatch"
        ):
            release_artifact.compare_archives(expected, actual)


class ReleasePackageShellTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        self.bin_directory = self.root / "bin"
        self.bin_directory.mkdir()
        self.captured_upload = self.root / "captured-upload.tgz"
        self.fhir_log = self.root / "fhir.log"

    def tearDown(self):
        self.temporary_directory.cleanup()

    def config_value(self, key):
        prefix = f"{key}:"
        for line in (REPOSITORY / "sushi-config.yaml").read_text().splitlines():
            if line.startswith(prefix):
                return line.split(":", 1)[1].strip()
        self.fail(f"Missing {key} in sushi-config.yaml")

    def write_executable(self, name, content):
        path = self.bin_directory / name
        path.write_text(textwrap.dedent(content))
        path.chmod(0o755)

    def create_canonical_archive(self, path, package_name, package_version):
        files = {
            "package/package.json": json.dumps(
                {
                    "name": package_name,
                    "version": package_version,
                }
            ).encode(),
            "package/Patient-synthetic.json": (
                b'{"resourceType":"Patient","id":"synthetic"}\n'
            ),
        }
        with tarfile.open(path, "w:gz") as archive:
            for name, content in files.items():
                member = tarfile.TarInfo(name)
                member.size = len(content)
                member.mode = 0o644
                archive.addfile(member, io.BytesIO(content))

    def install_release_stubs(self):
        self.write_executable(
            "curl",
            r"""
            #!/usr/bin/env bash
            set -euo pipefail
            printf '%s\n' "$*" >> "$TEST_CURL_LOG"
            output=""
            url=""
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -o|--output)
                        output="$2"
                        shift 2
                        ;;
                    --retry|--max-time|--connect-timeout)
                        shift 2
                        ;;
                    -*)
                        shift
                        ;;
                    *)
                        url="$1"
                        shift
                        ;;
                esac
            done
            if [[ "$url" == "https://packages.simplifier.net/koppeltaalv2.00" ]]; then
                printf '%s\n' '{"versions":{"0.16.3":{}}}'
            elif [[ -n "$output" ]]; then
                cp "$TEST_CANONICAL_ARCHIVE" "$output"
            else
                printf 'Unexpected curl request: %s\n' "$url" >&2
                exit 1
            fi
            """,
        )
        self.write_executable(
            "fhir",
            r"""
            #!/usr/bin/env bash
            set -euo pipefail
            printf '%s\n' "$1" >> "$TEST_FHIR_LOG"
            case "$1" in
                login)
                    exit 0
                    ;;
                publish-package)
                    cp "$2" "$TEST_CAPTURED_UPLOAD"
                    exit 0
                    ;;
                *)
                    printf 'Unexpected fhir command: %s\n' "$1" >&2
                    exit 1
                    ;;
            esac
            """,
        )

    def run_release_script(self, canonical):
        environment = os.environ.copy()
        environment.update(
            {
                "CI": "true",
                "FHIR_EMAIL": "release-test@example.invalid",
                "FHIR_PASSWORD": "synthetic-password",
                "PATH": f"{self.bin_directory}:{environment['PATH']}",
                "TEST_CANONICAL_ARCHIVE": str(canonical),
                "TEST_CAPTURED_UPLOAD": str(self.captured_upload),
                "TEST_CURL_LOG": str(self.root / "curl.log"),
                "TEST_FHIR_LOG": str(self.fhir_log),
            }
        )
        return subprocess.run(
            ["bash", str(REPOSITORY / "scripts/release_package.sh")],
            cwd=REPOSITORY,
            env=environment,
            text=True,
            capture_output=True,
        )

    def test_uploads_exact_github_release_asset(self):
        package_name = self.config_value("id")
        package_version = self.config_value("version")
        canonical = self.root / f"koppeltaalv2-{package_version}.tgz"
        self.create_canonical_archive(canonical, package_name, package_version)
        self.install_release_stubs()

        result = self.run_release_script(canonical)

        self.assertEqual(0, result.returncode, result.stderr)
        self.assertTrue(self.captured_upload.exists())
        self.assertEqual(canonical.read_bytes(), self.captured_upload.read_bytes())
        self.assertIn("GitHub asset", result.stdout)
        self.assertIn("SHA-256", result.stdout)

    def test_corrupt_github_asset_stops_before_login(self):
        package_name = self.config_value("id")
        package_version = self.config_value("version")
        canonical = self.root / f"koppeltaalv2-{package_version}.tgz"
        self.create_canonical_archive(canonical, package_name, package_version)
        canonical.write_bytes(canonical.read_bytes()[:-8])
        self.install_release_stubs()

        result = self.run_release_script(canonical)

        self.assertNotEqual(0, result.returncode, result.stdout)
        self.assertFalse(self.captured_upload.exists())
        fhir_calls = self.fhir_log.read_text().split() if self.fhir_log.exists() else []
        self.assertEqual([], fhir_calls)

    def test_make_publish_delegates_to_canonical_release_script(self):
        result = subprocess.run(
            ["make", "-n", "publish"],
            cwd=REPOSITORY,
            text=True,
            capture_output=True,
        )

        self.assertEqual(0, result.returncode, result.stderr)
        self.assertIn("./scripts/release_package.sh", result.stdout)
        self.assertNotIn("fhir pack", result.stdout)
        self.assertNotIn("fhir publish-package", result.stdout)


if __name__ == "__main__":
    unittest.main()
