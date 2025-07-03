Instance: nl-core-TreatmentDirective2-01-RelatedPerson-01
InstanceOf: NlcoreContactPerson
Description: "Nictiz Example of RelatedPerson only to test validation"
Usage: #example
* id = "relatedperson-nl-core-TreatmentDirective2-01"
* patient = Reference(Patient/patient-botje-minimaal) "Patient, Johanna Petronella Maria (Jo) van Putten-van der Giessen"
* patient.type = "Patient"
* relationship[0] = urn:oid:2.16.840.1.113883.2.4.3.11.22.472#01 "Eerste relatie/contactpersoon"
* relationship[+] = $v3-RoleCode#HUSB "Husband"
* name[0].extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-assembly-order"
* name[=].extension.valueCode = #NL1
* name[=].use = #official
* name[=].text = "Jan Pieter Mark van Putten"
* name[=].family.extension[0].url = "http://hl7.org/fhir/StructureDefinition/humanname-own-prefix"
* name[=].family.extension[=].valueString = "van"
* name[=].family.extension[+].url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name[=].family.extension[=].valueString = "Putten"
* name[=].family.extension[+].url = "http://hl7.org/fhir/StructureDefinition/humanname-partner-prefix"
* name[=].family.extension[=].valueString = "van"
* name[=].family.extension[+].url = "http://hl7.org/fhir/StructureDefinition/humanname-partner-name"
* name[=].family.extension[=].valueString = "Kleeff"
* name[=].family = "van Putten"
* name[=].given[0] = "Jan"
* name[=].given[+] = "Pieter"
* name[=].given[+] = "Mark"
* name[=].given[0].extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
* name[=].given[=].extension.valueCode = #BR
* name[=].given[+].extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
* name[=].given[=].extension.valueCode = #BR
* name[=].given[+].extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
* name[=].given[=].extension.valueCode = #BR
* name[=].prefix = "Dr."
* name[+].use = #usual
* name[=].given = "Piet"
* telecom[0].extension.url = "http://nictiz.nl/fhir/StructureDefinition/ext-Comment"
* telecom[=].extension.valueString = "test toelichting"
* telecom[=].system.extension.url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
* telecom[=].system.extension.valueCodeableConcept = $v3-AddressUse#MC "mobile contact"
* telecom[=].system = #phone
* telecom[=].value = "+31611234567"
* telecom[=].use = #home

* telecom[+].system = #email
* telecom[=].value = "giesput@myweb.nl"
* telecom[=].use = #home
* address.extension.url = "http://nictiz.nl/fhir/StructureDefinition/ext-AddressInformation.AddressType"
* address.extension.valueCodeableConcept = $v3-AddressUse#HP "Primary Home"
* address.use = #home
* address.type = #both
* address.line = "1e Jacob van Campenstr to 15 A 2e"
// * address.line.extension[0].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName"
// * address.line.extension[=].valueString = "1e Jacob van Campenstr"
// * address.line.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber"
// * address.line.extension[=].valueString = "15"
// * address.line.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-buildingNumberSuffix"
// * address.line.extension[=].valueString = "A 2e"
// * address.line.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-additionalLocator"
// * address.line.extension[=].valueString = "to"
// * address.line.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-unitID"
// * address.line.extension[=].valueString = "test info"
* address.city = "Hoogmade"
* address.district = "Kaag en Braassem"
* address.postalCode = "1012 NX"
// * address.country.extension.url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
// * address.country.extension.valueCodeableConcept.coding.version = "2020-10-26T00:00:00"
// * address.country.extension.valueCodeableConcept.coding = urn:iso:std:iso:3166#NL "Nederland"
// * address.country = "Nederland"