#!/usr/bin/env python3

import base64
import contextlib
import errno
import json
import os
import platform
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

# Where Firely Terminal keeps its login, relative to the home directory.
MACOS_FIRELY_CONFIG = "Library/Application Support/Torinox"
LINUX_FIRELY_CONFIG = ".local/share/Torinox"
if platform.system() == "Darwin":
    FIRELY_CONFIG, OTHER_FIRELY_CONFIG = MACOS_FIRELY_CONFIG, LINUX_FIRELY_CONFIG
else:
    FIRELY_CONFIG, OTHER_FIRELY_CONFIG = LINUX_FIRELY_CONFIG, MACOS_FIRELY_CONFIG


def simplifier_token(expires_in):
    """Return an unsigned JWT shaped like the access tokens of api.simplifier.net."""

    def encode(part):
        return base64.urlsafe_b64encode(json.dumps(part).encode()).rstrip(b"=").decode()

    claims = {"aud": "api.simplifier.net", "exp": int(time.time()) + expires_in}
    return ".".join([encode({"alg": "HS256", "typ": "JWT"}), encode(claims), "signature"])


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
        # A home of its own keeps the developer's real Firely Terminal login out of reach.
        self.home = self.root / "home"
        self.home.mkdir()
        self.fhir_calls = self.root / "fhir-calls.log"
        self.write_curl_stub()
        self.write_fhir_stub()

    def tearDown(self):
        self.temporary_directory.cleanup()

    def write_stub(self, name, body):
        stub = self.bin_directory / name
        stub.write_text(textwrap.dedent(body).lstrip())
        stub.chmod(0o755)

    def write_curl_stub(self):
        self.write_stub(
            "curl",
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
            """,
        )

    def write_fhir_stub(self):
        # Firely Terminal stand-in: call N of `fhir login` saves the Nth token from
        # TEST_FHIR_TOKENS (or the last one) where Firely keeps its login on this
        # platform, and the stub fails when the test gives it no token.
        self.write_stub(
            "fhir",
            r"""
            #!/usr/bin/env bash
            printf '%s\n' "$*" >> "$TEST_FHIR_CALLS"
            read -r -a tokens <<< "${TEST_FHIR_TOKENS:-}"
            (( ${#tokens[@]} )) || { echo "No saved login" >&2; exit 1; }
            call=$(wc -l < "$TEST_FHIR_CALLS")
            index=$(( call <= ${#tokens[@]} ? call - 1 : ${#tokens[@]} - 1 ))
            mkdir -p "$HOME/$TEST_FIRELY_CONFIG"
            printf '{"Tokens": {"AccessToken": "%s", "RefreshToken": "refresh", "Valid": true}}' \
                "${tokens[$index]}" > "$HOME/$TEST_FIRELY_CONFIG/config.json"
            echo "Authentication successful. Token saved."
            """,
        )

    def write_firely_config(self, directory, token):
        config = self.home / directory
        config.mkdir(parents=True, exist_ok=True)
        (config / "config.json").write_text(json.dumps({"Tokens": {"AccessToken": token}}))

    def environment(self, credentials=None, ci=True, firely_tokens=()):
        # Inherited TEST_* variables would change what the stubs do.
        environment = {
            key: value for key, value in os.environ.items() if not key.startswith("TEST_")
        }
        for key in ("CI", "FHIR_EMAIL", "FHIR_PASSWORD", "SKIP_BUILD"):
            environment.pop(key, None)
        environment.update(
            {
                "HOME": str(self.home),
                "PATH": f"{self.bin_directory}:{environment['PATH']}",
                "TEST_CURL_ARGUMENTS": str(self.curl_arguments),
                "TEST_CURL_ENVIRONMENT": str(self.curl_environment),
                "TEST_TOKEN_BODY": str(self.token_body),
                "TEST_PROJECT_ZIP": str(self.project_zip),
                "TEST_FHIR_CALLS": str(self.fhir_calls),
                "TEST_FIRELY_CONFIG": FIRELY_CONFIG,
            }
        )
        if ci:
            environment["CI"] = "true"
        if credentials:
            environment["FHIR_EMAIL"], environment["FHIR_PASSWORD"] = credentials
        if firely_tokens:
            environment["TEST_FHIR_TOKENS"] = " ".join(firely_tokens)
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

    def bearer_tokens(self):
        return [
            line.split("Authorization: Bearer ", 1)[1].split()[0]
            for line in self.curl_arguments.read_text().splitlines()
            if "Authorization: Bearer " in line
        ]

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

    @contextlib.contextmanager
    def on_terminal(self, arguments, environment):
        """Run the script on a pseudo-terminal and always clean the process up."""
        terminal, script_side = pty.openpty()
        process = subprocess.Popen(
            ["bash", str(self.script), *arguments],
            cwd=self.root,
            env=environment,
            stdin=script_side,
            stdout=script_side,
            stderr=script_side,
        )
        os.close(script_side)
        try:
            yield terminal, process
        finally:
            if process.poll() is None:
                process.kill()
                process.wait()
            os.close(terminal)

    def run_interactive(self, environment, password=None):
        """Run backup mode on a pseudo-terminal, answering the login prompts if they come."""
        with self.on_terminal(["backup"], environment) as (terminal, process):
            transcript = b""
            if password is not None:
                transcript += self.read_terminal(terminal, process, until=b"Simplifier e-mail: ")
                os.write(terminal, b"typed@example.invalid\n")
                transcript += self.read_terminal(terminal, process, until=b"Simplifier password: ")
                # read -s discards input that is already waiting when it turns echo off,
                # so type the password only once echo is off, as a person would.
                self.wait_for_echo_off(terminal)
                os.write(terminal, password.encode() + b"\n")
            transcript += self.read_terminal(terminal, process)
            process.wait(timeout=10)
        return process.returncode, transcript

    def test_interactive_run_asks_for_missing_credentials(self):
        # Leading and trailing spaces are part of the password and must survive.
        password = "  typed secret  "

        returncode, transcript = self.run_interactive(self.environment(ci=False), password)

        self.assertEqual(0, returncode, transcript)
        self.assertEqual(
            {"Email": "typed@example.invalid", "Password": password},
            self.token_request(),
        )
        self.assertNotIn(password.strip().encode(), transcript)
        self.assert_password_kept_from_curl(password.strip())

    def test_interactive_run_reuses_the_firely_terminal_login(self):
        token = simplifier_token(expires_in=8 * 3600)

        returncode, transcript = self.run_interactive(
            self.environment(ci=False, firely_tokens=[token])
        )

        self.assertEqual(0, returncode, transcript)
        self.assertEqual(["login"], self.fhir_calls.read_text().splitlines())
        self.assertIn(b"Using the Firely Terminal login", transcript)
        self.assertNotIn(b"Simplifier e-mail", transcript)
        self.assertFalse(self.token_body.exists(), "no password login expected")
        self.assertEqual([token], self.bearer_tokens())

    def test_only_the_firely_config_of_this_platform_counts(self):
        # A config at the other platform's location may belong to another account.
        other_token = simplifier_token(expires_in=8 * 3600)
        self.write_firely_config(OTHER_FIRELY_CONFIG, other_token)
        token = simplifier_token(expires_in=7 * 3600)

        returncode, transcript = self.run_interactive(
            self.environment(ci=False, firely_tokens=[token])
        )

        self.assertEqual(0, returncode, transcript)
        self.assertEqual([token], self.bearer_tokens())

    def test_expired_firely_token_falls_back_to_the_prompt(self):
        # A valid token at the other platform's location must not be used instead.
        self.write_firely_config(OTHER_FIRELY_CONFIG, simplifier_token(expires_in=8 * 3600))
        environment = self.environment(
            ci=False, firely_tokens=[simplifier_token(expires_in=-60)]
        )

        returncode, transcript = self.run_interactive(environment, "secret")

        self.assertEqual(0, returncode, transcript)
        self.assertIn(b"No usable Firely Terminal login", transcript)
        self.assertEqual(
            {"Email": "typed@example.invalid", "Password": "secret"},
            self.token_request(),
        )
        self.assertEqual(["synthetic-token"], self.bearer_tokens())

    def test_sync_renews_the_firely_token_before_the_upload(self):
        # The token can run out while the upload confirmation waits for an answer.
        resources = self.root / "fsh-generated" / "resources"
        resources.mkdir(parents=True)
        (resources / "StructureDefinition-example.json").write_text(
            '{"resourceType":"StructureDefinition","id":"example"}'
        )
        (self.root / "sushi-config.yaml").write_text("version: 0.0.1\n")
        for name in ("package.json", "README.md", "CHANGELOG.md"):
            (self.root / name).write_text("{}\n")
        self.write_stub("docker", "#!/usr/bin/env bash\nexit 0\n")
        first, renewed = simplifier_token(8 * 3600), simplifier_token(7 * 3600)
        environment = self.environment(ci=False, firely_tokens=[first, renewed])
        environment["SKIP_BUILD"] = "true"

        with self.on_terminal([], environment) as (terminal, process):
            transcript = self.read_terminal(
                terminal, process, until=b"Upload to Simplifier.net? [y/N] "
            )
            self.write_firely_config(FIRELY_CONFIG, simplifier_token(expires_in=-60))
            os.write(terminal, b"y\n")
            transcript += self.read_terminal(terminal, process)
            process.wait(timeout=10)

        self.assertEqual(0, process.returncode, transcript)
        self.assertEqual(["login", "login"], self.fhir_calls.read_text().splitlines())
        self.assertEqual([first, renewed], self.bearer_tokens())
        self.assertIn("-X PUT", self.curl_arguments.read_text().splitlines()[-1])

    def test_environment_credentials_take_precedence_over_firely_terminal(self):
        environment = self.environment(
            credentials=("sync-test@example.invalid", "secret"),
            ci=False,
            firely_tokens=[simplifier_token(expires_in=8 * 3600)],
        )

        returncode, transcript = self.run_interactive(environment)

        self.assertEqual(0, returncode, transcript)
        self.assertFalse(self.fhir_calls.exists(), "fhir login must not run")
        self.assertEqual(
            {"Email": "sync-test@example.invalid", "Password": "secret"},
            self.token_request(),
        )

    def test_non_interactive_run_without_credentials_stops_before_any_request(self):
        # Both CI and a missing terminal must stop the run; fhir login could hang on a pipe.
        for ci in (True, False):
            with self.subTest(ci=ci):
                environment = self.environment(
                    ci=ci, firely_tokens=[simplifier_token(expires_in=8 * 3600)]
                )

                result = self.run_backup(environment)

                self.assertNotEqual(0, result.returncode, result.stdout)
                self.assertIn("FHIR_EMAIL", result.stderr)
                self.assertFalse(self.curl_arguments.exists())
                self.assertFalse(self.fhir_calls.exists(), "fhir login must not run")


if __name__ == "__main__":
    unittest.main()
