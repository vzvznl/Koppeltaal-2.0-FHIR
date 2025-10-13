# Koppeltaal-2.0-FHIR

FHIR resource profiles for Koppeltaal 2.0 implementation.

Deze repository is gekoppeld aan https://simplifier.net/koppeltaalv2.0 en houdt deze in sync.
Simplifier importeert alleen xml, json, images, css, yaml en markdown file types.

----

## Koppeltaal v2.0

The objective of the Koppeltaal foundation includes a limitation for the exchange of data by means of the word 'internal'. This limitation means that data exchange always takes place under the responsibility of one healthcare provider.

Data is exchanged between different type of applications. In Koppeltaal, the term 'application' refers to all forms of ICT systems and eHealth platforms that are relevant for a healthcare provider to exchange data in the context of eHealth activities. The applications are provided by various vendors. These suppliers can unlock their services via Koppeltaal under the responsibility of the healthcare provider.

All FHIR resources of one healthcare provider can be accessed via the Koppeltaal (FHIR Resource) Provider for those service-providing applications that are connected to Koppeltaal. We use common concepts and standards that are based on HL7/FHIR.

<<<<<<< HEAD
=======
## Build Process

This project uses a **dual-build approach** to generate two different packages from the same source:

1. **Full Documentation Package** - For GitHub Pages and human consumption
2. **Minimal Server Package** - For HAPI FHIR servers (solves VARCHAR(4000) database issues)

See [BUILD.md](BUILD.md) for detailed technical information.

### Prerequisites

#### Using Docker (Recommended)
- Docker installed on your system
- Environment variables: `FHIR_EMAIL` and `FHIR_PASSWORD` for Simplifier.net authentication

#### Local Development (Without Docker)
If you prefer to run the build process locally without Docker, you'll need:
- Java runtime (for FHIR publisher)
- FHIR CLI tools
- Make
- Python 3
- Node.js and npm
- Environment variables: `FHIR_EMAIL` and `FHIR_PASSWORD` for Simplifier.net authentication

### Quick Start with Docker

The easiest way to build the project is using Docker, which includes all necessary dependencies.

#### Build the Docker image

```bash
docker build . -t koppeltaal-builder
```

#### Run the builds

```bash
# Build full documentation package
docker run -e FHIR_EMAIL=your-email -e FHIR_PASSWORD=your-password -v ${PWD}:/src koppeltaal-builder

# Build minimal server package (solves VARCHAR(4000) database issues)
docker run -e FHIR_EMAIL=your-email -e FHIR_PASSWORD=your-password -v ${PWD}:/src koppeltaal-builder build-minimal
```

### Using the Makefile

The Makefile provides several targets to manage the build process. You can run these either locally (if you have all prerequisites) or through Docker.

#### Available Targets

| Target | Description | Docker Command |
|--------|-------------|----------------|
| `build` | Full documentation package (default) | `docker run -e FHIR_EMAIL=... -e FHIR_PASSWORD=... -v ${PWD}:/src koppeltaal-builder` |
| `build-minimal` | Minimal server package | `docker run -e FHIR_EMAIL=... -e FHIR_PASSWORD=... -v ${PWD}:/src koppeltaal-builder build-minimal` |
| `build-ig` | Build Implementation Guide only | `docker run -e FHIR_EMAIL=... -e FHIR_PASSWORD=... -v ${PWD}:/src koppeltaal-builder build-ig` |
| `version` | Show current version | `docker run -v ${PWD}:/src koppeltaal-builder version` |
| `publish` | Publish to Simplifier.net | `docker run -e FHIR_EMAIL=... -e FHIR_PASSWORD=... -v ${PWD}:/src koppeltaal-builder publish` |
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
docker run -it --entrypoint /bin/bash -e FHIR_EMAIL=your-email -e FHIR_PASSWORD=your-password -v ${PWD}:/src koppeltaal-builder
```

#### Local Development

If you have all prerequisites installed locally, you can run Make commands directly:

```bash
# Set environment variables
export FHIR_EMAIL=your-email
export FHIR_PASSWORD=your-password

# Build full documentation package
make build

# Build minimal server package
make build-minimal

# Show version
make version

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

### Development Workflow with Pull Requests

#### Recommended Development Process

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Edit FHIR profiles, extensions, or other resources
   - Update version in `sushi-config.yaml` if needed
   - Test locally using Docker or Make commands

3. **Push to GitHub**
   ```bash
   git push origin feature/your-feature-name
   ```
   - CI automatically builds and validates your changes
   - Creates a pre-release with minimal package for testing

4. **Create Pull Request**
   - Open PR from your feature branch to `main`
   - CI runs validation on the PR
   - Review the build artifacts and test results
   - Get code review from team members

5. **Merge to Main**
   - Once approved, merge the PR to `main`
   - CI automatically:
     - Builds both full and minimal packages
     - Creates a stable GitHub release
     - Publishes to GitHub Packages
     - Deploys documentation to GitHub Pages

6. **Manual Publish to Simplifier** (when ready)
   - Navigate to Actions tab in GitHub
   - Select "Publish to Simplifier.net" workflow
   - Click "Run workflow" on main branch
   - Provide a reason for publishing
   - Monitor the workflow for successful completion

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

## Technical Details

- **Single Source**: Uses one `sushi-config.yaml` for both builds
- **Dual Output**: Generates both full and minimal packages
- **Database Compatible**: Minimal package solves VARCHAR(4000) constraint issues
- **Package ID**: `koppeltaalv2.00` to match Simplifier registry
- **CI/CD**: Automated builds and releases via GitHub Actions

For complete technical details, see [BUILD.md](BUILD.md).
>>>>>>> e613ab877192ed378c774c007be462dea915bee8
