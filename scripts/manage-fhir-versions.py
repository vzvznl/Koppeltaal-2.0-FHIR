#!/usr/bin/env python3
"""
Manage FHIR resource versions on a HAPI FHIR server

Usage: python3 manage-fhir-versions.py <command> <fhir_base_url>

Commands:
  detect - Detect unexpected versions of profiles
  clean  - Remove old/unexpected versions (interactive confirmation)
  list   - List all versions of Koppeltaal profiles

Examples:
  python3 manage-fhir-versions.py detect http://localhost:8080/fhir/DEFAULT
  python3 manage-fhir-versions.py clean https://staging-fhir-server.koppeltaal.headease.nl/fhir/DEFAULT
  python3 manage-fhir-versions.py list http://localhost:8080/fhir/DEFAULT
"""

import sys
import json
import urllib.request
import urllib.error
import re
import os
import glob
from typing import List, Dict, Tuple, Optional

# ANSI color codes
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color


def get_canonical_base() -> str:
    """Get canonical base URL from sushi-config.yaml"""
    try:
        with open('sushi-config.yaml', 'r') as f:
            for line in f:
                if line.startswith('canonical:'):
                    return line.split(':', 1)[1].strip()
    except FileNotFoundError:
        pass
    return "http://koppeltaal.nl/fhir"  # Default fallback


def parse_fsh_canonical_url(file_path: str, resource_type: str = None) -> Optional[str]:
    """Parse FSH file to extract canonical URL

    For CodeSystems and ValueSets, looks for explicit ^url
    For Profiles, constructs URL from Id and canonical base
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

            # Look for explicit * ^url = "http://..."
            match = re.search(r'\*\s+\^url\s+=\s+"([^"]+)"', content)
            if match:
                return match.group(1)

            # For profiles, construct URL from Id field
            if resource_type == 'StructureDefinition':
                id_match = re.search(r'^Id:\s+(\S+)', content, re.MULTILINE)
                if id_match:
                    canonical_base = get_canonical_base()
                    profile_id = id_match.group(1)
                    return f"{canonical_base}/StructureDefinition/{profile_id}"
    except Exception as e:
        print(f"{YELLOW}Warning: Could not parse {file_path}: {e}{NC}", file=sys.stderr)
    return None


def discover_fsh_resources(base_dir: str = 'input/fsh') -> Tuple[List[str], List[str], List[str]]:
    """Discover all FSH resources by scanning the input/fsh directory"""
    profiles = []
    codesystems = []
    valuesets = []

    # Find all profile files
    profile_dir = os.path.join(base_dir, 'profiles')
    if os.path.exists(profile_dir):
        for fsh_file in glob.glob(os.path.join(profile_dir, '*.fsh')):
            url = parse_fsh_canonical_url(fsh_file, 'StructureDefinition')
            if url:
                profiles.append(url)

    # Find all codesystem files
    codesystem_dir = os.path.join(base_dir, 'codesystems')
    if os.path.exists(codesystem_dir):
        for fsh_file in glob.glob(os.path.join(codesystem_dir, '*.fsh')):
            url = parse_fsh_canonical_url(fsh_file, 'CodeSystem')
            if url:
                codesystems.append(url)

    # Find all valueset files
    valueset_dir = os.path.join(base_dir, 'valuesets')
    if os.path.exists(valueset_dir):
        for fsh_file in glob.glob(os.path.join(valueset_dir, '*.fsh')):
            url = parse_fsh_canonical_url(fsh_file, 'ValueSet')
            if url:
                valuesets.append(url)

    return profiles, codesystems, valuesets


def get_expected_version() -> str:
    """Get expected version from sushi-config.yaml"""
    try:
        with open('sushi-config.yaml', 'r') as f:
            for line in f:
                if line.startswith('version:'):
                    return line.split(':', 1)[1].strip()
    except FileNotFoundError:
        pass
    return "unknown"


def query_resource(fhir_base_url: str, resource_type: str, url: str) -> Dict:
    """Query FHIR server for a specific canonical URL"""
    query_url = f"{fhir_base_url}/{resource_type}?url={url}"
    req = urllib.request.Request(query_url, headers={'Accept': 'application/fhir+json'})

    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf-8'))
    except urllib.error.URLError as e:
        print(f"{RED}Error querying {query_url}: {e}{NC}", file=sys.stderr)
        return {"total": 0, "entry": []}


def delete_resource(fhir_base_url: str, resource_type: str, resource_id: str) -> Dict:
    """Delete a resource by ID"""
    delete_url = f"{fhir_base_url}/{resource_type}/{resource_id}"
    req = urllib.request.Request(delete_url, method='DELETE', headers={'Accept': 'application/fhir+json'})

    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf-8'))
    except urllib.error.URLError as e:
        return {"resourceType": "OperationOutcome", "issue": [{"severity": "error", "diagnostics": str(e)}]}


def process_resources(
    fhir_base_url: str,
    resource_type: str,
    urls: List[str],
    expected_version: str,
    command: str
) -> Tuple[int, List[Tuple[str, str, str, str]]]:
    """Process resources and return issues count and resources to clean"""
    total_issues = 0
    resources_to_clean = []

    for url in urls:
        response = query_resource(fhir_base_url, resource_type, url)
        total = response.get('total', 0)
        entries = response.get('entry', [])

        if total > 1:
            print(f"{YELLOW}⚠ Found {total} versions of {resource_type}: {url}{NC}", file=sys.stderr)

            for entry in entries:
                resource = entry.get('resource', {})
                version = resource.get('version', 'unknown')
                resource_id = resource.get('id', 'unknown')
                date = resource.get('date', 'unknown')

                if version == expected_version:
                    print(f"  {GREEN}✓ Keep{NC} Version: {version}, ID: {resource_id}, Date: {date}", file=sys.stderr)
                else:
                    print(f"  {RED}✗ Remove{NC} Version: {version}, ID: {resource_id}, Date: {date}", file=sys.stderr)
                    if command == 'clean':
                        resources_to_clean.append((resource_type, resource_id, url, version))

            total_issues += 1
            print("", file=sys.stderr)

        elif total == 1:
            resource = entries[0].get('resource', {})
            version = resource.get('version', 'unknown')
            resource_id = resource.get('id', 'unknown')

            if version != expected_version:
                print(f"{YELLOW}⚠ Unexpected version of {resource_type}: {url}{NC}", file=sys.stderr)
                print(f"  Found: {version}, Expected: {expected_version}, ID: {resource_id}", file=sys.stderr)
                print("", file=sys.stderr)
                total_issues += 1

                if command == 'clean':
                    resources_to_clean.append((resource_type, resource_id, url, version))
            elif command == 'list':
                print(f"{GREEN}✓{NC} {resource_type}: {url.split('/')[-1]} - Version: {version}", file=sys.stderr)

        elif total == 0 and command == 'list':
            print(f"{RED}✗{NC} {resource_type}: {url.split('/')[-1]} - Not found", file=sys.stderr)

    return total_issues, resources_to_clean


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]
    fhir_base_url = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:8080/fhir/DEFAULT"

    if command not in ['detect', 'clean', 'list']:
        print(f"{RED}Error: Invalid command '{command}'{NC}")
        print("Valid commands: detect, clean, list")
        sys.exit(1)

    expected_version = get_expected_version()

    # Discover resources from FSH files
    print(f"{BLUE}Discovering resources from FSH files...{NC}", file=sys.stderr)
    profiles, codesystems, valuesets = discover_fsh_resources()
    print(f"  Found {len(profiles)} profiles, {len(codesystems)} code systems, {len(valuesets)} value sets", file=sys.stderr)
    print("", file=sys.stderr)

    # Print header
    print(f"{BLUE}═══════════════════════════════════════════════════════════{NC}")
    print(f"{BLUE}  Koppeltaal FHIR Version Management{NC}")
    print(f"{BLUE}═══════════════════════════════════════════════════════════{NC}")
    print(f"Command:          {command}")
    print(f"FHIR Server:      {fhir_base_url}")
    print(f"Expected Version: {expected_version}")
    print(f"{BLUE}═══════════════════════════════════════════════════════════{NC}")
    print()

    # Process resources
    all_resources_to_clean = []

    print(f"{BLUE}Checking StructureDefinitions...{NC}", file=sys.stderr)
    sd_issues, sd_clean = process_resources(fhir_base_url, "StructureDefinition", profiles, expected_version, command)
    all_resources_to_clean.extend(sd_clean)

    print(f"{BLUE}Checking CodeSystems...{NC}", file=sys.stderr)
    cs_issues, cs_clean = process_resources(fhir_base_url, "CodeSystem", codesystems, expected_version, command)
    all_resources_to_clean.extend(cs_clean)

    print(f"{BLUE}Checking ValueSets...{NC}", file=sys.stderr)
    vs_issues, vs_clean = process_resources(fhir_base_url, "ValueSet", valuesets, expected_version, command)
    all_resources_to_clean.extend(vs_clean)

    total_issues = sd_issues + cs_issues + vs_issues

    # Summary
    print(f"{BLUE}═══════════════════════════════════════════════════════════{NC}")

    if command == 'detect':
        if total_issues == 0:
            print(f"{GREEN}✓ No version issues detected!{NC}")
            print(f"All resources have the expected version: {expected_version}")
        else:
            print(f"{RED}✗ Found {total_issues} resource(s) with version issues{NC}")
            print("Run with 'clean' command to remove old versions")

    elif command == 'clean':
        if len(all_resources_to_clean) == 0:
            print(f"{GREEN}✓ No resources to clean!{NC}")
        else:
            print(f"{YELLOW}Found {len(all_resources_to_clean)} resource(s) to clean{NC}")
            print()

            # Show what will be deleted
            print("The following resources will be deleted:")
            for resource_type, resource_id, url, version in all_resources_to_clean:
                resource_name = url.split('/')[-1]
                print(f"  - {resource_type}/{resource_id} ({resource_name} version {version})")
            print()

            # Confirm deletion
            confirm = input("Do you want to proceed with deletion? (yes/no): ")
            if confirm.lower() == 'yes':
                print()
                print(f"{BLUE}Deleting old versions...{NC}")

                for resource_type, resource_id, url, version in all_resources_to_clean:
                    print(f"Deleting {resource_type}/{resource_id} (version {version})...")

                    result = delete_resource(fhir_base_url, resource_type, resource_id)

                    if result.get('resourceType') == 'OperationOutcome':
                        severity = result.get('issue', [{}])[0].get('severity', 'unknown')
                        if severity == 'information':
                            print(f"  {GREEN}✓ Deleted successfully{NC}")
                        else:
                            diagnostics = result.get('issue', [{}])[0].get('diagnostics', 'Unknown error')
                            print(f"  {RED}✗ Error deleting: {diagnostics}{NC}")
                    else:
                        print(f"  {GREEN}✓ Deleted successfully{NC}")

                print()
                print(f"{GREEN}✓ Cleanup completed!{NC}")
            else:
                print(f"{YELLOW}Cleanup cancelled{NC}")

    elif command == 'list':
        print("Listed all Koppeltaal resources")

    print(f"{BLUE}═══════════════════════════════════════════════════════════{NC}")


if __name__ == '__main__':
    main()
