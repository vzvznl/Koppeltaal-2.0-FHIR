#!/usr/bin/env python3
"""
Fix the "4.0.x" version in nictiz package.json files that causes
"Invalid candidate: 4.0.x" error in IG Publisher 2.0.15.
"""

import json
import os
from pathlib import Path

def fix_package_json(file_path):
    """Fix 4.0.x version in package.json file."""
    with open(file_path, 'r') as f:
        package_data = json.load(f)

    modified = False

    # Check dependencies
    if 'dependencies' in package_data:
        for dep_name, dep_version in package_data['dependencies'].items():
            if dep_version == '4.0.x':
                print(f"  Fixing {dep_name}: {dep_version} -> 4.0.1")
                package_data['dependencies'][dep_name] = '4.0.1'
                modified = True

    if modified:
        with open(file_path, 'w') as f:
            json.dump(package_data, f, indent=2)
        print(f"  ✅ Fixed: {file_path}")
        return True

    return False

def main():
    """Fix all nictiz package.json files."""
    home = Path.home()
    fhir_packages = home / '.fhir' / 'packages'

    if not fhir_packages.exists():
        print(f"Error: {fhir_packages} does not exist")
        return

    print("🔧 Fixing 4.0.x versions in nictiz packages")
    print("=" * 50)

    # Find nictiz package directories
    nictiz_dirs = [
        fhir_packages / 'nictiz.fhir.nl.r4.nl-core#0.11.0-beta.1' / 'package',
        fhir_packages / 'nictiz.fhir.nl.r4.zib2020#0.11.0-beta.1' / 'package',
    ]

    fixed_count = 0
    for package_dir in nictiz_dirs:
        package_json = package_dir / 'package.json'
        if package_json.exists():
            print(f"Processing: {package_json.parent.parent.name}")
            if fix_package_json(package_json):
                fixed_count += 1
        else:
            print(f"  ⚠️  Not found: {package_json}")

    print("\n" + "=" * 50)
    print(f"✅ Fixed {fixed_count} package.json files")

if __name__ == "__main__":
    main()
