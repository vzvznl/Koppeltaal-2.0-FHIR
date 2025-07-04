# Koppeltaal-2.0-FHIR
FHIR resource

Deze repository is gekoppeld aan https://simplifier.net/koppeltaalv2.0 en houdt deze in sync.
Simplifier importeert alleen xml, json, images, css, yaml en markdown file types.

----

Koppeltaal v2.0

The objective of the Koppeltaal foundation includes a limitation for the exchange of data by means of the word 'internal'. This limitation means that data exchange always takes place under the responsibility of one healthcare provider.

Data is exchanged between different type of applications. In Koppeltaal, the term 'application' refers to all forms of ICT systems and eHealth platforms that are relevant for a healthcare provider to exchange data in the context of eHealth activities. The applications are provided by various vendors. These suppliers can unlock their services via Koppeltaal under the responsibility of the healthcare provider.

All FHIR resources of one healthcare provider can be accessed via the Koppeltaal (FHIR Resource) Provider for those service-providing applications that are connected to Koppeltaal. We use common concepts and standards that are based on HL7/FHIR.

## Build Process

This project uses a Makefile to automate the FHIR Implementation Guide build process. The build system reads the version from `sushi-config.yaml` and creates a versioned package.

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

#### Run the build

```bash
# Run default build process
docker run -e FHIR_EMAIL=your-email -e FHIR_PASSWORD=your-password -v ${PWD}:/src koppeltaal-builder
```

### Using the Makefile

The Makefile provides several targets to manage the build process. You can run these either locally (if you have all prerequisites) or through Docker.

#### Available Targets

| Target | Description | Docker Command |
|--------|-------------|----------------|
| `build` | Complete build process (default) | `docker run -e FHIR_EMAIL=... -e FHIR_PASSWORD=... -v ${PWD}:/src koppeltaal-builder` |
| `build-ig` | Build Implementation Guide only | `docker run -e FHIR_EMAIL=... -e FHIR_PASSWORD=... -v ${PWD}:/src koppeltaal-builder build-ig` |
| `version` | Show current version | `docker run -v ${PWD}:/src koppeltaal-builder version` |
| `publish` | Publish to Simplifier.net | `docker run -e FHIR_EMAIL=... -e FHIR_PASSWORD=... -v ${PWD}:/src koppeltaal-builder publish` |
| `help` | Display available targets | `docker run -v ${PWD}:/src koppeltaal-builder help` |

The build process:
1. Installs FHIR dependencies (Nictiz packages)
2. Builds the Implementation Guide using the FHIR publisher
3. Creates a versioned package: `output/koppeltaalv2-{VERSION}.tgz`

### Build Output

The build process creates:
- FHIR Implementation Guide in the `output/` directory
- A versioned package file: `output/koppeltaalv2-{VERSION}.tgz`
- HTML documentation files for GitHub Pages deployment

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

# Run build
make build

# Show version
make version

# Other targets
make help
```
