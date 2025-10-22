#!/usr/bin/env python3
"""
Upload or update ImplementationGuide to FHIR server

NOTE: The ImplementationGuide is typically installed as part of the FHIR package
installation process. This script is provided for manual upload when needed, but
may fail validation on strict FHIR servers due to IG-specific parameter codes.

Usage: python3 upload-implementation-guide.py <fhir_base_url> [bearer_token]

Parameters:
  fhir_base_url - The base URL of the FHIR server
  bearer_token  - Optional Bearer token for authentication

Examples:
  python3 upload-implementation-guide.py http://localhost:8080/fhir/DEFAULT
  python3 upload-implementation-guide.py https://staging-fhir-server.koppeltaal.headease.nl/fhir/DEFAULT
  python3 upload-implementation-guide.py https://prod.example.com/fhir/DEFAULT "eyJhbGciOi..."

Troubleshooting:
  If upload fails due to validation errors, the ImplementationGuide should be
  installed via the package installation process instead of this script.
"""

import sys
import json
import urllib.request
import urllib.error
from pathlib import Path

# ANSI color codes
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

IG_SOURCE_PATH = 'fsh-generated/resources/ImplementationGuide-koppeltaalv2.00.json'


def load_implementation_guide() -> dict:
    """Load ImplementationGuide from generated resources"""
    ig_path = Path(IG_SOURCE_PATH)

    if not ig_path.exists():
        print(f"{RED}Error: ImplementationGuide not found at {IG_SOURCE_PATH}{NC}")
        print(f"{YELLOW}Run the IG publisher first to generate the ImplementationGuide{NC}")
        sys.exit(1)

    with open(ig_path, 'r') as f:
        ig = json.load(f)

    return ig


def check_existing_ig(fhir_base_url: str, ig_id: str, bearer_token: str = None) -> dict:
    """Check if ImplementationGuide already exists on server"""
    query_url = f"{fhir_base_url}/ImplementationGuide/{ig_id}"
    headers = {'Accept': 'application/fhir+json'}

    if bearer_token:
        headers['Authorization'] = f'Bearer {bearer_token}'

    req = urllib.request.Request(query_url, headers=headers)

    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        else:
            raise


def upload_implementation_guide(fhir_base_url: str, ig: dict, bearer_token: str = None) -> dict:
    """Upload or update ImplementationGuide using PUT"""
    ig_id = ig['id']
    put_url = f"{fhir_base_url}/ImplementationGuide/{ig_id}"

    headers = {
        'Content-Type': 'application/fhir+json',
        'Accept': 'application/fhir+json'
    }

    if bearer_token:
        headers['Authorization'] = f'Bearer {bearer_token}'

    data = json.dumps(ig).encode('utf-8')
    req = urllib.request.Request(put_url, data=data, headers=headers, method='PUT')

    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result
    except urllib.error.URLError as e:
        print(f"{RED}Error uploading ImplementationGuide: {e}{NC}")
        if hasattr(e, 'read'):
            error_body = e.read().decode('utf-8')
            try:
                error_json = json.loads(error_body)
                if error_json.get('resourceType') == 'OperationOutcome':
                    for issue in error_json.get('issue', []):
                        print(f"{RED}  {issue.get('severity', 'error')}: {issue.get('diagnostics', 'Unknown error')}{NC}")
            except:
                print(f"{RED}  {error_body}{NC}")
        sys.exit(1)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    fhir_base_url = sys.argv[1]
    bearer_token = sys.argv[2] if len(sys.argv) > 2 else None

    print(f"{BLUE}═══════════════════════════════════════════════════════════{NC}")
    print(f"{BLUE}  Upload ImplementationGuide to FHIR Server{NC}")
    print(f"{BLUE}═══════════════════════════════════════════════════════════{NC}")
    print(f"FHIR Server:      {fhir_base_url}")
    print(f"Authentication:   {'Bearer token provided' if bearer_token else 'No token (public access)'}")
    print(f"{BLUE}═══════════════════════════════════════════════════════════{NC}")
    print()

    # Load ImplementationGuide from generated resources
    print(f"{BLUE}Loading ImplementationGuide from {IG_SOURCE_PATH}...{NC}")
    ig = load_implementation_guide()
    ig_id = ig['id']
    ig_version = ig['version']
    ig_url = ig['url']

    print(f"  ID:      {ig_id}")
    print(f"  Version: {ig_version}")
    print(f"  URL:     {ig_url}")
    print()

    # Check if ImplementationGuide already exists
    print(f"{BLUE}Checking if ImplementationGuide exists on server...{NC}")
    existing_ig = check_existing_ig(fhir_base_url, ig_id, bearer_token)

    if existing_ig:
        existing_version = existing_ig.get('version', 'unknown')
        print(f"{YELLOW}  Found existing ImplementationGuide with version {existing_version}{NC}")

        if existing_version == ig_version:
            print(f"{GREEN}  ✓ Same version - updating anyway to ensure consistency{NC}")
        else:
            print(f"{YELLOW}  ⚠ Different version - updating from {existing_version} to {ig_version}{NC}")
    else:
        print(f"{YELLOW}  ImplementationGuide not found - will create new{NC}")

    print()

    # Upload/update ImplementationGuide
    print(f"{BLUE}Uploading ImplementationGuide...{NC}")
    result = upload_implementation_guide(fhir_base_url, ig, bearer_token)

    print(f"{GREEN}✅ Successfully uploaded ImplementationGuide{NC}")
    print(f"  Resource ID: {result.get('id', 'unknown')}")
    print(f"  Version:     {result.get('version', 'unknown')}")

    print()
    print(f"{BLUE}═══════════════════════════════════════════════════════════{NC}")


if __name__ == '__main__':
    main()
