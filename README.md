# Koppeltaal-2.0-FHIR

FHIR resource profiles for Koppeltaal 2.0 implementation.

Deze repository is gekoppeld aan https://simplifier.net/koppeltaalv2.0 en houdt deze in sync.
Simplifier importeert alleen xml, json, images, css, yaml en markdown file types.

----

## Koppeltaal v2.0

The objective of the Koppeltaal foundation includes a limitation for the exchange of data by means of the word 'internal'. This limitation means that data exchange always takes place under the responsibility of one healthcare provider.

Data is exchanged between different type of applications. In Koppeltaal, the term 'application' refers to all forms of ICT systems and eHealth platforms that are relevant for a healthcare provider to exchange data in the context of eHealth activities. The applications are provided by various vendors. These suppliers can unlock their services via Koppeltaal under the responsibility of the healthcare provider.

All FHIR resources of one healthcare provider can be accessed via the Koppeltaal (FHIR Resource) Provider for those service-providing applications that are connected to Koppeltaal. We use common concepts and standards that are based on HL7/FHIR.

## Build Process

This project uses a **dual-build approach** to generate two different packages from the same source:

1. **Full Documentation Package** - For GitHub Pages and human consumption
2. **Minimal Server Package** - For HAPI FHIR servers (solves VARCHAR(4000) database issues)

See [BUILD.md](BUILD.md) for detailed technical information.

### Prerequisites

#### Using Docker (Recommended)
- Docker installed on your system

#### Local Development (Without Docker)
If you prefer to run the build process locally without Docker, you'll need:
- Java runtime (for FHIR publisher)
- FHIR CLI tools
- Make
- Python 3
- Node.js and npm

#### Publishing to Simplifier.net
Only required if you need to publish packages to Simplifier.net:
- Environment variables: `FHIR_EMAIL` and `FHIR_PASSWORD` for Simplifier.net authentication

### Quick Start with Docker

The easiest way to build the project is using Docker, which includes all necessary dependencies.

#### Build the Docker image

```bash
docker build . -t koppeltaal-builder
```

#### Run the builds

```bash
# Build full documentation package (no credentials needed)
docker run -v ${PWD}:/src koppeltaal-builder

# Build minimal server package (no credentials needed)
docker run -v ${PWD}:/src koppeltaal-builder build-minimal
```

### Using the Makefile

The Makefile provides several targets to manage the build process. You can run these either locally (if you have all prerequisites) or through Docker.

#### Available Targets

| Target | Description | Docker Command |
|--------|-------------|----------------|
| `build` | Full documentation package (default) | `docker run -v ${PWD}:/src koppeltaal-builder` |
| `build-minimal` | Minimal server package | `docker run -v ${PWD}:/src koppeltaal-builder build-minimal` |
| `build-ig` | Build Implementation Guide only | `docker run -v ${PWD}:/src koppeltaal-builder build-ig` |
| `version` | Show current version | `docker run -v ${PWD}:/src koppeltaal-builder version` |
| `publish` | Publish to Simplifier.net (requires credentials) | `docker run -e FHIR_EMAIL=... -e FHIR_PASSWORD=... -v ${PWD}:/src koppeltaal-builder publish` |
| `help` | Display available targets | `docker run -v ${PWD}:/src koppeltaal-builder help` |

### Build Output

The build process creates two different packages:

#### Full Documentation Package
- **Location**: `output/koppeltaalv2-{VERSION}.tgz`
- **Purpose**: GitHub Pages, human documentation
- **Features**: Complete HTML documentation, full snapshots
- **Size**: Larger due to complete narratives and snapshots

#### Minimal Server Package
- **Location**: `output-minimal/koppeltaalv2-{VERSION}-minimal.tgz`
- **Purpose**: HAPI FHIR server deployment
- **Features**: Differential-only StructureDefinitions, no narratives
- **Size**: ~184KB (optimized for database constraints)

### Package Selection Guide

#### Use Full Package For:
- Documentation websites
- GitHub Pages
- Human-readable guides
- Complete IG Publisher output

#### Use Minimal Package For:
- HAPI FHIR server deployment ✅
- Production FHIR servers
- Automated processing
- Database loading (solves VARCHAR(4000) errors)

**HAPI Configuration Example:**
```yaml
implementationguides:
  kt2:
    name: koppeltaalv2.00  # Must match Simplifier package name
    version: 1.4.5-beta.005
    packageUrl: https://github.com/{owner}/Koppeltaal-2.0-FHIR/releases/download/v1.4.5-beta.002/koppeltaalv2-1.4.5-beta.005-minimal.tgz
    fetchDependencies: false
    installMode: STORE_AND_INSTALL
```

### Troubleshooting

#### VARCHAR(4000) Database Errors
**Problem**: `value too long for type character varying(4000)`

**Solution**: 
- ✅ Use the **minimal package** (`koppeltaalv2-{VERSION}-minimal.tgz`)
- ❌ Don't use the full package for HAPI FHIR servers

The minimal package strips snapshots and narratives to match the working Simplifier format.

### Advanced Usage

#### Interactive Shell

For debugging or manual operations, you can access an interactive shell:

```bash
# No credentials needed for exploration
docker run -it --entrypoint /bin/bash -v ${PWD}:/src koppeltaal-builder

# With credentials (only if you need to publish)
docker run -it --entrypoint /bin/bash -e FHIR_EMAIL=your-email -e FHIR_PASSWORD=your-password -v ${PWD}:/src koppeltaal-builder
```

#### Local Development

If you have all prerequisites installed locally, you can run Make commands directly:

```bash
# Build full documentation package (no credentials needed)
make build

# Build minimal server package (no credentials needed)
make build-minimal

# Show version (no credentials needed)
make version

# Publish to Simplifier.net (requires credentials)
export FHIR_EMAIL=your-email
export FHIR_PASSWORD=your-password
make publish

# Other targets
make help
```

#### File Size Verification

To verify the minimal package is properly stripped:

```bash
# Check that minimal files are ~1KB (not 8KB)
du -h output-minimal/package/ext-KT2CorrelationId.json

# Compare package sizes
du -h output/koppeltaalv2-*.tgz          # Full package
du -h output-minimal/koppeltaalv2-*.tgz  # Minimal package (should be ~184KB)
```

## Contributing

**Want to contribute?** See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Step-by-step development workflow
- How to create feature branches and pull requests
- Testing your changes with Docker
- VSCode-specific instructions and tips
- Git best practices
- Troubleshooting common issues

## GitHub Workflows and CI/CD

### Workflow Overview

This repository uses GitHub Actions for continuous integration and deployment:

1. **Build and Deploy Workflow** (`build_deploy.yml`)
   - Triggers automatically on every push to any branch
   - Builds both full documentation and minimal server packages
   - Publishes packages to GitHub Packages (NPM registry)
   - Creates GitHub releases for main branch
   - Deploys documentation to GitHub Pages (main branch only)

2. **Publish to Simplifier Workflow** (`publish_simplifier.yml`)
   - **Manual trigger only** from the main branch
   - Requires explicit user action via GitHub Actions UI
   - Publishes the FHIR package to Simplifier.net
   - Uses stored credentials for authentication

### Publishing to Simplifier.net

**Important**: Publishing to Simplifier.net is a **manual process** that must be triggered explicitly:

1. **Prerequisites**:
   - Changes must be merged to `main` branch
   - GitHub secrets `FHIR_EMAIL` and `FHIR_PASSWORD` must be configured in repository settings:
     - Go to repository **Settings** → **Secrets and variables** → **Actions**
     - Add `FHIR_EMAIL` with your Simplifier.net email
     - Add `FHIR_PASSWORD` with your Simplifier.net password

2. **How to Publish**:
   - Go to the [Actions tab](../../actions) in GitHub
   - Select "Publish to Simplifier.net" from the workflow list
   - Click "Run workflow"
   - Select `main` branch (only option available)
   - Enter a reason for publishing
   - Click "Run workflow" button

3. **What Happens**:
   - Builds the Implementation Guide
   - Runs `fhir bake`, `fhir pack`, and `fhir publish-package` in sequence
   - Publishes to the configured Simplifier.net project

**Note**: This publishing process covers the installation of the package in Simplifier.net. 
It does **not** include:
 - Updating the resources on Simplifier.net
 - Updating the Implementation Guide on Simplifier.net.

#### Updating Resources on Simplifier.net 
The reason for this is that Simplifier.net does not support updating the resources and implementation guide with the command line tools, but in practice this turned out to cause problems. Therefore, we suggest updating the resources and implementation guide manually.

The manual steps for updating the resources on Simplifier are:
```bash
echo "Publishing project to Simplifier.net..."
echo "Cloning Simplifier project..."
fhir project clone koppeltaalv2.0 koppeltaalv2.0
echo "Copying resources..."
cp README.md koppeltaalv2.0/
cp CHANGELOG.md koppeltaalv2.0/
cp package.json koppeltaalv2.0/
rm -Rf koppeltaalv2.0/resources
mkdir -p koppeltaalv2.0/resources
cp -r fsh-generated/resources/* koppeltaalv2.0/resources/
echo "Pushing to Simplifier..."
cd koppeltaalv2.0 && $(FHIR) project status && $(FHIR) project push
echo "Successfully published to Simplifier.net" 
```

#### Updating the Implementation Guide on Simplifier.net
Updating the implementation guide is done by hand in the Simplifier UI.
### Release Types

#### Main Branch Releases (Stable)
When pushed to `main` branch:
- **Full Release**: Contains both full and minimal packages
- **Release Name**: Version number (e.g., `1.4.5`)
- **Tag**: `v{version}` (e.g., `v1.4.5`)
- **Assets**:
  - `koppeltaalv2-{version}.tgz` - Full documentation package
  - `koppeltaalv2-{version}-minimal.tgz` - Minimal server package

#### Branch Pre-releases (Testing)
When pushed to any other branch:
- **Pre-release**: Only contains minimal package
- **Release Name**: `{version}-minimal-{branch-name}`
- **Tag**: `v{version}-minimal-{branch-name}-{run-number}`
- **Assets**:
  - `koppeltaalv2-{version}-minimal.tgz` - Minimal server package only

### Package URLs

#### For Stable Releases
```yaml
# Minimal package (recommended for HAPI)
packageUrl: https://github.com/{owner}/{repo}/releases/download/v{version}/koppeltaalv2-{version}-minimal.tgz

# Full package (for documentation)
packageUrl: https://github.com/{owner}/{repo}/releases/download/v{version}/koppeltaalv2-{version}.tgz
```

**Example (GIDSOpenStandaarden):**
```yaml
# Minimal package
packageUrl: https://github.com/GIDSOpenStandaarden/Koppeltaal-2.0-FHIR/releases/download/v1.4.5/koppeltaalv2-1.4.5-minimal.tgz
```

#### For Pre-releases
```yaml
# Pattern
packageUrl: https://github.com/{owner}/{repo}/releases/download/v{version}-minimal-{branch}-{run}/koppeltaalv2-{version}-minimal.tgz

# Example (test-beta-release branch, run 82)
packageUrl: https://github.com/GIDSOpenStandaarden/Koppeltaal-2.0-FHIR/releases/download/v1.4.5-beta.002-minimal-test-beta-release-82/koppeltaalv2-1.4.5-beta.005-minimal.tgz
```

### GitHub Packages (NPM)
The CI/CD also publishes to GitHub Packages:
- **Main branch**: Public access
- **Other branches**: Restricted access
- **Package names**: Scoped to repository owner (e.g., `@{owner}/koppeltaalv2.00`)

## FHIR Package Synchronization and Testing

This repository includes scripts for synchronizing FHIR package resources to HAPI FHIR servers and running smoke tests.

### FHIR Package Synchronization Script

The `sync-fhir-package.py` script synchronizes all FHIR package resources to a HAPI FHIR server, ensuring consistency and handling special requirements for different resource types.

**Features:**
- Downloads and extracts FHIR packages (.tgz) from URLs
- Detects discrepancies: missing resources, wrong IDs, wrong versions, duplicates
- Synchronizes resources by deleting duplicates and PUTting correct versions
- Handles optimistic locking via resource history
- Special handling for ImplementationGuide resources:
  - Strips IG Publisher-specific `definition.parameter` entries
  - Removes example resources from `definition.resource` (keeps only conformance resources)
- Supports Bearer token authentication
- Interactive confirmation before making changes

**Commands:**
```bash
# Detect discrepancies between package and server
python3 scripts/sync-fhir-package.py detect {fhir_base_url} {package_url} [bearer_token]

# Synchronize package resources to server
python3 scripts/sync-fhir-package.py sync {fhir_base_url} {package_url} [bearer_token]
```

**Examples:**
```bash
# Detect discrepancies on localhost
python3 scripts/sync-fhir-package.py detect http://localhost:8080/fhir/DEFAULT https://github.com/vzvznl/Koppeltaal-2.0-FHIR/releases/download/v0.15.0-beta.7a/koppeltaalv2-0.15.0-beta.7a.tgz

# Synchronize to staging server with authentication
python3 scripts/sync-fhir-package.py sync https://staging-fhir-server.koppeltaal.headease.nl/fhir/DEFAULT https://github.com/vzvznl/Koppeltaal-2.0-FHIR/releases/download/v0.15.0-beta.7a/koppeltaalv2-0.15.0-beta.7a.tgz "eyJhbGciOi..."
```

**Common Issues Detected:**
- Missing resources (resource not found on server)
- Wrong resource ID (server has different ID than package)
- Wrong version (server has different version than package)
- Duplicate resources (same canonical URL with multiple IDs or versions)

### Smoke Tests

Automated smoke tests verify that no duplicate versions exist on the FHIR server. These are generated as part of the test resource generation process.

**Generate smoke tests:**
```bash
python3 scripts/generate_test_resources.py
```

This creates:
- `test-resources/smoke-tests/smoke-tests.sh` - Executable test script
- `test-resources/smoke-tests/version-check-data.json` - Test data with all resources to check

**Run smoke tests:**
```bash
# Test localhost
./test-resources/smoke-tests/smoke-tests.sh http://localhost:8080/fhir/DEFAULT

# Test with authentication
./test-resources/smoke-tests/smoke-tests.sh https://prod.example.com/fhir/DEFAULT "eyJhbGciOi..."
```

**Output:**
```
✓ StructureDefinition/KT2Patient - Single version found (version: 0.15.0-beta.6a)
✓ CodeSystem/koppeltaal-expansion - Single version found (version: 0.15.0-beta.6a)
✗ ImplementationGuide/koppeltaalv2.00 - Found 2 versions (expected 1)

Smoke Test Results:
Passed: 23
Failed: 1
Total: 24
```

**CI/CD Integration:**
The smoke tests are automatically run as part of the `run-fhir-tests.yml` workflow before the main Newman tests. Results are displayed in the workflow summary with actionable cleanup commands.

### Resources Synchronized

The sync-fhir-package.py script synchronizes all resources from the FHIR package, including:

| Resource Type | Count | Examples |
|--------------|-------|----------|
| StructureDefinition | 11 | KT2Patient, KT2Practitioner, KT2Organization, etc. |
| CodeSystem | 6 | koppeltaal-expansion, koppeltaal-endpoint-connection-type, etc. |
| ValueSet | 6 | koppeltaal-expansion, koppeltaal-task-code, etc. |
| ImplementationGuide | 1 | koppeltaalv2.00 |
| **Total** | **24** | |

## Technical Details

- **Single Source**: Uses one `sushi-config.yaml` for both builds
- **Dual Output**: Generates both full and minimal packages
- **Database Compatible**: Minimal package solves VARCHAR(4000) constraint issues
- **Package ID**: `koppeltaalv2.00` to match Simplifier registry
- **CI/CD**: Automated builds and releases via GitHub Actions

For complete technical details, see [BUILD.md](BUILD.md).
