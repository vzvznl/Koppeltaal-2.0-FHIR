CHANGELOG

## 0.15.0 (2025-11-25)

No changes from 0.15.0-beta.9.

## 0.15.0-beta.9 (2025-10-30)

### Changed
- **KT2_RelatedPerson profile**: Refined display validation to only validate codes 23 and 24
  - Updated FHIRPath invariant `kt2-role-display-validation` to only enforce exact display values for COD472 codes 23 (Contactpersoon) and 24 (Wettelijke vertegenwoordiger)
  - Other COD472 codes (01-22, 25-99) no longer require exact display matching, allowing more flexibility
  - Reduces maintenance burden while enforcing critical business rules for the two most common role codes
  - Display validation enforced due to known inconsistencies between different code systems and ValueSets
  - Updated profile comments to clarify validation scope and rationale

### Technical
- Simplified invariant expression from 18 lines (16 codes) to 4 lines (2 codes)
- Display values must match CodeSystem definitions exactly: "Contactpersoon" (code 23) and "Wettelijke vertegenwoordiger" (code 24)
- Note: The display value in the ValueSet can differ from the CodeSystem; validation uses CodeSystem values

## 0.15.0-beta.8 (2025-10-28)

### Fixed
- **KT2_RelatedPerson profile**: Enforce exact display values for COD472 role codes
  - Added FHIRPath invariant `kt2-role-display-validation` to validate display values match CodeSystem definitions exactly
  - Validates all 16 COD472 code/display pairs from the Nictiz ValueSet (urn:oid:2.16.840.1.113883.2.4.3.11.22.472)
  - Raises ERROR (not just warning) when display values don't match
  - Only validates COD472 codes; v3-RoleCode (HL7 international codes) remain lenient
  - **Breaking change**: Resources with incorrect display values will now be rejected with 422 error

### Technical
- Standard FHIR validation treats display mismatches as warnings; this invariant enforces error-level validation for Dutch COD472 codes
- Maintenance note: Invariant must be updated if COD472 CodeSystem is updated with new codes or display changes

## 0.15.0-beta.7 (2025-10-23)

### Fixed
- **Choice type constraints**: Fixed FHIR validation errors when constraining choice type elements to 0 cardinality
  - KT2_Patient: `deceased[x]` and `multipleBirth[x]` now use explicit `0..0` cardinality with `[x]` suffix
  - KT2_ActivityDefinition: `subject[x]`, `timing[x]`, and `product[x]` now use explicit `0..0` cardinality with `[x]` suffix
  - Resolves "The element has no assigned types, and no content reference" validation errors
- **Extension slicing conflicts**: Fixed "derived max (*) cannot be greater than the base max (1)" errors
  - KT2_AuditEvent: Combined resource-origin, traceId, correlationId, and requestId extensions into single declaration
  - KT2_ActivityDefinition: Combined resource-origin, endpoint, and publisherId extensions into single declaration
  - KT2_Task: Combined resource-origin and instantiates extensions into single declaration
  - Multiple 'extension contains' statements were creating conflicting slicing definitions
- **NamingSystem ID**: Added missing explicit ID to koppeltaal-client-id NamingSystem
  - Ensures SUSHI generates expected ID that matches ImplementationGuide references
  - Prevents HAPI-1094 errors when uploading ImplementationGuide resources

### Changed
- Removed unused Tracing ruleset from rulesets.fsh (extensions now declared directly in profiles)

### Technical
- All profiles now validate successfully in HAPI FHIR servers
- ImplementationGuide resources can be uploaded without reference errors

## 0.15.0-beta.6 (2025-10-22)

### Changed
- **KT2_ActivityDefinition profile**: Consolidated useContext slice rename from `feature` to `koppeltaal-expansion`
  - Merged feature/koppeltaal-extension-rename branch
  - Ensures consistency with expansion terminology across the implementation guide

### Added
- **FHIR Package Synchronization**: New script `sync-fhir-package.py` for synchronizing FHIR packages to servers
  - Downloads and extracts FHIR packages from URLs
  - Detects discrepancies: missing resources, wrong IDs, wrong versions, duplicates
  - Synchronizes resources by deleting duplicates and PUTting correct versions
  - Handles optimistic locking via resource history
  - Solves ImplementationGuide reference errors caused by ID mismatches
- **ImplementationGuide Upload**: Enhanced `upload-implementation-guide.py` script
  - Strips IG Publisher-specific parameters for HAPI FHIR compatibility
  - Removes example resources that don't exist on server
  - Supports optimistic locking with If-Match header

### Technical
- Improved FHIR server resource management tooling
- Fixed version management for deleted resources using history etag

## 0.15.0-beta.5 (2025-10-21)

### Changed
- **KT2_ActivityDefinition profile**: Renamed useContext slice from `feature` to `koppeltaal-expansion`
  - Aligns slice naming with expansion terminology introduced in 0.15.0-beta.4
  - Improves consistency between slice name and the expansion concept it represents
  - Generated StructureDefinition now uses `sliceName: "koppeltaal-expansion"`

### Technical
- Refactored profile slicing to use consistent naming throughout the implementation guide

## 0.15.0-beta.4 (2025-10-21)

### Changed
- **Terminology rename**: Changed from "features" to "expansion" terminology
  - Renamed `KoppeltaalFeatures` CodeSystem to `KoppeltaalExpansion`
  - Changed URL from `http://vzvz.nl/fhir/CodeSystem/koppeltaal-features` to `http://vzvz.nl/fhir/CodeSystem/koppeltaal-expansion`
  - Renamed `KoppeltaalFeatures_VS` ValueSet to `KoppeltaalExpansion_VS`
  - Changed URL from `http://vzvz.nl/fhir/ValueSet/koppeltaal-features` to `http://vzvz.nl/fhir/ValueSet/koppeltaal-expansion`
  - Updated descriptions from "Required features or capabilities" to "Optional expansions"
  - Aligns with standard terminology: these are optional extensions, not required features
- **KT2_ActivityDefinition profile**: Updated useContext[feature] documentation
  - Changed from "Required feature or capability" to "Optional expansion"
  - Updated binding descriptions to reflect optional nature

### Technical
- Updated all references in profiles, examples, and test resources to use new expansion terminology

## 0.15.0-beta.3 (2025-10-21)

### Added
- **KT2Task validation documentation**: Added mandatory validation rules for Tasks with read-only permissions (`Task.code = view`)
  - Task must have `Task.partOf` present
  - `Task.partOf` must reference a Task without `Task.code`
  - `Task.for` must equal the `Task.for` of the referenced Task
  - Documentation added to StructureDefinition-KT2Task-notes.md
- **KT2CareTeam validation documentation**: Added mandatory validation rules for CareTeam operations
  - `CareTeam.subject` must equal the associated Patient
  - `CareTeam.status` must be `active`
  - If `CareTeam.period` is present, validation moment must fall within the period
  - Documentation added to StructureDefinition-KT2CareTeam-notes.md

### Changed
- Removed ambiguous statement from KT2Task documentation about `view` permission meaning differing per application
  - Now clearly defines mandatory validation requirements for all applications

### Technical
- Implemented requirements from KPTSTD-925 (Resource-specific validations for implementation guide)

## 0.15.0-beta.2 (2025-10-21)

### Fixed
- **KT2_ActivityDefinition useContext validation**: Added required binding for expansion codes in useContext.valueCodeableConcept
  - Created `KoppeltaalExpansion_VS` ValueSet to validate expansion codes
  - Implemented slicing on `useContext` to discriminate by code type
  - Added `feature` slice with required binding to `KoppeltaalExpansion_VS`
  - Now properly validates that expansion codes must be from `koppeltaal-expansion` CodeSystem
  - Prevents invalid codes like "INVALID" from passing validation

### Added
- **ValueSet**: `KoppeltaalExpansion_VS` (http://vzvz.nl/fhir/ValueSet/koppeltaal-expansion)
  - Includes all codes from `KoppeltaalExpansion` CodeSystem
- **Test case**: `invalid-feature-code` variant in test resource generator
  - Tests rejection of invalid expansion codes in useContext.valueCodeableConcept
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
