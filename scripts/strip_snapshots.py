#!/usr/bin/env python3
"""
Script to strip snapshots from FHIR StructureDefinition JSON files
This creates minimal packages that match the original working format
"""

import json
import os
import sys
import glob

def strip_snapshots_from_file(file_path):
    """Remove snapshot, mapping, and text sections from a StructureDefinition JSON file"""
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
        
        if data.get('resourceType') == 'StructureDefinition':
            sections_removed = []
            
            # Remove snapshot section
            if 'snapshot' in data:
                del data['snapshot']
                sections_removed.append('snapshot')
            
            # Remove mapping section
            if 'mapping' in data:
                del data['mapping']
                sections_removed.append('mapping')
            
            # Remove text/narrative section
            if 'text' in data:
                del data['text']
                sections_removed.append('text')
            
            # Clean up differential section - remove disabled extensions
            if 'differential' in data and 'element' in data['differential']:
                original_elements = data['differential']['element']
                # Keep only essential elements, remove Extension.extension if max is 0
                filtered_elements = []
                for element in original_elements:
                    if element.get('path') == 'Extension.extension' and element.get('max') == '0':
                        sections_removed.append('Extension.extension')
                        continue
                    filtered_elements.append(element)
                data['differential']['element'] = filtered_elements
            
            if sections_removed:
                print(f"Removed {', '.join(sections_removed)} from {os.path.basename(file_path)}")
            
            # Write back the stripped file (compact format to save space)
            with open(file_path, 'w') as f:
                json.dump(data, f, separators=(',', ':'))
                f.write('\n')
            
            return True
        else:
            print(f"Skipping {os.path.basename(file_path)} - not a StructureDefinition")
            return False
            
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 strip_snapshots.py <directory>")
        sys.exit(1)
    
    directory = sys.argv[1]
    
    if not os.path.isdir(directory):
        print(f"Error: {directory} is not a directory")
        sys.exit(1)
    
    # Find all JSON files in the directory
    json_files = glob.glob(os.path.join(directory, "*.json"))
    
    if not json_files:
        print(f"No JSON files found in {directory}")
        sys.exit(1)
    
    print(f"Processing {len(json_files)} JSON files in {directory}")
    
    processed = 0
    for file_path in json_files:
        if strip_snapshots_from_file(file_path):
            processed += 1
    
    print(f"Successfully processed {processed} StructureDefinition files")

if __name__ == "__main__":
    main()