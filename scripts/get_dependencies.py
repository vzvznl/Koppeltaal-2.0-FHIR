#!/usr/bin/env python3
"""Extract FHIR package dependencies from sushi-config.yaml."""

import yaml
import sys

def get_dependencies(config_file='sushi-config.yaml'):
    """Read dependencies from sushi-config.yaml and output as package@version."""
    with open(config_file, 'r') as f:
        config = yaml.safe_load(f)

    dependencies = config.get('dependencies', {})

    for package_name, package_info in dependencies.items():
        if isinstance(package_info, dict) and 'version' in package_info:
            version = package_info['version']
            print(f"{package_name}@{version}")

if __name__ == '__main__':
    get_dependencies()
