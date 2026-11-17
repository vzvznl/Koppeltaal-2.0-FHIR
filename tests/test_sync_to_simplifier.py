#!/usr/bin/env python3

import errno
import json
import os
import pty
import select
import shutil
import subprocess
import tempfile
import termios
import textwrap
import time
import unittest
import zipfile
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]
SCRIPT = REPOSITORY / "scripts" / "sync_to_simplifier.sh"


class SyncCredentialTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        # The script derives its project root from its own location, so running a
        # copy keeps backups and work directories out of the repository.
        (self.root / "scripts").mkdir()
        self.script = self.root / "scripts" / SCRIPT.name
        shutil.copy(SCRIPT, self.script)
        self.bin_directory = self.root / "bin"
        self.bin_directory.mkdir()
        self.curl_arguments = self.root / "curl-arguments.log"
        self.curl_environment = self.root / "curl-environment.log"
        self.token_body = self.root / "token-body.json"
        self.project_zip = self.root / "project.zip"
        with zipfile.ZipFile(self.project_zip, "w") as archive:
            archive.writestr("resources/Patient-example.json", '{"resourceType":"Patient"}')
        self.write_curl_stub()

    def tearDown(self):
        self.temporary_directory.cleanup()

    def write_curl_stub(self):
        stub = self.bin_directory / "curl"
        stub.write_text(
            textwrap.dedent(
                r"""
                #!/usr/bin/env bash
                set -euo pipefail
                printf '%s\n' "$*" >> "$TEST_CURL_ARGUMENTS"
                printf '%s\n' "${FHIR_PASSWORD+password-in-environment}" >> "$TEST_CURL_ENVIRONMENT"
                output=""
                write_out=""
                url=""
                while [[ $# -gt 0 ]]; do
                    case "$1" in
                        -o|--output) output="$2"; shift 2 ;;
                        -w|--write-out) write_out="$2"; shift 2 ;;
                        -X|-H|--header|-d|--data|--data-binary|--connect-timeout|--max-time) shift 2 ;;
                        -*) shift ;;
                        *) url="$1"; shift ;;
                    esac
                done
                case "$url" in
                    */token)
                        cat > "$TEST_TOKEN_BODY"
                        printf '%s\n' '{"token":"synthetic-token"}'
                        exit "${TEST_TOKEN_EXIT:-0}"
                        ;;
                    */zip)
                        cp "$TEST_PROJECT_ZIP" "$output"
                        [[ -n "$write_out" ]] && printf '200'
                        ;;
                    *)
                        printf 'Unexpected curl request: %s\n' "$url" >&2
                        exit 1
                        ;;
                esac
                """
            ).lstrip()
        )
        stub.chmod(0o755)

    def environment(self, credentials=None, ci=True):
        environment = os.environ.copy()
        for key in ("CI", "FHIR_EMAIL", "FHIR_PASSWORD"):
            environment.pop(key, None)
        environment.update(
            {
                "PATH": f"{self.bin_directory}:{environment['PATH']}",
                "TEST_CURL_ARGUMENTS": str(self.curl_arguments),
                "TEST_CURL_ENVIRONMENT": str(self.curl_environment),
                "TEST_TOKEN_BODY": str(self.token_body),
                "TEST_PROJECT_ZIP": str(self.project_zip),
            }
        )
        if ci:
            environment["CI"] = "true"
        if credentials:
            environment["FHIR_EMAIL"], environment["FHIR_PASSWORD"] = credentials
        return environment

    def run_backup(self, environment):
        return subprocess.run(
            ["bash", str(self.script), "backup"],
            cwd=self.root,
            env=environment,
            stdin=subprocess.DEVNULL,
            text=True,
            capture_output=True,
        )

    def token_request(self):
        return json.loads(self.token_body.read_text())

    def assert_password_kept_from_curl(self, password):
        self.assertNotIn(password, self.curl_arguments.read_text())
        self.assertNotIn("password-in-environment", self.curl_environment.read_text())

    def test_token_request_sends_credentials_through_stdin(self):
        # Quotes and backslashes broke the hand-built JSON body.
        password = 'pa"ss\\word'

        result = self.run_backup(self.environment(("sync-test@example.invalid", password)))

        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual(
            {"Email": "sync-test@example.invalid", "Password": password},
            self.token_request(),
        )
        self.assert_password_kept_from_curl(password)

    def test_failed_token_request_stops_even_after_printing_a_token(self):
        environment = self.environment(("sync-test@example.invalid", "secret"))
        environment["TEST_TOKEN_EXIT"] = "28"

        result = self.run_backup(environment)

        self.assertNotEqual(0, result.returncode, result.stdout)
        self.assertIn("Authentication failed", result.stderr)
        self.assertNotIn("/zip", self.curl_arguments.read_text())

    def read_terminal(self, terminal, process, until=None, timeout=60):
        seen = b""
        deadline = time.monotonic() + timeout
        while until is None or until not in seen:
            if time.monotonic() > deadline:
                self.fail(f"Timed out waiting for {until!r}; terminal showed {seen!r}")
            ready, _, _ = select.select([terminal], [], [], 0.2)
            chunk = b""
            if ready:
                try:
                    chunk = os.read(terminal, 1024)
                except OSError as error:
                    # Linux reports EIO once the script has closed its side of the terminal.
                    if error.errno != errno.EIO:
                        raise
            seen += chunk
            if not chunk and process.poll() is not None:
                break
        return seen

    def wait_for_echo_off(self, terminal, timeout=30):
        deadline = time.monotonic() + timeout
        while termios.tcgetattr(terminal)[3] & termios.ECHO:
            if time.monotonic() > deadline:
                self.fail("The password prompt never turned off terminal echo")
            time.sleep(0.05)

    def test_interactive_run_asks_for_missing_credentials(self):
        # Leading and trailing spaces are part of the password and must survive.
        password = "  typed secret  "
        terminal, script_side = pty.openpty()
        process = subprocess.Popen(
            ["bash", str(self.script), "backup"],
            cwd=self.root,
            env=self.environment(ci=False),
            stdin=script_side,
            stdout=script_side,
            stderr=script_side,
        )
        os.close(script_side)
        try:
            transcript = self.read_terminal(terminal, process, until=b"Simplifier e-mail: ")
            os.write(terminal, b"typed@example.invalid\n")
            transcript += self.read_terminal(terminal, process, until=b"Simplifier password: ")
            # read -s discards input that is already waiting when it turns echo off,
            # so type the password only once echo is off, as a person would.
            self.wait_for_echo_off(terminal)
            os.write(terminal, password.encode() + b"\n")
            transcript += self.read_terminal(terminal, process)
            process.wait(timeout=10)
        finally:
            if process.poll() is None:
                process.kill()
                process.wait()
            os.close(terminal)

        self.assertEqual(0, process.returncode, transcript)
        self.assertEqual(
            {"Email": "typed@example.invalid", "Password": password},
            self.token_request(),
        )
        self.assertNotIn(password.strip().encode(), transcript)
        self.assert_password_kept_from_curl(password.strip())

    def test_non_interactive_run_without_credentials_stops_before_any_request(self):
        result = self.run_backup(self.environment())

        self.assertNotEqual(0, result.returncode, result.stdout)
        self.assertIn("FHIR_EMAIL", result.stderr)
        self.assertFalse(self.curl_arguments.exists())


if __name__ == "__main__":
    unittest.main()
