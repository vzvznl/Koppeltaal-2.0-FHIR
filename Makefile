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

# Build Implementation Guide (Minimal for servers using original FSH approach)
# This target creates a minimal FHIR package optimized for FHIR server deployment by:
# 1. Using SUSHI/IG Publisher to generate resources first
# 2. Converting IG Publisher output back to package.json using Python script
# 3. Using Firely CLI pack to create final package (original working approach from commit 13d0e43)
.PHONY: build-ig-minimal
build-ig-minimal: install-dependencies build-ig convert-ig-minimal pack-minimal

# Convert ImplementationGuide back to package.json for minimal package using Python script
.PHONY: convert-ig-minimal
convert-ig-minimal:
	@echo "Converting ImplementationGuide to minimal package.json using Python script..."
	@python3 scripts/convert_ig_to_package.py output/ImplementationGuide-koppeltaalv2.00.json package.json

# Pack FHIR resources for minimal package using Firely CLI with snapshot stripping
.PHONY: pack-minimal
pack-minimal:
	@echo "Creating minimal FHIR package using Firely CLI (without snapshots)..."
	@mkdir -p output-minimal
	@echo "Restoring package dependencies..."
	$(FHIR) restore
	@echo "Copying FHIR resources from output to output-minimal..."
	@find output -name "*.json" -type f -not -name "*usage-stats*" -not -name "*qa*" -not -name "*manifest*" -not -name "*fragment*" -not -name "*canonicals*" -not -name "*list*" -not -name "*expansions*" -exec cp {} output-minimal/ \;
	@echo "Stripping narratives, snapshots, and mappings from FHIR resources..."
	@python3 scripts/strip_narratives.py output-minimal/
	@echo "Verifying stripping was successful..."
	@if [ -f output-minimal/StructureDefinition-KT2Patient.json ]; then \
		SIZE=$$(wc -c < output-minimal/StructureDefinition-KT2Patient.json); \
		if [ $$SIZE -gt 50000 ]; then \
			echo "ERROR: StructureDefinition-KT2Patient.json is still $$SIZE bytes (should be < 50KB after stripping)"; \
			exit 1; \
		fi; \
		echo "SUCCESS: StructureDefinition-KT2Patient.json is $$SIZE bytes (properly stripped)"; \
	fi
	@echo "Copying package.json to output-minimal..."
	@cp package.json output-minimal/
	@echo "Creating minimal package manually (avoiding Firely CLI snapshot regeneration)..."
	@echo "Preparing package structure..."
	@mkdir -p output-minimal/package
	@echo "Moving stripped JSON files to package directory..."
	@find output-minimal -maxdepth 1 -name "*.json" -type f ! -name "package.json" -exec mv {} output-minimal/package/ \;
	@echo "Moving package.json to package directory..."
	@mv output-minimal/package.json output-minimal/package/
	@echo "Creating .index.json..."
	@cd output-minimal && python3 ../scripts/create_index.py
	@echo "Creating package tarball..."
	@cd output-minimal && tar -czf koppeltaal.$(VERSION).tgz package/
	@echo "Verifying minimal package was created..."
	@if [ ! -f output-minimal/*.tgz ]; then \
		echo "ERROR: Minimal package creation failed - no .tgz file found"; \
		exit 1; \
	fi
	@echo "Renaming generated package for GitHub Actions compatibility..."
	@cd output-minimal && \
	for file in *.tgz; do \
		if [ -f "$$file" ]; then \
			cp "$$file" package.tgz; \
			cp "$$file" koppeltaalv2-$(VERSION)-minimal.tgz; \
			break; \
		fi; \
	done
	@echo "Successfully created minimal FHIR package: ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz"
	@echo "Package also available as: ./output-minimal/package.tgz"
	@echo "Final package size: $$(du -h ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz | cut -f1)"
	@echo "Package structure matches working Simplifier format - ready for HAPI FHIR deployment"

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
