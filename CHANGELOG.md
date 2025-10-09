CHANGELOG

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
