Instance: relatedperson-full
InstanceOf: RelatedPerson
Description: "RelatedPerson multiple relationships"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2RelatedPerson"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>RelatedPerson multiple relationships</div>"
* identifier[0]
  * use = #official
  * system = "urn:oid:2.16.840.1.68469.16.4.3.5.6"
  * value = "d52962e1-02d0-4c90-9950-26f08dbb6242"
* identifier[+]
  * use = #usual
  * system = "http://www.testsysteem.xxx/patientrelatedperson"
  * value = "${RelPersIdentifier2}"
* active = true
* patient = Reference(Patient/patient-botje-minimaal)
* relationship[0] = $v3-NullFlavor#OTH "Other"
* relationship[+] = urn:oid:2.16.840.1.113883.2.4.3.11.22.472#21 "Cliëntondersteuner"
* relationship[+] = urn:oid:2.16.840.1.113883.2.4.3.11.22.472#14 "Bewindvoerder"
* name[0]
  * use = #official
  * text = "Lizzy (Liz) Contact - van de Patient"
  * extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-assembly-order"
  * extension.valueCode = #NL1
  * family = "Contact - van de Patient"
    * extension[0].url = "http://hl7.org/fhir/StructureDefinition/humanname-own-prefix"
    * extension[=].valueString = "van de"
    * extension[+].url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
    * extension[=].valueString = "Patient"
    * extension[+].url = "http://hl7.org/fhir/StructureDefinition/humanname-partner-name"
    * extension[=].valueString = "Contact"
  * given[0] = "Lizzy"
    * extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
    * extension.valueCode = #BR
* name[+]
  * use = #usual
  * given = "Liz"
* telecom[0]
  * use = #home
  * system = #email
  * value = "lizzy@vzvz.nl"
* telecom[+]
  * use = #home
  * extension.url = "http://nictiz.nl/fhir/StructureDefinition/ext-Comment"
  * extension.valueString = "alleen bereikbaar in de middag en avond"
  * system.extension.url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
  * system.extension.valueCodeableConcept = $v3-AddressUse#MC "mobile contact"
  * system = #phone
  * value = "+31699999995"
* gender.extension.url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
* gender.extension.valueCodeableConcept = $v3-AdministrativeGender#UN "Undifferentiated"
* gender = #unknown
* birthDate = "1981-07-19"
* address
  * use = #home
  * line = "Westvlietweg 69,C to De Ark,2495AA 's-Gravenhage"
    * extension[0].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName"
    * extension[=].valueString = "Westvlietweg"
    * extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber"
    * extension[=].valueString = "69"
    * extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-buildingNumberSuffix"
    * extension[=].valueString = "C"
    * extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-additionalLocator"
    * extension[=].valueString = "to"
    * extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-unitID"
    * extension[=].valueString = "De Ark"
  * city = "'s-Gravenhage"
  * postalCode = "2495AA"
  * country.extension.url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
  * country.extension.valueCodeableConcept = urn:iso:std:iso:3166#NL "Netherlands"
  * country = "Nederland"
* period.start = "2024-07-10T08:02:05+02:00"
* period.end = "2040-02-15T12:20:05+01:00"
* communication.language = urn:ietf:bcp:47#en "English"