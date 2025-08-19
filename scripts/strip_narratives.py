#!/usr/bin/env python3
"""
Script to strip narratives and other large content from FHIR JSON files
This creates minimal packages suitable for HAPI FHIR server deployment
"""

import json
import os
import sys
import glob
import argparse

def strip_narratives_from_file(file_path, keep_snapshots=False):
    """Remove text and optionally snapshot sections from FHIR JSON files"""
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)

        resource_type = data.get('resourceType')

        if resource_type == 'StructureDefinition':
            sections_removed = []

            # Remove snapshot section only if not keeping snapshots
            if not keep_snapshots and 'snapshot' in data:
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
            elif keep_snapshots:
                print(f"Kept snapshot in {os.path.basename(file_path)}")

            # Write back the stripped file (compact format to save space)
            with open(file_path, 'w') as f:
                json.dump(data, f, separators=(',', ':'))
                f.write('\n')

            return True

        elif resource_type == 'ImplementationGuide':
            sections_removed = []

            # Remove text/narrative section
            if 'text' in data:
                del data['text']
                sections_removed.append('text')

            # Simplify description if it's too long
            if 'description' in data and len(data['description']) > 500:
                data['description'] = "Koppeltaal 2.0 Implementation Guide - Minimal package for FHIR server deployment"
                sections_removed.append('long description')

            # Remove or simplify definition section if it exists and is large
            if 'definition' in data:
                definition = data['definition']

                # Simplify grouping descriptions
                if 'grouping' in definition:
                    for group in definition['grouping']:
                        if 'description' in group and len(group['description']) > 100:
                            group['description'] = group.get('name', 'Resources')
                    sections_removed.append('grouping descriptions')

                # Remove resource descriptions but keep references
                if 'resource' in definition:
                    for resource in definition['resource']:
                        if 'description' in resource:
                            del resource['description']
                    sections_removed.append('resource descriptions')

                # Simplify pages if they exist
                if 'page' in definition:
                    pages = definition['page']
                    if isinstance(pages, dict) and 'page' in pages:
                        # Remove nested pages to reduce size
                        del pages['page']
                        sections_removed.append('nested pages')

            if sections_removed:
                print(f"Removed {', '.join(sections_removed)} from {os.path.basename(file_path)}")

            # Write back the stripped file (compact format to save space)
            with open(file_path, 'w') as f:
                json.dump(data, f, separators=(',', ':'))
                f.write('\n')

            return True
        else:
            print(f"Skipping {os.path.basename(file_path)} - not a StructureDefinition or ImplementationGuide")
            return False

    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Strip narratives and optionally snapshots from FHIR JSON files')
    parser.add_argument('directory', help='Directory containing JSON files to process')
    parser.add_argument('--keep-snapshots', action='store_true', 
                        help='Keep snapshot sections in StructureDefinitions (removes only text and mappings)')
    
    args = parser.parse_args()
    directory = args.directory

    if not os.path.isdir(directory):
        print(f"Error: {directory} is not a directory")
        sys.exit(1)

    # Find all JSON files in the directory
    json_files = glob.glob(os.path.join(directory, "*.json"))

    if not json_files:
        print(f"No JSON files found in {directory}")
        sys.exit(1)

    print(f"Processing {len(json_files)} JSON files in {directory}")
    if args.keep_snapshots:
        print("Keeping snapshots in StructureDefinitions")

    processed = 0
    for file_path in json_files:
        if strip_narratives_from_file(file_path, args.keep_snapshots):
            processed += 1

    print(f"Successfully processed {processed} FHIR resource files")

if __name__ == "__main__":
    main()