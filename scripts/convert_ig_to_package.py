#!/usr/bin/env python3

import json
import sys
import os

def convert_ig_to_package(ig_path='output/ImplementationGuide-Koppeltaal.json', output_path='package.json'):
    """Convert FHIR ImplementationGuide JSON back to package.json format"""

    # Read existing package.json if it exists
    package = {}
    if os.path.exists(output_path):
        with open(output_path, 'r') as f:
            package = json.load(f)
        print(f"Loaded existing {output_path}")
    else:
        print(f"Warning: {output_path} not found, creating new package.json")
        # Provide minimal defaults if package.json doesn't exist
        package = {
            "name": "koppeltaal",
            "description": "Koppeltaal 2.0 FHIR resource profiles - minimal package for FHIR servers",
            "title": "Koppeltaal 2.0 FHIR Package",
            "author": "VZVZ",
            "fhirVersions": ["4.0.1"],
            "jurisdiction": "urn:iso:std:iso:3166#NL",
            "maintainers": [{"name": "VZVZ"}, {"name": "Koppeltaal"}],
            "keywords": ["VZVZ", "Koppeltaal", "GGZ"]
        }

    # Read ImplementationGuide JSON
    with open(ig_path, 'r') as f:
        ig = json.load(f)

    # Update only version from ImplementationGuide
    package['version'] = ig.get('version', package.get('version', '0.0.0'))

    # Update dependencies from FHIR format, ignoring hl7ext
    package['dependencies'] = {}
    if 'dependsOn' in ig:
        for dependency in ig['dependsOn']:
            pkg_id = dependency.get('packageId', '')
            version = dependency.get('version', '')
            
            # Skip hl7ext and hl7tx dependencies
            if pkg_id and version and not pkg_id.startswith('hl7.'):
                package['dependencies'][pkg_id] = version

    # Add default dependencies if none found
    if not package['dependencies']:
        package['dependencies'] = {
            "nictiz.fhir.nl.r4.zib2020": "0.11.0-beta.1",
            "nictiz.fhir.nl.r4.nl-core": "0.11.0-beta.1"
        }

    # Write package.json with proper formatting
    with open(output_path, 'w') as f:
        json.dump(package, f, indent=2)
        f.write('\n')  # Add trailing newline

    print(f"Successfully converted {ig_path} to {output_path}")
    print(f"Version: {package['version']}")
    print(f"Dependencies: {len(package['dependencies'])}")
    
    # List dependencies
    if package['dependencies']:
        print("\nDependencies:")
        for pkg_id, version in package['dependencies'].items():
            print(f"  - {pkg_id}: {version}")

if __name__ == "__main__":
    # Allow custom input/output paths via command line
    ig_path = sys.argv[1] if len(sys.argv) > 1 else 'output/ImplementationGuide-Koppeltaal.json'
    output_path = sys.argv[2] if len(sys.argv) > 2 else 'package.json'

    try:
        convert_ig_to_package(ig_path, output_path)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)