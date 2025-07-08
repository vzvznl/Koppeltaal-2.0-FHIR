# Dual-Build Configuration

This project uses a dual-build approach to generate two different packages from the same source:

## 1. Full Documentation Package (`sushi-config.yaml`)
- **Purpose**: For GitHub Pages and human consumption
- **Features**: 
  - Full HTML narratives with embedded images
  - Complete documentation pages  
  - Examples and detailed descriptions
  - Rich formatting for web viewing
- **Output**: `./output/koppeltaalv2-{version}.tgz`
- **Build Command**: `make build`

## 2. Minimal Server Package (`sushi-config-minimal.yaml`)
- **Purpose**: For FHIR servers and automated processing
- **Features**:
  - No HTML narratives (solves VARCHAR(4000) database issues)
  - Only essential structural definitions
  - Minimal file sizes for efficient loading
  - JSON-only format
- **Output**: `./output-minimal/koppeltaalv2-{version}-minimal.tgz`
- **Build Command**: `make build-minimal`

## Key Differences

| Feature | Full Package | Minimal Package |
|---------|-------------|-----------------|
| HTML Narratives | ✅ Included | ❌ Stripped |
| Documentation Pages | ✅ Generated | ❌ Skipped |
| Examples | ✅ Included | ❌ Excluded |
| File Size | ~430KB+ per StructureDefinition | ~10KB per StructureDefinition |
| Database Compatibility | ⚠️ May exceed VARCHAR limits | ✅ Fits in VARCHAR(4000) |
| Use Case | Human documentation | Server implementation |

## Configuration Parameters

### Full Package (sushi-config.yaml)
- Uses default IG Publisher settings
- Generates complete HTML documentation
- Includes all narrative content

### Minimal Package (sushi-config-minimal.yaml)
- Uses IG Publisher CLI flag `-generation-off` to disable narrative generation
- No `pages` section - No HTML documentation
- No `menu` section - No navigation menus
- Identical resource generation, but without HTML narratives

## GitHub Actions Integration

The CI/CD pipeline builds both packages in parallel:

### Jobs
1. **`build-full`** - Builds full documentation package
2. **`build-minimal`** - Builds minimal server package

### Artifacts
- **Full Package**: Published to GitHub Pages
- **Minimal Package**: Published to NPM with `-minimal` suffix
- **Both**: Included in GitHub releases

### Usage
```yaml
# For GitHub Pages deployment
needs: build-full
artifact: fhir-package-full

# For NPM package (servers)
needs: build-minimal  
artifact: fhir-package-minimal
```

## Local Development

### Build Both Packages
```bash
# Build full documentation package
make build

# Build minimal server package
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
- Simplifier.net publishing

### For FHIR Servers
Use the **minimal package** for:
- HAPI FHIR servers
- Validation engines
- Automated processing
- Database loading

## Troubleshooting

### Database VARCHAR Errors
If you encounter database errors with large resources:
- Use the **minimal package** instead
- The minimal package strips narratives to fit VARCHAR(4000) limits
- All validation and structural information is preserved

### Build Failures
- Check that both `sushi-config.yaml` and `sushi-config-minimal.yaml` have same version
- Ensure Docker container has access to both config files
- Verify IG Publisher parameters are correct for each build type

## File Structure
```
project/
├── sushi-config.yaml          # Full documentation build
├── sushi-config-minimal.yaml  # Minimal server build
├── output/                    # Full package output
├── output-minimal/           # Minimal package output
├── Makefile                  # Build scripts
└── .github/workflows/        # CI/CD configuration
```

This approach ensures you get the best of both worlds: beautiful documentation for humans and efficient packages for servers.