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
	@echo "Installing dependencies from sushi-config.yaml..."
	@python3 scripts/get_dependencies.py | while read pkg; do \
		echo "Installing $$pkg..."; \
		fhir install $$pkg; \
		fhir extract-package $$pkg; \
		fhir inflate --package $$pkg; \
	done

# Build Implementation Guide (Full with documentation)
.PHONY: build-ig
build-ig:
	@echo "Building Full Implementation Guide with version $(VERSION)..."
	java -jar /usr/local/publisher.jar -ig ig.ini
	@echo "Fixing extension version references..."
	@python3 scripts/fix_extension_versions.py output
	@if [ ! -f ./output/package.tgz ]; then \
		echo "ERROR: Build did not create ./output/package.tgz"; \
		exit 1; \
	fi
	@echo "Copying package.tgz to: ./output/koppeltaalv2-$(VERSION).tgz"
	@cp ./output/package.tgz ./output/koppeltaalv2-$(VERSION).tgz
	@echo "Successfully created: ./output/koppeltaalv2-$(VERSION).tgz"

# Build Implementation Guide (Minimal for servers with snapshots)
# This target creates a minimal FHIR package optimized for FHIR server deployment by:
# 1. Using SUSHI/IG Publisher to generate resources with snapshots
# 2. Converting IG Publisher output back to package.json using Python script
# 3. Stripping only narratives and mappings while keeping snapshots
# 4. Creating final package without regenerating snapshots
.PHONY: build-ig-minimal
build-ig-minimal: install-dependencies build-ig convert-ig-minimal pack-minimal

# Convert ImplementationGuide back to package.json for minimal package using Python script
.PHONY: convert-ig-minimal
convert-ig-minimal:
	@echo "Converting ImplementationGuide to minimal package.json using Python script..."
	@python3 scripts/convert_ig_to_package.py output/ImplementationGuide-koppeltaalv2.00.json package.json

# Pack FHIR resources for minimal package using Firely CLI (keeping snapshots, removing only narratives/mappings)
.PHONY: pack-minimal
pack-minimal:
	@echo "Creating minimal FHIR package with snapshots retained..."
	@mkdir -p output-minimal
	@echo "Restoring package dependencies..."
	$(FHIR) restore
	@echo "Copying FHIR resources from output to output-minimal..."
	@find output -name "*.json" -type f -not -name "*usage-stats*" -not -name "*qa*" -not -name "*manifest*" -not -name "*fragment*" -not -name "*canonicals*" -not -name "*list*" -not -name "*expansions*" -exec cp {} output-minimal/ \;
	@echo "Stripping narratives and mappings from FHIR resources (keeping snapshots)..."
	@python3 scripts/strip_narratives.py output-minimal/ --keep-snapshots
	@echo "Verifying minimal package creation..."
	@if [ -f output-minimal/StructureDefinition-KT2Patient.json ]; then \
		SIZE=$$(wc -c < output-minimal/StructureDefinition-KT2Patient.json); \
		echo "StructureDefinition-KT2Patient.json is $$SIZE bytes (with snapshots retained)"; \
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
	@cd output-minimal && tar -czf koppeltaalv2.$(VERSION).tgz package/
	@echo "Verifying minimal package was created..."
	@if ! ls output-minimal/*.tgz >/dev/null 2>&1; then \
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

# Publish package to Simplifier.net
.PHONY: publish
publish: build-ig login
	@echo "Publishing package to Simplifier.net..."
	cd fsh-generated/resources && $(FHIR) bake
	@echo "Copying package.json to fsh-generated/resources..."
	cp package.json fsh-generated/resources/package.json
	@echo "Restoring package dependencies..."
	cd fsh-generated/resources && $(FHIR) restore
	cd fsh-generated/resources && $(FHIR) pack
	cd fsh-generated/resources && $(FHIR) publish-package koppeltaalv2.00.$(VERSION).tgz
	@echo "✅"
#	@echo "Publishing project to Simplifier.net..."
#	@echo "Cloning Simplifier project..."
#	$(FHIR) project clone koppeltaalv2.0 koppeltaalv2.0
#	@echo "Copying resources..."
#	@cp README.md koppeltaalv2.0/
#	@cp CHANGELOG.md koppeltaalv2.0/
#	@cp package.json koppeltaalv2.0/
#	@rm -Rf koppeltaalv2.0/resources
#	@mkdir -p koppeltaalv2.0/resources
#	@cp -r fsh-generated/resources/* koppeltaalv2.0/resources/
#	@echo "Pushing to Simplifier..."
#	cd koppeltaalv2.0 && $(FHIR) project status && $(FHIR) project push
#	@echo "Successfully published to Simplifier.net"

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
	@echo "  build-minimal - Build minimal package with snapshots but without narratives/mappings (for FHIR servers)"
	@echo "  login    - Login to FHIR registry"
	@echo "  install-dependencies  - Install FHIR dependencies"
	@echo "  build-ig - Build Implementation Guide using FHIR publisher (full)"
	@echo "  build-ig-minimal - Build Implementation Guide using FHIR publisher (minimal)"
	@echo "  publish  - Publish package to Simplifier.net (requires login)"
	@echo "  version  - Show the current version from sushi-config.yaml"
	@echo "  clean    - Clean build artifacts (not implemented)"
	@echo "  help     - Show this help message"
