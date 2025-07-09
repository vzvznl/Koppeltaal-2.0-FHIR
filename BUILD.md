# Dual-Build Configuration

This project uses a dual-build approach to generate two different packages from the same source:

## 1. Full Documentation Package
- **Purpose**: For GitHub Pages and human consumption
- **Features**: 
  - Full HTML narratives with embedded images
  - Complete documentation pages  
  - Examples and detailed descriptions
  - Rich formatting for web viewing
  - Implementation Guide format with full structure
- **Output**: `./output/koppeltaalv2-{version}.tgz`
- **Build Command**: `make build`

## 2. Minimal Server Package 
- **Purpose**: For FHIR servers (HAPI FHIR) and automated processing
- **Features**:
  - **Firely CLI export format** (not IG Publisher format)
  - Simple file naming convention (`KT2Patient.json` vs `StructureDefinition-KT2Patient.json`)
  - Minimal ImplementationGuide (589 bytes like working Simplifier packages)
  - No HTML narratives (solves VARCHAR(4000) database issues)
  - Standard FHIR package format (not Implementation Guide type)
  - JSON-only format with minimal dependencies
- **Output**: `./output-minimal/koppeltaalv2-{version}-minimal.tgz`
- **Build Command**: `make build-minimal`

## Key Differences

| Feature | Full Package | Minimal Package |
|---------|-------------|-----------------|
| Package Type | Implementation Guide | Standard FHIR Package |
| File Naming | `StructureDefinition-KT2Patient.json` | `KT2Patient.json` |
| ImplementationGuide | 46KB+ with full definition | 589 bytes minimal skeleton |
| HTML Narratives | ✅ Included | ❌ Stripped |
| Documentation Pages | ✅ Generated | ❌ Not included |
| SearchParameters | IG Publisher format | Simple `search-*.json` format |
| Extensions | `StructureDefinition-correlation-id.json` | `ext-KT2CorrelationId.json` |
| Validation Files | ✅ Included | ❌ Removed (cause database issues) |
| Database Compatibility | ⚠️ May exceed VARCHAR limits | ✅ Optimized for HAPI FHIR |
| Use Case | Human documentation | Server implementation |

## Package Format Conversion

The minimal build solves the **VARCHAR(4000) database constraint** issue by converting from IG Publisher format to Firely CLI export format:

### Root Cause
HAPI FHIR servers expect **standard FHIR packages** (like Simplifier exports), but our IG Publisher creates **Implementation Guide packages** with different structure that causes database errors.

### Solution
The minimal build performs **format conversion**:

1. **Takes IG Publisher output** (`StructureDefinition-KT2Patient.json`)
2. **Converts to Firely CLI format** (`KT2Patient.json`)
3. **Creates minimal ImplementationGuide** (589 bytes like working packages)
4. **Removes IG Publisher bloat** (validation files, complex SearchParameters)
5. **Uses standard package.json** (not IG type)

## Build Process Details

### Full Package (IG Publisher Standard)
1. Runs FHIR IG Publisher with full configuration
2. Generates complete HTML documentation
3. Creates Implementation Guide package
4. Includes all narratives and validation files

### Minimal Package (Format Conversion)
1. **Starts with full IG Publisher output**
2. **Extracts and converts file structure**:
   - `StructureDefinition-KT2*.json` → `KT2*.json` (strip narratives)
   - `StructureDefinition-KT2*Extension.json` → `ext-KT2*.json`
   - `StructureDefinition-*.json` → `ext-KT2*.json` (for other extensions)
   - `SearchParameter-*.json` → `search-*.json`
   - `ImplementationGuide-*.json` → `KT2ImplementationGuide.json` (minimal)
3. **Creates Firely CLI-style package.json**:
   ```json
   {
     "name": "koppeltaal",
     "version": "1.4.5-beta.002",
     "fhirVersions": ["4.0.1"],
     "dependencies": {
       "nictiz.fhir.nl.r4.zib2020": "0.11.0-beta.1",
       "nictiz.fhir.nl.r4.nl-core": "0.11.0-beta.1"
     }
   }
   ```
4. **Removes problematic files**:
   - `other/validation-oo.json` (105KB, causes database issues)
   - `.index.json` 
   - `xml/` directory
5. **Repackages for HAPI FHIR compatibility**

## GitHub Actions Integration

The CI/CD pipeline builds both packages:

### Jobs
1. **`build-full`** - Builds full documentation package (IG Publisher format)
2. **`build-minimal`** - Builds minimal server package (Firely CLI format)

### Artifacts
- **Full Package**: Published to GitHub Pages
- **Minimal Package**: Published for FHIR server deployment
- **Both**: Included in GitHub releases

## Local Development

### Build Both Packages
```bash
# Build full documentation package
make build

# Build minimal server package (with format conversion)
make build-minimal
```

### Docker Usage
```bash
# Full build (IG Publisher format)
docker run -v ${PWD}:/src koppeltaal-builder:latest build

# Minimal build (Firely CLI format)  
docker run -v ${PWD}:/src koppeltaal-builder:latest build-minimal
```

## Package Consumption

### For Implementation Guides
Use the **full package** for:
- Documentation websites
- GitHub Pages  
- Human-readable guides
- Complete IG Publisher output

### For HAPI FHIR Servers
Use the **minimal package** for:
- HAPI FHIR server deployment (solves VARCHAR(4000) errors)
- Production FHIR servers
- Automated processing
- Database loading

**HAPI Configuration Example:**
```yaml
implementationguides:
  kt2:
    name: koppeltaal
    version: 1.4.5-beta.002
    packageUrl: https://github.com/.../koppeltaalv2-1.4.5-beta.002-minimal.tgz
    fetchDependencies: false
    installMode: STORE_AND_INSTALL
```

## Troubleshooting

### VARCHAR(4000) Database Errors
**Problem**: `value too long for type character varying(4000)`

**Solution**: 
- ✅ Use the **minimal package** (Firely CLI format)
- ❌ Don't use the full package (IG Publisher format) for HAPI FHIR

The minimal package converts the problematic IG Publisher structure to the same format as working Simplifier packages.

### Working vs Failing Examples
```yaml
# ✅ WORKS (Simplifier package)
kt2:
  name: Koppeltaalv2.00
  version: 0.14.0
  
# ✅ WORKS (Our minimal package - same format)  
kt2:
  name: koppeltaal
  version: 1.4.5-beta.002
  packageUrl: .../koppeltaalv2-1.4.5-beta.002-minimal.tgz

# ❌ FAILS (IG Publisher format)
kt2:
  name: koppeltaal
  version: 1.4.5-beta.002  
  packageUrl: .../koppeltaalv2-1.4.5-beta.002.tgz  # Full package
```

## Technical Details

### File Structure Comparison

**Working Simplifier Package:**
```
package/
├── KT2Patient.json              (352KB - works fine)
├── KT2ImplementationGuide.json  (589 bytes)
├── ext-KT2CorrelationId.json
└── search-*.json
```

**Our Minimal Package (After Conversion):**
```
package/
├── KT2Patient.json              (352KB - same size, works)
├── KT2ImplementationGuide.json  (589 bytes - matches working)
├── ext-KT2CorrelationId.json    (converted from IG Publisher)
└── search-*.json                (converted from SearchParameter-*)
```

**Problematic IG Publisher Package:**
```
package/
├── StructureDefinition-KT2Patient.json     (482KB)
├── ImplementationGuide-koppeltaal.json     (46KB - too large!)
├── StructureDefinition-correlation-id.json (complex structure)
├── SearchParameter-*.json                  (IG Publisher format)
├── other/validation-oo.json                (105KB - causes errors)
└── .index.json                            (IG Publisher artifact)
```

The minimal build transforms the bottom structure into the top structure, matching the proven working format.

## Configuration

### Single Source Configuration
- Uses **one** `sushi-config.yaml` for both builds
- No separate minimal configuration needed
- Conversion happens at build time via Makefile

### Makefile Targets
- `make build` - Full IG Publisher package
- `make build-minimal` - Converted Firely CLI package
- `make install-dependencies` - Install required FHIR packages

This approach ensures compatibility with both human documentation needs and FHIR server requirements while solving the VARCHAR(4000) database constraint issue.