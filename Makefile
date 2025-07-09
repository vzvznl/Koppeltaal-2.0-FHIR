# Makefile for FHIR build process

# Variables
FHIR := fhir
DOTNET_TOOLS := $(HOME)/.dotnet/tools

# Fetch version from sushi-config.yaml with error handling
export VERSION := $(shell grep '^version:' sushi-config.yaml | sed 's/version: //' | tr -d '[:space:]')
ifeq ($(VERSION),)
$(error "Could not extract version from sushi-config.yaml")
endif

# Export PATH with dotnet tools
export PATH := $(PATH):$(DOTNET_TOOLS)

# Default target
.PHONY: all
all: build

# Build target (full documentation package)
.PHONY: build
build: install-dependencies build-ig

# Build minimal package (without narratives)
.PHONY: build-minimal
build-minimal: install-dependencies build-ig-minimal

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

# Build Implementation Guide (Full with documentation)
.PHONY: build-ig
build-ig:
	@echo "Building Full Implementation Guide with version $(VERSION)..."
	java -jar /usr/local/publisher.jar -ig ig.ini
	@if [ ! -f ./output/package.tgz ]; then \
		echo "ERROR: Build did not create ./output/package.tgz"; \
		exit 1; \
	fi
	@echo "Copying package.tgz to: ./output/koppeltaalv2-$(VERSION).tgz"
	@cp ./output/package.tgz ./output/koppeltaalv2-$(VERSION).tgz
	@echo "Successfully created: ./output/koppeltaalv2-$(VERSION).tgz"

# Build Implementation Guide (Minimal for servers)
.PHONY: build-ig-minimal
build-ig-minimal:
	@echo "Building Minimal Implementation Guide with version $(VERSION)..."
	@mkdir -p output-minimal
	@cp sushi-config-minimal.yaml sushi-config.yaml.bak
	@cp sushi-config-minimal.yaml sushi-config.yaml
	java -jar /usr/local/publisher.jar -ig ig.ini -generation-off
	@mv sushi-config.yaml.bak sushi-config.yaml
	@if [ ! -f ./output/package.tgz ]; then \
		echo "ERROR: Minimal build did not create ./output/package.tgz"; \
		exit 1; \
	fi
	@echo "Stripping narratives from FHIR resources..."
	@mkdir -p temp-package
	@cd temp-package && tar -xzf ../output/package.tgz
	@echo "Processing StructureDefinition files (removing snapshots, narratives, and metadata)..."
	@find temp-package -name "StructureDefinition-*.json" -exec sh -c 'jq "del(.text) | del(.snapshot) | del(.jurisdiction) | del(.language) | del(.mapping)" "$$1" > "$$1.tmp" && mv "$$1.tmp" "$$1"' _ {} \;
	@echo "Processing other FHIR resource files..."
	@find temp-package -name "*.json" -not -name "package.json" -not -name "StructureDefinition-*.json" -exec sh -c 'jq "del(.text)" "$$1" > "$$1.tmp" && mv "$$1.tmp" "$$1"' _ {} \; 2>/dev/null || true
	@echo "Removing most examples (keeping only essential ones)..."
	@find temp-package -path "*/example/*" -name "*.json" -not -name "namingsystem-koppeltaal-client-id.json" -delete || true
	@cd temp-package && tar -czf ../output-minimal/package.tgz package/
	@rm -rf temp-package
	@echo "Copying package.tgz to: ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz"
	@cp ./output-minimal/package.tgz ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz
	@echo "Successfully created minimal package with narratives stripped: ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz"

# Publish package to Simplifier.net, not tested.
.PHONY: publish
publish: login
	$(FHIR) publish-package ./output/koppeltaalv2-$(VERSION).tgz

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
	@echo "  build    - Run the complete FHIR build process (full documentation package)"
	@echo "  build-minimal - Build minimal package without narratives (for FHIR servers)"
	@echo "  login    - Login to FHIR registry"
	@echo "  install-dependencies  - Install FHIR dependencies"
	@echo "  build-ig - Build Implementation Guide using FHIR publisher (full)"
	@echo "  build-ig-minimal - Build Implementation Guide using FHIR publisher (minimal)"
	@echo "  publish  - Publish package to Simplifier.net (requires login)"
	@echo "  version  - Show the current version from sushi-config.yaml"
	@echo "  clean    - Clean build artifacts (not implemented)"
	@echo "  help     - Show this help message"
