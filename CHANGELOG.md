CHANGELOG

## 0.15.0-beta.2 (2025-10-21)

### Fixed
- **KT2_ActivityDefinition useContext validation**: Added required binding for feature codes in useContext.valueCodeableConcept
  - Created `KoppeltaalFeatures_VS` ValueSet to validate feature codes
  - Implemented slicing on `useContext` to discriminate by code type
  - Added `feature` slice with required binding to `KoppeltaalFeatures_VS`
  - Now properly validates that feature codes must be from `koppeltaal-features` CodeSystem
  - Prevents invalid codes like "INVALID" from passing validation

### Added
- **ValueSet**: `KoppeltaalFeatures_VS` (http://vzvz.nl/fhir/ValueSet/koppeltaal-features)
  - Includes all codes from `KoppeltaalFeatures` CodeSystem
- **Test case**: `invalid-feature-code` variant in test resource generator
  - Tests rejection of invalid feature codes in useContext.valueCodeableConcept
  - Validates that required binding on feature slice works correctly

### Technical
- Enhanced profile constraints using FHIR slicing to apply context-specific bindings
- Improved validation for ActivityDefinition useContext values based on context type

## 0.15.0-beta.1 (2025-10-16)

**Note: Changed versioning scheme from 1.4.5-beta.x to 0.15.0-beta.x to align with existing versioning system and semver requirements**

### Changed
- **Versioning scheme**: Changed from 1.4.5-beta.012 to 0.15.0-beta.1 (using hyphen for semver compatibility)
- **Nictiz dependencies**: Updated from 0.11.0-beta.1 to 0.12.0-beta.4
  - Resolves snapshot generation issues with zib-AddressInformation during HAPI FHIR package installation
  - Both `nictiz.fhir.nl.r4.zib2020` and `nictiz.fhir.nl.r4.nl-core` updated

### Added
- **scripts/get_dependencies.py**: Dynamic dependency extraction script for Makefile
  - Dependencies can now be automatically extracted from sushi-config.yaml

### Technical
- Makefile: Enhanced publish workflow with both package publishing and project synchronization
  - Maintains `bake`, `pack`, and `publish-package` with filename argument (`koppeltaalv2.00.$(VERSION).tgz`)
  - Adds project cloning from Simplifier.net
  - Copies README.md, CHANGELOG.md, and resources to Simplifier project
  - Pushes updated project back to Simplifier
- Makefile: install-dependencies now dynamically reads from sushi-config.yaml via scripts/get_dependencies.py
- KoppeltaalUsageContextType: Added clickable link to KoppeltaalFeatures CodeSystem in feature code description

## 1.4.5-beta.012 (2025-10-14)

### Fixed
- **KT2_ActivityDefinition useContext.code binding**: Changed from `extensible` to `required` to prevent invalid context type codes
  - Now only allows codes from `KoppeltaalUsageContextType_VS` valueset
  - Prevents invalid codes from being accepted
  - Closes the valueset to enforce strict validation
- **activitydefinition-with-participant example**: Corrected codesystem URL for useContext.valueCodeableConcept
  - Changed from `http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context` (invalid)
  - To `http://vzvz.nl/fhir/CodeSystem/koppeltaal-features` (correct)
- **activitydefinition-standard-usecontext example**: Corrected codesystem URL for useContext.code with feature type
  - Changed from `http://terminology.hl7.org/CodeSystem/usage-context-type#feature` (invalid - feature not in standard FHIR)
  - To `http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context-type#feature` (correct - Koppeltaal extension)

### Added
- **Test case for invalid useContext**: Added negative test case `invalid-usecontext-invalid-codes` to test resource generator
  - Tests rejection of invalid context type code ("onzin")
  - Tests rejection of invalid context value with non-existent codesystem ("Troep")
  - Validates that required binding on useContext.code works correctly

### Technical
- Strengthened validation by using required bindings instead of extensible bindings for useContext.code
- Removed unnecessary KoppeltaalUsageContextValues_VS valueset (valueCodeableConcept validation handled by FHIR naturally)

## 1.4.5-beta.011 (2025-10-09)

### Fixed
- **KoppeltaalUsageContextType_VS**: Corrected ValueSet to reference CodeSystem instead of another ValueSet
  - Changed from `http://hl7.org/fhir/ValueSet/use-context` (invalid - ValueSet URL)
  - To `http://terminology.hl7.org/CodeSystem/usage-context-type` (correct - CodeSystem URL)
  - Resolves HAPI FHIR server installation error: "Unable to expand ValueSet because CodeSystem could not be found"

### Technical
- Fixed terminology service compatibility issue that prevented package installation on HAPI FHIR servers
- ValueSets must include codes from CodeSystems, not from other ValueSets

## 1.4.5-beta.010 (2025-10-07)

### Added
- **KoppeltaalFeatures**: New CodeSystem for Koppeltaal-specific feature codes (http://vzvz.nl/fhir/CodeSystem/koppeltaal-features)
- **Code 026-RolvdNaaste**: "Rol van de naaste" feature code for relative participation support
- **activitydefinition-standard-usecontext**: New example demonstrating standard FHIR useContext usage alongside Koppeltaal-specific extensions
- **ActivityDefinition test resources**: Enhanced test resource generation to include useContext examples with age ranges and relative participation features

### Changed
- **KoppeltaalUsageContext → KoppeltaalUsageContextType**: Renamed CodeSystem to follow FHIR naming convention for usage context types
  - Updated canonical URL from `koppeltaal-usage-context` to `koppeltaal-usage-context-type`
  - Changed content from specific feature values to usage context type codes
  - Now includes standard FHIR `#feature` code instead of custom codes
- **KoppeltaalUsageContext_VS → KoppeltaalUsageContextType_VS**: Renamed ValueSet to align with CodeSystem rename
  - Updated to include codes from standard FHIR `usage-context-type` CodeSystem
  - Added codes from custom `KoppeltaalUsageContextType` CodeSystem
- **KT2_ActivityDefinition**: Updated useContext binding to reference renamed ValueSet
- **ActivityDefinition examples**: Refactored extension usage from numeric indices to named slice references (`endpoint`, `publisherId`)
- **Test resource generation**: Updated terminology references to use standard FHIR `usage-context-type#feature` instead of custom codes

### Fixed
- **Origin RuleSet**: Corrected cardinality for `KT2_ResourceOrigin` extension from `0..*` to `0..1` to align with extension definition constraints
- **Terminology alignment**: Updated usage context implementation to properly use standard FHIR codes (`feature`) for types and custom codes for values

### Technical
- Separated usage context types (standard FHIR) from feature values (Koppeltaal-specific) following FHIR architectural patterns
- Improved terminology structure to support both standard FHIR useContext (age, gender, focus) and Koppeltaal features (relative participation)

## 1.4.5-beta.009 (2025-09-11)

### Added
- **KoppeltaalUsageContextType**: New CodeSystem for custom usage context types (http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context-type)
- **KoppeltaalUsageContextType_VS**: New ValueSet for custom usage context types (http://vzvz.nl/fhir/ValueSet/koppeltaal-usage-context-type)
- **Code required-feature**: Custom usage context type for indicating technical features that applications must support

### Changed
- **KT2_ActivityDefinition**: Added required binding for useContext.code to KoppeltaalUsageContextType_VS
- **KT2_ActivityDefinition**: Updated profile version to 0.10.1
- **ActivityDefinition examples**: Updated with new useContext structure using required-feature context type

## 1.4.5-beta.008 (2025-09-10)

### Changed
- **KT2_ActivityDefinition**: Updated profile version from 0.9.0 to 0.10.0
- **KT2_ActivityDefinition**: Updated profile date to 2025-09-10
- **KT2_ActivityDefinition**: Enabled useContext element with required binding to KoppeltaalUsageContext ValueSet
- **KT2_ActivityDefinition**: Constrained useContext.value[x] to CodeableConcept only

### Added
- **KoppeltaalUsageContext**: New CodeSystem for usage context values (http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context)
- **KoppeltaalUsageContext_VS**: New ValueSet for usage context values (http://vzvz.nl/fhir/ValueSet/koppeltaal-usage-context)
- **Code 026-RolvdNaaste**: "Rol van de naaste" - enables relatives to participate in patient care trajectory
