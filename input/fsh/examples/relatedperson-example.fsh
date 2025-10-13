Instance: relatedperson-example
InstanceOf: RelatedPerson
Description: "RelatedPerson example"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2RelatedPerson"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>RelatedPerson example</div>"
* identifier[0].use = #official
* identifier[=].system = "urn:oid:2.16.840.1.68469.16.4.3.5.6"
* identifier[=].value = "878787"
* identifier[+].use = #usual
* identifier[=].system = "http://www.testsysteem.xxx/patientrelatedperson"
* identifier[=].value = "12345"
* active = true
* patient = Reference(patient-volledig-adres)
* relationship[0] = $v3-RoleCode#MTH "Mother"
* relationship[+] = urn:oid:2.16.840.1.113883.2.4.3.11.22.472#21 "Cliëntondersteuner"
* name.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-assembly-order"
* name.extension.valueCode = #NL2
* name.use = #official
* name.text = "Relatie Ouder van Patient"
* name.family = "Ouder van Patient"
* name.family.extension[0].url = "http://hl7.org/fhir/StructureDefinition/humanname-own-prefix"
* name.family.extension[=].valueString = "van"
* name.family.extension[+].url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension[=].valueString = "Patient"
* name.family.extension[+].url = "http://hl7.org/fhir/StructureDefinition/humanname-partner-name"
* name.family.extension[=].valueString = "Ouder"
* name.given = "Relatie"
* name.given.extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
* name.given.extension.valueCode = #BR
* telecom.system = #email
* telecom.value = "ouder@vzvz.nl"
* telecom.use = #home
* gender = #female
* birthDate = "1950-02-14"
* address.use = #home
* address.line = "1e Jacob van Campenstr to 15 A 2e"
* address.line.extension[0].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName"
* address.line.extension[=].valueString = "1e Jacob van Campenstr"
* address.line.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber"
* address.line.extension[=].valueString = "15"
* address.line.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-buildingNumberSuffix"
* address.line.extension[=].valueString = "A 2e"
* address.line.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-additionalLocator"
* address.line.extension[=].valueString = "to"
* address.line.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-unitID"
* address.line.extension[=].valueString = "Testadres"
* address.city = "Hoogmade"
* address.postalCode = "1012 NX"
* address.country = "Nederland"
* address.country.extension.url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
* address.country.extension.valueCodeableConcept = urn:iso:std:iso:3166#NL "Netherlands"
* communication.language = $bcp47#en "English"
* communication.preferred = true
* period.start = "2024-07-10T08:02:05+02:00"
* period.end = "2030-02-28T12:20:05+01:00"