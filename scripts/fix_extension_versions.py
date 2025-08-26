#!/usr/bin/env python3
"""
Fix incorrect version references in generated FHIR profiles.

The IG Publisher incorrectly generates snapshots with R5 versions for 
HL7 FHIR R4 resources. These versions cause resolution errors.
This script removes or fixes version suffixes from HL7 FHIR references.
"""

import json
import sys
from pathlib import Path

def fix_hl7_reference(reference_url):
    """Fix HL7 FHIR reference versions."""
    if "|" in reference_url:
        base_url = reference_url.split("|")[0]
        version = reference_url.split("|")[1]
        
        # Check if this is an HL7 FHIR resource that should have version removed/fixed
        if base_url.startswith("http://hl7.org/fhir/"):
            # For R5 versions (5.x.x), remove version entirely for R4 compatibility
            if version.startswith("5."):
                print(f"  Removing R5 version: {reference_url} -> {base_url}")
                return base_url, True
            # For explicit 4.0.x versions, keep them
            elif version.startswith("4.0"):
                return reference_url, False
            else:
                # Remove other problematic versions
                print(f"  Removing version: {reference_url} -> {base_url}")
                return base_url, True
    
    return reference_url, False

def process_element(element):
    """Process a single element in the snapshot/differential."""
    modified = False
    
    # Check type.profile for extensions
    if "type" in element:
        for type_elem in element["type"]:
            if "profile" in type_elem:
                profiles = type_elem["profile"]
                new_profiles = []
                for profile in profiles:
                    fixed_profile, was_fixed = fix_hl7_reference(profile)
                    new_profiles.append(fixed_profile)
                    if was_fixed:
                        modified = True
                type_elem["profile"] = new_profiles
    
    # Check binding.valueSet references
    if "binding" in element and "valueSet" in element["binding"]:
        valueset = element["binding"]["valueSet"]
        fixed_valueset, was_fixed = fix_hl7_reference(valueset)
        if was_fixed:
            element["binding"]["valueSet"] = fixed_valueset
            modified = True
    
    return modified

def fix_structure_definition(file_path):
    """Fix extension versions in a StructureDefinition file."""
    print(f"Processing: {file_path.name}")
    
    with open(file_path, 'r') as f:
        resource = json.load(f)
    
    if resource.get("resourceType") != "StructureDefinition":
        return False
    
    modified = False
    
    # Process snapshot elements
    if "snapshot" in resource and "element" in resource["snapshot"]:
        for element in resource["snapshot"]["element"]:
            if process_element(element):
                modified = True
    
    # Process differential elements
    if "differential" in resource and "element" in resource["differential"]:
        for element in resource["differential"]["element"]:
            if process_element(element):
                modified = True
    
    if modified:
        # Save the fixed file
        with open(file_path, 'w') as f:
            json.dump(resource, f, indent=2)
        print(f"  ✅ Fixed and saved: {file_path.name}")
        return True
    
    return False

def main():
    """Main function to process all StructureDefinition files."""
    if len(sys.argv) > 1:
        output_dir = Path(sys.argv[1])
    else:
        output_dir = Path("output")
    
    if not output_dir.exists():
        print(f"Error: Directory {output_dir} does not exist")
        sys.exit(1)
    
    print(f"🔧 Fixing Extension Version References in {output_dir}")
    print("=" * 50)
    
    # Find all StructureDefinition JSON files
    sd_files = list(output_dir.glob("StructureDefinition-*.json"))
    
    if not sd_files:
        print("No StructureDefinition files found")
        return
    
    fixed_count = 0
    for file_path in sd_files:
        if fix_structure_definition(file_path):
            fixed_count += 1
    
    print("\n" + "=" * 50)
    print(f"✅ Fixed {fixed_count} files")
    
    # Also process files in package subdirectory if it exists
    package_dir = output_dir / "package"
    if package_dir.exists():
        print(f"\n🔧 Processing package directory: {package_dir}")
        print("=" * 50)
        
        package_sd_files = list(package_dir.glob("StructureDefinition-*.json"))
        package_fixed = 0
        
        for file_path in package_sd_files:
            if fix_structure_definition(file_path):
                package_fixed += 1
        
        if package_fixed > 0:
            print(f"✅ Fixed {package_fixed} files in package directory")

if __name__ == "__main__":
    main()