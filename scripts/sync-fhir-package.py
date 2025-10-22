#!/usr/bin/env python3
"""
Synchronize FHIR package resources to a HAPI FHIR server

This script downloads a FHIR package (.tgz) and synchronizes all resources to a
FHIR server, ensuring that:
- Resources exist with the correct ID (matching the package)
- No duplicate versions exist (same canonical URL, different version)
- No duplicate IDs exist (same canonical URL, different resource ID)

Usage: python3 sync-fhir-package.py <command> <fhir_base_url> <package_url> [bearer_token]

Commands:
  detect - Detect discrepancies between package and server
  sync   - Synchronize package resources to server (removes duplicates, PUTs resources)

Parameters:
  fhir_base_url - The base URL of the FHIR server (e.g., http://localhost:8080/fhir/DEFAULT)
  package_url   - URL to the FHIR package .tgz file
  bearer_token  - Optional Bearer token for authentication

Examples:
  python3 sync-fhir-package.py detect http://localhost:8080/fhir/DEFAULT https://github.com/vzvznl/Koppeltaal-2.0-FHIR/releases/download/v0.15.0-beta.6b/koppeltaalv2-0.15.0-beta.6b.tgz
  python3 sync-fhir-package.py sync https://staging-fhir-server.koppeltaal.headease.nl/fhir/DEFAULT https://github.com/.../koppeltaalv2-0.15.0-beta.6b.tgz "eyJhbGci..."
"""

import sys
import json
import urllib.request
import urllib.error
import tarfile
import tempfile
import os
import shutil
from typing import List, Dict, Tuple, Optional

# ANSI color codes
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color


def download_package(package_url: str, temp_dir: str) -> str:
    """Download package .tgz file to temp directory"""
    print(f"{BLUE}Downloading package from {package_url}...{NC}")

    package_path = os.path.join(temp_dir, 'package.tgz')

    try:
        req = urllib.request.Request(package_url)
        with urllib.request.urlopen(req) as response:
            with open(package_path, 'wb') as f:
                f.write(response.read())

        print(f"{GREEN}✓ Downloaded package{NC}")
        return package_path
    except Exception as e:
        print(f"{RED}Error downloading package: {e}{NC}")
        sys.exit(1)


def extract_package(package_path: str, temp_dir: str) -> str:
    """Extract package .tgz file"""
    print(f"{BLUE}Extracting package...{NC}")

    extract_dir = os.path.join(temp_dir, 'package')
    os.makedirs(extract_dir, exist_ok=True)

    try:
        with tarfile.open(package_path, 'r:gz') as tar:
            tar.extractall(extract_dir)

        print(f"{GREEN}✓ Extracted package{NC}")
        return extract_dir
    except Exception as e:
        print(f"{RED}Error extracting package: {e}{NC}")
        sys.exit(1)


def load_package_resources(package_dir: str) -> List[Dict]:
    """Load all conformance resources from package/package directory"""
    resources = []
    package_subdir = os.path.join(package_dir, 'package')

    if not os.path.exists(package_subdir):
        print(f"{RED}Error: package/package directory not found in extracted archive{NC}")
        sys.exit(1)

    # Resource types we care about
    resource_types = ['StructureDefinition', 'CodeSystem', 'ValueSet', 'SearchParameter',
                     'NamingSystem', 'ImplementationGuide']

    for filename in os.listdir(package_subdir):
        if not filename.endswith('.json'):
            continue

        filepath = os.path.join(package_subdir, filename)
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                resource = json.load(f)

            if resource.get('resourceType') in resource_types:
                resources.append(resource)
        except Exception as e:
            print(f"{YELLOW}Warning: Could not load {filename}: {e}{NC}")

    print(f"{GREEN}✓ Loaded {len(resources)} resources from package{NC}")
    return resources


def query_server_resource_by_url(fhir_base_url: str, resource_type: str, url: str, bearer_token: str = None) -> Dict:
    """Query FHIR server for resource by canonical URL"""
    query_url = f"{fhir_base_url}/{resource_type}?url={urllib.parse.quote(url)}"
    headers = {'Accept': 'application/fhir+json'}

    if bearer_token:
        headers['Authorization'] = f'Bearer {bearer_token}'

    req = urllib.request.Request(query_url, headers=headers)

    try:
        with urllib.request.urlopen(req) as response:
            bundle = json.loads(response.read().decode('utf-8'))
            return bundle
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return {'total': 0, 'entry': []}
        else:
            print(f"{RED}Error querying {resource_type}?url={url}: {e}{NC}")
            return {'total': 0, 'entry': []}


def delete_resource(fhir_base_url: str, resource_type: str, resource_id: str, bearer_token: str = None) -> bool:
    """Delete a resource from the FHIR server"""
    delete_url = f"{fhir_base_url}/{resource_type}/{resource_id}"
    headers = {}

    if bearer_token:
        headers['Authorization'] = f'Bearer {bearer_token}'

    req = urllib.request.Request(delete_url, headers=headers, method='DELETE')

    try:
        with urllib.request.urlopen(req) as response:
            return True
    except Exception as e:
        print(f"{RED}Error deleting {resource_type}/{resource_id}: {e}{NC}")
        return False


def put_resource(fhir_base_url: str, resource: Dict, bearer_token: str = None) -> bool:
    """PUT a resource to the FHIR server (create or update)"""
    resource_type = resource['resourceType']
    resource_id = resource['id']
    put_url = f"{fhir_base_url}/{resource_type}/{resource_id}"

    headers = {
        'Content-Type': 'application/fhir+json',
        'Accept': 'application/fhir+json'
    }

    if bearer_token:
        headers['Authorization'] = f'Bearer {bearer_token}'

    # Remove meta fields that might cause conflicts
    resource_copy = resource.copy()
    if 'meta' in resource_copy:
        # Keep only versionId for updates if present
        meta = resource_copy['meta']
        resource_copy['meta'] = {k: v for k, v in meta.items() if k in ['versionId']}
        if not resource_copy['meta']:
            del resource_copy['meta']

    data = json.dumps(resource_copy).encode('utf-8')
    req = urllib.request.Request(put_url, data=data, headers=headers, method='PUT')

    try:
        with urllib.request.urlopen(req) as response:
            return True
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        try:
            error_json = json.loads(error_body)
            if error_json.get('resourceType') == 'OperationOutcome':
                print(f"{RED}Error uploading {resource_type}/{resource_id}:{NC}")
                for issue in error_json.get('issue', []):
                    print(f"  {issue.get('severity', 'error')}: {issue.get('diagnostics', 'Unknown error')}")
        except:
            print(f"{RED}Error uploading {resource_type}/{resource_id}: {error_body}{NC}")
        return False


def detect_discrepancies(fhir_base_url: str, resources: List[Dict], bearer_token: str = None) -> Tuple[List, List, List]:
    """
    Detect discrepancies between package and server

    Returns:
        - resources_to_delete: List of (resource_type, resource_id, canonical_url, version, reason)
        - resources_to_put: List of resource dicts
        - missing_resources: List of (resource_type, canonical_url, expected_id)
    """
    resources_to_delete = []
    resources_to_put = []
    missing_resources = []

    print(f"\n{BLUE}{'='*70}{NC}")
    print(f"{BLUE}Detecting Discrepancies{NC}")
    print(f"{BLUE}{'='*70}{NC}\n")

    for resource in resources:
        resource_type = resource['resourceType']
        canonical_url = resource.get('url')
        expected_id = resource.get('id')
        expected_version = resource.get('version')

        if not canonical_url:
            continue

        # Query server for this canonical URL
        bundle = query_server_resource_by_url(fhir_base_url, resource_type, canonical_url, bearer_token)

        if bundle['total'] == 0:
            # Resource missing on server
            missing_resources.append((resource_type, canonical_url, expected_id))
            resources_to_put.append(resource)
            print(f"{YELLOW}✗ {resource_type}/{expected_id}{NC}")
            print(f"  Canonical: {canonical_url}")
            print(f"  Status: MISSING on server")
            print()
        elif bundle['total'] == 1:
            # Single resource found - check if ID and version match
            server_resource = bundle['entry'][0]['resource']
            server_id = server_resource['id']
            server_version = server_resource.get('version')

            if server_id != expected_id:
                # Wrong ID - need to delete old and PUT new
                resources_to_delete.append((resource_type, server_id, canonical_url, server_version,
                                           f"Wrong ID (expected {expected_id}, found {server_id})"))
                resources_to_put.append(resource)
                print(f"{YELLOW}✗ {resource_type}/{expected_id}{NC}")
                print(f"  Canonical: {canonical_url}")
                print(f"  Status: WRONG ID (server has {server_id})")
                print(f"  Action: DELETE {server_id}, PUT {expected_id}")
                print()
            elif server_version != expected_version:
                # Wrong version - need to update
                resources_to_put.append(resource)
                print(f"{YELLOW}⚠ {resource_type}/{expected_id}{NC}")
                print(f"  Canonical: {canonical_url}")
                print(f"  Status: WRONG VERSION (server has {server_version}, expected {expected_version})")
                print(f"  Action: PUT {expected_id}")
                print()
            else:
                # Everything matches
                print(f"{GREEN}✓ {resource_type}/{expected_id}{NC}")
                print(f"  Canonical: {canonical_url}")
                print(f"  Status: OK (version {expected_version})")
                print()
        else:
            # Multiple resources found - duplicates!
            print(f"{RED}✗ {resource_type}/{expected_id}{NC}")
            print(f"  Canonical: {canonical_url}")
            print(f"  Status: DUPLICATES ({bundle['total']} found)")

            for entry in bundle['entry']:
                server_resource = entry['resource']
                server_id = server_resource['id']
                server_version = server_resource.get('version')

                if server_id == expected_id and server_version == expected_version:
                    # This is the correct one - keep it
                    print(f"    ✓ Keep {server_id} (version {server_version})")
                else:
                    # This is a duplicate - mark for deletion
                    reason = []
                    if server_id != expected_id:
                        reason.append(f"wrong ID {server_id}")
                    if server_version != expected_version:
                        reason.append(f"wrong version {server_version}")

                    resources_to_delete.append((resource_type, server_id, canonical_url, server_version,
                                               ', '.join(reason)))
                    print(f"    ✗ Delete {server_id} (version {server_version}) - {', '.join(reason)}")

            # Make sure we PUT the correct resource
            resources_to_put.append(resource)
            print()

    return resources_to_delete, resources_to_put, missing_resources


def sync_resources(fhir_base_url: str, resources_to_delete: List, resources_to_put: List, bearer_token: str = None):
    """Synchronize resources to server"""
    print(f"\n{BLUE}{'='*70}{NC}")
    print(f"{BLUE}Synchronizing Resources{NC}")
    print(f"{BLUE}{'='*70}{NC}\n")

    # Step 1: Delete resources
    if resources_to_delete:
        print(f"{YELLOW}Deleting {len(resources_to_delete)} duplicate/incorrect resources...{NC}\n")

        for resource_type, resource_id, canonical_url, version, reason in resources_to_delete:
            print(f"  Deleting {resource_type}/{resource_id} ({reason})...")
            if delete_resource(fhir_base_url, resource_type, resource_id, bearer_token):
                print(f"    {GREEN}✓ Deleted{NC}")
            else:
                print(f"    {RED}✗ Failed{NC}")
        print()

    # Step 2: PUT resources
    if resources_to_put:
        print(f"{BLUE}Uploading {len(resources_to_put)} resources...{NC}\n")

        success_count = 0
        fail_count = 0

        for resource in resources_to_put:
            resource_type = resource['resourceType']
            resource_id = resource['id']
            version = resource.get('version', 'unknown')

            print(f"  Uploading {resource_type}/{resource_id} (version {version})...")
            if put_resource(fhir_base_url, resource, bearer_token):
                print(f"    {GREEN}✓ Uploaded{NC}")
                success_count += 1
            else:
                print(f"    {RED}✗ Failed{NC}")
                fail_count += 1

        print()
        print(f"{GREEN}✓ Successfully uploaded: {success_count}{NC}")
        if fail_count > 0:
            print(f"{RED}✗ Failed: {fail_count}{NC}")


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]
    fhir_base_url = sys.argv[2]
    package_url = sys.argv[3]
    bearer_token = sys.argv[4] if len(sys.argv) > 4 else None

    if command not in ['detect', 'sync']:
        print(f"{RED}Error: Invalid command '{command}'. Use 'detect' or 'sync'{NC}")
        sys.exit(1)

    print(f"{BLUE}{'='*70}{NC}")
    print(f"{BLUE}  FHIR Package Synchronization{NC}")
    print(f"{BLUE}{'='*70}{NC}")
    print(f"Command:          {command}")
    print(f"FHIR Server:      {fhir_base_url}")
    print(f"Package URL:      {package_url}")
    print(f"Authentication:   {'Bearer token provided' if bearer_token else 'No token (public access)'}")
    print(f"{BLUE}{'='*70}{NC}\n")

    # Create temp directory
    temp_dir = tempfile.mkdtemp(prefix='fhir-package-sync-')

    try:
        # Download and extract package
        package_path = download_package(package_url, temp_dir)
        extract_dir = extract_package(package_path, temp_dir)

        # Load resources from package
        resources = load_package_resources(extract_dir)

        # Detect discrepancies
        resources_to_delete, resources_to_put, missing_resources = detect_discrepancies(
            fhir_base_url, resources, bearer_token
        )

        # Print summary
        print(f"{BLUE}{'='*70}{NC}")
        print(f"{BLUE}Summary{NC}")
        print(f"{BLUE}{'='*70}{NC}")
        print(f"Resources in package:     {len(resources)}")
        print(f"Resources to delete:      {len(resources_to_delete)}")
        print(f"Resources to upload:      {len(resources_to_put)}")
        print(f"Missing resources:        {len(missing_resources)}")
        print(f"{BLUE}{'='*70}{NC}\n")

        if command == 'sync':
            if resources_to_delete or resources_to_put:
                # Ask for confirmation
                response = input(f"{YELLOW}Proceed with synchronization? (yes/no): {NC}")
                if response.lower() in ['yes', 'y']:
                    sync_resources(fhir_base_url, resources_to_delete, resources_to_put, bearer_token)
                    print(f"\n{GREEN}✓ Synchronization complete{NC}")
                else:
                    print(f"\n{YELLOW}Synchronization cancelled{NC}")
            else:
                print(f"{GREEN}✓ Server is already in sync with package{NC}")

    finally:
        # Cleanup temp directory
        shutil.rmtree(temp_dir, ignore_errors=True)


if __name__ == '__main__':
    main()
