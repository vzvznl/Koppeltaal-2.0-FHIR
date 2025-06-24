#!/usr/bin/env python3

import json
import yaml
import sys
from datetime import datetime

def convert_package_to_ig(package_path='package.json', output_path='generated-resources/KT2ImplementationGuide.gen.yaml'):
    """Convert package.json to FHIR ImplementationGuide YAML format"""

    # Read package.json
    with open(package_path, 'r') as f:
        package = json.load(f)

    # Create ImplementationGuide structure
    ig = {
        "ImplementationGuide": {
            "id": f"koppeltaal-ig-{package['name']}",
            "url": "http://koppeltaal.nl/fhir/ImplementationGuide",
            "version": package['version'],
            "name": "Koppeltaal_2.0_IG",
            "status": "active",
            "experimental": False,
            "date": datetime.now().strftime("%Y-%m-%d"),
            "publisher": package.get('author', 'VZVZ'),
            "packageId": package['name'],
            "fhirVersion": package.get('fhirVersions', ['4.0.1']),
            "dependsOn": []
        }
    }

    # Convert dependencies to FHIR format
    if 'dependencies' in package:
        for pkg_id, version in package['dependencies'].items():
            dependency = {
                "uri": f"https://simplifier.net/packages/{pkg_id}",
                "packageId": pkg_id,
                "version": version
            }
            ig['ImplementationGuide']['dependsOn'].append(dependency)

    # Write YAML output with proper formatting
    with open(output_path, 'w') as f:
        yaml.dump(ig, f, default_flow_style=False, sort_keys=False, allow_unicode=True)

    print(f"Successfully converted {package_path} to {output_path}")
    print(f"Version: {package['version']}")
    print(f"Dependencies: {len(ig['ImplementationGuide']['dependsOn'])}")

if __name__ == "__main__":
    # Allow custom input/output paths via command line
    package_path = sys.argv[1] if len(sys.argv) > 1 else 'package.json'
    output_path = sys.argv[2] if len(sys.argv) > 2 else 'generated-resources/KT2ImplementationGuide.gen.yaml'

    try:
        convert_package_to_ig(package_path, output_path)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
