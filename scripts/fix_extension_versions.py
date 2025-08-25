#!/usr/bin/env python3
"""
Fix incorrect extension version references in generated FHIR profiles.

The IG Publisher incorrectly generates snapshots with version 5.2.0 for 
HL7 FHIR R4 extensions when it should use version 4.0.1.
"""

import json
import sys
from pathlib import Path

# Map of extensions that should use R4 version
R4_EXTENSIONS = {
    "http://hl7.org/fhir/StructureDefinition/humanname-own-prefix": "4.0.1",
    "http://hl7.org/fhir/StructureDefinition/humanname-own-name": "4.0.1",
    "http://hl7.org/fhir/StructureDefinition/humanname-partner-prefix": "4.0.1",
    "http://hl7.org/fhir/StructureDefinition/humanname-partner-name": "4.0.1",
    "http://hl7.org/fhir/StructureDefinition/humanname-assembly-order": "4.0.1",
    "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier": "4.0.1",
}

def fix_extension_version(profile_url, old_version, new_version):
    """Fix extension version in a profile URL."""
    if f"|{old_version}" in profile_url:
        base_url = profile_url.split("|")[0]
        if base_url in R4_EXTENSIONS:
            return f"{base_url}|{R4_EXTENSIONS[base_url]}"
    return profile_url

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
                    # Fix version 5.2.0 references
                    if "|5.2.0" in profile or "|5.1.0" in profile:
                        base_url = profile.split("|")[0]
                        if base_url in R4_EXTENSIONS:
                            new_profile = f"{base_url}|{R4_EXTENSIONS[base_url]}"
                            print(f"  Fixed: {profile} -> {new_profile}")
                            new_profiles.append(new_profile)
                            modified = True
                        else:
                            new_profiles.append(profile)
                    else:
                        new_profiles.append(profile)
                type_elem["profile"] = new_profiles
    
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