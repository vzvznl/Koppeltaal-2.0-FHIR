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
# 2. Converting from IG Publisher format to Firely CLI export format
# 3. Renaming files to match working Simplifier package structure
# 4. Creating minimal package.json and ImplementationGuide
.PHONY: build-ig-minimal
build-ig-minimal: build-ig
	@echo "Creating minimal FHIR resource package from IG Publisher output..."
	@mkdir -p output-minimal
	@if [ ! -f ./output/package.tgz ]; then \
		echo "ERROR: Full build package not found at ./output/package.tgz"; \
		exit 1; \
	fi
	@echo "Extracting and converting IG Publisher package to Firely CLI format..."
	@rm -rf temp-package temp-minimal
	@mkdir -p temp-package temp-minimal
	@cd temp-package && tar -xzf ../output/package.tgz
	@echo "Original package size: $$(du -h output/package.tgz | cut -f1)"
	@echo "Converting StructureDefinition files to simple naming convention..."
	@find temp-package -name "StructureDefinition-KT2*.json" -exec sh -c 'filename=$$(basename "$$1"); newname=$$(echo "$$filename" | sed "s/StructureDefinition-//"); jq "del(.text)" "$$1" > "temp-minimal/$$newname"' _ {} \;
	@echo "Creating minimal ImplementationGuide (589 bytes like working package)..."
	@find temp-package -name "ImplementationGuide-*.json" -exec sh -c 'jq "{resourceType: .resourceType, id: (.id | sub(\"-.*\"; \"-ig-koppeltaalv2.00\")), url: \"http://koppeltaal.nl/fhir/ImplementationGuide\", version: .version, name: \"Koppeltaal_2.0_IG\", status: \"active\", experimental: false, date: (.date | sub(\"T.*\"; \"\")), publisher: .publisher, packageId: \"koppeltaalv2.00\", fhirVersion: .fhirVersion, dependsOn: [.dependsOn[] | select(.packageId | test(\"nictiz\"))]}" "$$1" > "temp-minimal/KT2ImplementationGuide.json"' _ {} \;
	@echo "Converting extensions and other resources..."
	@find temp-package -name "StructureDefinition-KT2*Extension.json" -exec sh -c 'filename=$$(basename "$$1"); newname=$$(echo "$$filename" | sed "s/StructureDefinition-KT2/ext-KT2/" | sed "s/Extension//"); jq "del(.text)" "$$1" > "temp-minimal/$$newname"' _ {} \;
	@find temp-package -name "StructureDefinition-*.json" -not -name "StructureDefinition-KT2*" -exec sh -c 'filename=$$(basename "$$1"); newname=$$(echo "$$filename" | sed "s/StructureDefinition-/ext-KT2/"); jq "del(.text)" "$$1" > "temp-minimal/$$newname"' _ {} \;
	@echo "Converting CodeSystems and ValueSets..."
	@find temp-package -name "CodeSystem-*.json" -exec sh -c 'filename=$$(basename "$$1"); jq "del(.text)" "$$1" > "temp-minimal/$$filename"' _ {} \;
	@find temp-package -name "ValueSet-*.json" -exec sh -c 'filename=$$(basename "$$1"); jq "del(.text)" "$$1" > "temp-minimal/$$filename"' _ {} \;
	@echo "Converting SearchParameters..."
	@find temp-package -name "SearchParameter-*.json" -exec sh -c 'filename=$$(basename "$$1"); newname=$$(echo "$$filename" | sed "s/SearchParameter-/search-/"); jq "del(.text)" "$$1" > "temp-minimal/$$newname"' _ {} \;
	@echo "Copying examples..."
	@mkdir -p temp-minimal/examples
	@find temp-package -path "*/example/*" -name "*.json" -exec cp {} temp-minimal/examples/ \;
	@echo "Creating Firely CLI-style package.json..."
	@echo '{"name": "koppeltaalv2.00", "version": "$(VERSION)", "description": "Koppeltaal 2.0 FHIR resource profiles - minimal package for FHIR servers", "title": "Koppeltaal 2.0 FHIR Package", "author": "VZVZ", "fhirVersions": ["4.0.1"], "jurisdiction": "urn:iso:std:iso:3166#NL", "maintainers": [{"name": "VZVZ"}, {"name": "Koppeltaal"}], "keywords": ["VZVZ", "Koppeltaal", "GGZ"], "dependencies": {"nictiz.fhir.nl.r4.zib2020": "0.11.0-beta.1", "nictiz.fhir.nl.r4.nl-core": "0.11.0-beta.1"}}' > temp-minimal/package.json
	@echo "Creating package archive..."
	@cd temp-minimal && tar -czf ../output-minimal/package.tgz .
	@rm -rf temp-package temp-minimal
	@echo "Copying package.tgz to: ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz"
	@cp ./output-minimal/package.tgz ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz
	@echo "Successfully created minimal FHIR package: ./output-minimal/koppeltaalv2-$(VERSION)-minimal.tgz"
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
