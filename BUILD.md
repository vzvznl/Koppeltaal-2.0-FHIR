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
  - **Snapshot-free StructureDefinitions** (differential-only like working Simplifier packages)
  - **No HTML narratives** (solves VARCHAR(4000) database issues)
  - **No RIM mappings** (reduces file size)
  - **Compact JSON format** (minimized whitespace)
  - **Standard FHIR package format** (compatible with HAPI FHIR)
- **Output**: `./output-minimal/koppeltaalv2-{version}-minimal.tgz`
- **Build Command**: `make build-minimal`

## Key Differences

| Feature | Full Package | Minimal Package |
|---------|-------------|-----------------|
| StructureDefinition Format | Full snapshots + differentials | Differential-only |
| File Size (per extension) | ~8KB (with snapshots) | ~1KB (differential-only) |
| HTML Narratives | ✅ Included | ❌ Stripped |
| RIM Mappings | ✅ Included | ❌ Stripped |
| JSON Format | Pretty-printed | Compact |
| Database Compatibility | ⚠️ May exceed VARCHAR limits | ✅ Optimized for HAPI FHIR |
| Use Case | Human documentation | Server implementation |

## Package Format Approach

The minimal build solves the **VARCHAR(4000) database constraint** issue by creating packages that match the working Simplifier format:

### Root Cause
HAPI FHIR servers have database field limits (VARCHAR(4000)) that are exceeded by:
- Full snapshot definitions in StructureDefinitions
- HTML narrative content (`text` sections)
- RIM mapping definitions
- Pretty-printed JSON with extensive whitespace

### Solution
The minimal build creates **differential-only packages** that match the working Simplifier format:

1. **Starts with full IG Publisher output** (with snapshots and narratives)
2. **Strips problematic content**:
   - Removes `snapshot` sections (keeps only `differential`)
   - Removes `text` sections (HTML narratives)
   - Removes `mapping` sections (RIM mappings)
   - Removes disabled `Extension.extension` elements
3. **Compacts JSON format** (removes whitespace)
4. **Uses Firely CLI pack** (standard FHIR package format)

## Build Process Details

### Full Package (Standard IG Publisher)
1. Runs FHIR IG Publisher with full configuration
2. Generates complete HTML documentation
3. Creates Implementation Guide package with full snapshots
4. Includes all narratives and validation files

### Minimal Package (Snapshot Stripping)
1. **Builds full IG first** (reuses existing output)
2. **Copies FHIR resources** to output-minimal directory
3. **Strips snapshots and narratives** using Python script:
   ```python
   # Remove snapshot sections
   if 'snapshot' in data:
       del data['snapshot']
   
   # Remove text/narrative sections  
   if 'text' in data:
       del data['text']
   
   # Remove mapping sections
   if 'mapping' in data:
       del data['mapping']
   ```
4. **Converts IG to package.json** using original approach from commit 13d0e43
5. **Packs with Firely CLI** to create standard FHIR package

## File Size Comparison

### Working Simplifier Package (Reference)
```
ext-KT2CorrelationId.json: 1.0KB (differential-only)
```

### Our Minimal Package (After Stripping)
```
ext-KT2CorrelationId.json: 1.0KB (differential-only, matches working)
```

### Full Package (With Snapshots)
```
StructureDefinition-correlation-id.json: 8.0KB (with snapshots + narratives)
```

## GitHub Actions Integration

The CI/CD pipeline automatically builds, tests, and releases packages:

### Build Jobs
1. **`build-full`** - Builds full documentation package with narratives
2. **`build-minimal`** - Builds minimal server package (snapshot-free)

### Release Strategy

#### Main Branch (Stable Releases)
When code is pushed to `main`:
1. Builds both full and minimal packages
2. Deploys full package to GitHub Pages
3. Creates a **stable release** with both packages
4. Publishes both packages to GitHub Packages (NPM)

**Release format:**
- **Name**: `{version}` (e.g., `1.4.5`)
- **Tag**: `v{version}` (e.g., `v1.4.5`)
- **Assets**:
  - `koppeltaalv2-{version}.tgz` - Full documentation package
  - `koppeltaalv2-{version}-minimal.tgz` - Minimal server package

#### Branch Builds (Pre-releases)
When code is pushed to any other branch:
1. Builds both packages but only releases the minimal
2. Creates a **pre-release** with minimal package only
3. Publishes packages to GitHub Packages with restricted access

**Pre-release format:**
- **Name**: `{version}-minimal-{branch-name}`
- **Tag**: `v{version}-minimal-{branch-name}-{run-number}`
- **Assets**:
  - `koppeltaalv2-{version}-minimal.tgz` - Minimal package only

### Package URLs

#### Stable Release URLs
```bash
# Minimal package (for HAPI servers)
https://github.com/GIDSOpenStandaarden/Koppeltaal-2.0-FHIR/releases/download/v1.4.5/koppeltaalv2-1.4.5-minimal.tgz

# Full package (for documentation)
https://github.com/GIDSOpenStandaarden/Koppeltaal-2.0-FHIR/releases/download/v1.4.5/koppeltaalv2-1.4.5.tgz
```

#### Pre-release URLs
```bash
# Example for test-beta-release branch, run 82
https://github.com/GIDSOpenStandaarden/Koppeltaal-2.0-FHIR/releases/download/v1.4.5-beta.002-minimal-test-beta-release-82/koppeltaalv2-1.4.5-beta.002-minimal.tgz
```

### Artifacts
- **build-full**: Creates `fhir-package-full` artifact
- **build-minimal**: Creates `fhir-package-minimal` artifact
- Both artifacts contain the built packages and metadata

## Local Development

### Build Both Packages
```bash
# Build full documentation package
make build

# Build minimal server package (with snapshot stripping)
make build-minimal
```

### Docker Usage
```bash
# Full build
docker run -v ${PWD}:/src koppeltaal-builder:latest build

# Minimal build  
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
    name: koppeltaalv2.00  # Must match Simplifier package name
    version: 1.4.5-beta.002
    packageUrl: https://github.com/GIDSOpenStandaarden/Koppeltaal-2.0-FHIR/releases/download/v1.4.5-beta.002/koppeltaalv2-1.4.5-beta.002-minimal.tgz
    fetchDependencies: false
    installMode: STORE_AND_INSTALL
```

## Troubleshooting

### VARCHAR(4000) Database Errors
**Problem**: `value too long for type character varying(4000)`

**Solution**: 
- ✅ Use the **minimal package** (differential-only format)
- ❌ Don't use the full package (with snapshots) for HAPI FHIR

The minimal package matches the working Simplifier format that doesn't exceed database limits.

### File Size Verification
```bash
# Check that minimal files match working package sizes
du -h output-minimal/package/ext-KT2CorrelationId.json
# Should be ~1KB (not 8KB)
```

## Technical Details

### Package Size Comparison
- **Working Simplifier Package**: 172KB
- **Our Minimal Package**: 184KB (very close!)
- **Full Package**: Much larger due to snapshots

### Snapshot Stripping Script
The `scripts/strip_snapshots.py` script processes StructureDefinition files to:
1. Remove snapshot sections (largest contributor to file size)
2. Remove text/narrative sections (HTML content)
3. Remove mapping sections (RIM mappings)
4. Clean up disabled Extension.extension elements
5. Output compact JSON format

### Original Working Approach
This implementation restores the original working approach from commit `13d0e43` that used:
1. SUSHI/IG Publisher for resource generation
2. Python script for IG → package.json conversion  
3. Firely CLI for final package creation

This proven approach ensures compatibility with HAPI FHIR servers while maintaining the ability to generate rich documentation.

## Configuration

### Single Source Configuration
- Uses **one** `sushi-config.yaml` for both builds
- No separate minimal configuration needed
- Stripping happens at build time via Makefile

### Package Naming
- **Package ID**: `koppeltaalv2.00` (matches Simplifier registry)
- **Previous ID**: `koppeltaal` (generic, caused conflicts)
- **HAPI Config**: Must use `name: koppeltaalv2.00` to match package

### Makefile Targets
- `make build` - Full IG Publisher package
- `make build-minimal` - Stripped minimal package
- `make install-dependencies` - Install required FHIR packages
- `make version` - Show current version from sushi-config.yaml

This approach ensures compatibility with both human documentation needs and FHIR server requirements while solving the VARCHAR(4000) database constraint issue by matching the proven working Simplifier package format.