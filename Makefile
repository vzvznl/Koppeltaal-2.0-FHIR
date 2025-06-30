# Makefile for FHIR build process

# Variables
FHIR := fhir
DOTNET_TOOLS := $(HOME)/.dotnet/tools

# Fetch version from package.json
export VERSION := $(shell jq -r '.version' package.json)

# Export PATH with dotnet tools
export PATH := $(PATH):$(DOTNET_TOOLS)

# Default target
.PHONY: all
all: build

# Build target
.PHONY: build
build: login install-dependencies build-ig convert-ig pack

# Login to FHIR
.PHONY: login
login:
	$(FHIR) login email=$(FHIR_EMAIL) password=$(FHIR_PASSWORD)

# Install dependencies
.PHONY: install-dependencies
install-dependencies:
	@echo "Installing nictiz packages from local zip file..."
	@mkdir -p $(HOME)/.fhir/packages
	@unzip -o nictiz-packages/nictiz.fhir.nl.r4-with-snapshots.zip -d $(HOME)/.fhir/packages/
	@echo "Nictiz packages installed successfully"

# Build Implementation Guide
.PHONY: build-ig
build-ig:
	@echo "Building Implementation Guide..."
	java -jar /src/publisher.jar -ig ig.ini

# Convert ImplementationGuide back to package.json
.PHONY: convert-ig
convert-ig:
	@echo "Converting ImplementationGuide to package.json..."
	python3 scripts/convert_ig_to_package.py output/ImplementationGuide-Koppeltaal.json package.json

# Pack FHIR resources
.PHONY: pack
pack:
	$(FHIR) pack

# Show version
.PHONY: version
version:
	@echo "Version: $(VERSION)"

# Clean target (optional)
.PHONY: clean
clean:
	@echo "Clean target not implemented - add cleanup commands if needed"

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build    - Run the complete FHIR build process (login, install, build-ig, convert-ig, pack)"
	@echo "  login    - Login to FHIR registry"
	@echo "  install-dependencies  - Install FHIR dependencies"
	@echo "  build-ig - Build Implementation Guide using FHIR publisher"
	@echo "  convert-ig  - Convert ImplementationGuide JSON back to package.json"
	@echo "  pack     - Pack FHIR resources"
	@echo "  version  - Show the current version from package.json"
	@echo "  clean    - Clean build artifacts (not implemented)"
	@echo "  help     - Show this help message"
