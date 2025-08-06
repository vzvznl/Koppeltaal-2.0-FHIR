#!/usr/bin/env python3
"""
Create .index.json file for FHIR package
"""
import json
import glob
import os
from datetime import datetime

def create_index():
    """Create .index.json file for FHIR package"""
    files = []
    
    # Process all JSON files in the package directory
    for filepath in glob.glob('package/*.json'):
        if os.path.basename(filepath) == 'package.json':
            continue
            
        try:
            with open(filepath, 'r') as f:
                resource = json.load(f)
                
            # Extract metadata from resource
            file_entry = {
                'filename': os.path.basename(filepath),
                'resourceType': resource.get('resourceType', 'Unknown'),
                'id': resource.get('id', 'Unknown')
            }
            
            # Add URL if present
            if 'url' in resource:
                file_entry['url'] = resource['url']
                
            # Add version if present
            if 'version' in resource:
                file_entry['version'] = resource['version']
                
            # Add kind for StructureDefinition
            if resource.get('resourceType') == 'StructureDefinition':
                file_entry['kind'] = resource.get('kind', 'unknown')
                file_entry['type'] = resource.get('type', 'unknown')
                
            files.append(file_entry)
            
        except Exception as e:
            print(f"Warning: Could not process {filepath}: {e}")
            continue
    
    # Create index structure
    index = {
        'index-version': 1,
        'files': files
    }
    
    # Write index file
    with open('package/.index.json', 'w') as f:
        json.dump(index, f, indent=2)
        
    print(f"Created .index.json with {len(files)} entries")

if __name__ == '__main__':
    create_index()