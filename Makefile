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
# This target creates a minimal FHIR package optimized for FHIR server deployment by:
# 1. Taking the full package created by build-ig
# 2. Stripping .text (narratives), .snapshot, .jurisdiction, .language, .mapping
# 3. Removing most examples to reduce package size
# 4. Optimizing files for HAPI FHIR varchar(4000) constraint
.PHONY: build-ig-minimal
build-ig-minimal: build-ig
	@echo "Creating minimal package from full build..."
	@mkdir -p output-minimal
	@if [ ! -f ./output/package.tgz ]; then \
		echo "ERROR: Full build package not found at ./output/package.tgz"; \
		exit 1; \
	fi
	@echo "Stripping narratives from FHIR resources..."
	@mkdir -p temp-package
	@cd temp-package && tar -xzf ../output/package.tgz
	@echo "Original package size before stripping: $$(du -h ../output/package.tgz | cut -f1)"
	@ORIG_LARGE_FILES=$$(find temp-package -name "*.json" -exec wc -c {} \; | awk '$$1 > 4000 {print $$2}' | wc -l); \
	echo "Original files over 4000 characters: $$ORIG_LARGE_FILES"
	@echo "Processing StructureDefinition files (removing narratives only - keeping snapshots like original)..."
	@find temp-package -name "StructureDefinition-*.json" -exec sh -c 'if ! jq "del(.text)" "$$1" > "$$1.tmp"; then echo "ERROR: Failed to process $$1"; exit 1; fi && mv "$$1.tmp" "$$1"' _ {} \;
	@echo "Processing ImplementationGuide files (creating minimal skeleton like original)..."
	@find temp-package -name "ImplementationGuide-*.json" -exec sh -c 'if jq "{resourceType: .resourceType, id: .id, url: .url, version: .version, name: .name, status: .status, experimental: .experimental, date: .date, publisher: .publisher, packageId: .packageId, fhirVersion: .fhirVersion, dependsOn: .dependsOn}" "$$1" > "$$1.tmp"; then mv "$$1.tmp" "$$1"; else echo "ERROR: Failed to process $$1"; exit 1; fi' _ {} \;
	@echo "Processing other FHIR resource files..."
	@find temp-package -name "*.json" -not -name "package.json" -not -name "StructureDefinition-*.json" -not -name "ImplementationGuide-*.json" -exec sh -c 'if ! jq "del(.text)" "$$1" > "$$1.tmp"; then echo "ERROR: Failed to process $$1"; exit 1; fi && mv "$$1.tmp" "$$1"' _ {} \;
	@echo "Removing validation and other large files that cause database issues..."
	@rm -rf temp-package/other/ || true
	@rm -f temp-package/.index.json || true
	@echo "Checking file sizes after stripping..."
	@LARGE_FILES=$$(find temp-package -name "*.json" -exec wc -c {} \; | awk '$$1 > 4000 {print $$2}' | wc -l); \
	if [ $$LARGE_FILES -gt 0 ]; then \
		echo "INFO: $$LARGE_FILES files still exceed 4000 characters (expected for StructureDefinitions):"; \
		find temp-package -name "*.json" -exec wc -c {} \; | awk '$$1 > 4000 {print $$1 " " $$2}' | head -10; \
	else \
		echo "All files are within 4000 character limit"; \
	fi
	@echo "Validating JSON integrity after stripping..."
	@find temp-package -name "*.json" -exec sh -c 'if ! jq empty "$$1" >/dev/null 2>&1; then echo "ERROR: Invalid JSON after processing: $$1"; exit 1; fi' _ {} \;
	@echo "All JSON files are valid"
	@echo "Removing most examples (keeping only essential ones)..."
	@find temp-package -path "*/example/*" -name "*.json" -not -name "namingsystem-koppeltaal-client-id.json" -delete || true
	@cd temp-package && tar -czf ../output-minimal/package.tgz package/
	@rm -rf temp-package
	@echo "Copying package.tgz to: ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz"
	@cp ./output-minimal/package.tgz ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz
	@echo "Successfully created minimal package with narratives stripped: ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz"
	@echo "Final package size: $$(du -h ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz | cut -f1)"
	@echo "Files in package: $$(tar -tzf ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz | wc -l)"
	@echo "Stripping process completed - package optimized for FHIR server deployment"

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
