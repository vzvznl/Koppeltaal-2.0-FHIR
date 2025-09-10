CHANGELOG

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
