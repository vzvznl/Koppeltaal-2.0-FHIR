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
build: login install-dependencies convert-ig check pack

# Login to FHIR
.PHONY: login
login:
	$(FHIR) login email=$(FHIR_EMAIL) password=$(FHIR_PASSWORD)

# Install dependencies
.PHONY: install-dependencies
install-dependencies:
	$(FHIR) install nictiz.fhir.nl.r4.zib2020 0.11.0-beta.1
	$(FHIR) install nictiz.fhir.nl.r4.nl-core 0.11.0-beta.1

# Convert package.json to ImplementationGuide
.PHONY: convert-ig
convert-ig:
	@echo "Converting package.json to ImplementationGuide..."
	@mkdir -p generated-resources
	python3 scripts/convert_package_to_ig.py package.json generated-resources/KT2ImplementationGuide.gen.yaml

# Pack FHIR resources
.PHONY: pack
pack:
	$(FHIR) pack

# Check project with unit tests
.PHONY: check
check:
	@echo "Running project checks..."
	$(FHIR) check unittest

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
	@echo "  build    - Run the complete FHIR build process (login, install, pack, check)"
	@echo "  login    - Login to FHIR registry"
	@echo "  install-dependencies  - Install FHIR dependencies"
	@echo "  convert-ig  - Convert package.json to ImplementationGuide YAML"
	@echo "  pack     - Pack FHIR resources"
	@echo "  check    - Run project checks with unit tests"
	@echo "  version  - Show the current version from package.json"
	@echo "  clean    - Clean build artifacts (not implemented)"
	@echo "  help     - Show this help message"
