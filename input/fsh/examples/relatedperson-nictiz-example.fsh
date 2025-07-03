Alias: $v3-AddressUse = http://terminology.hl7.org/CodeSystem/v3-AddressUse

Instance: relatedperson-nictiz-example
InstanceOf: NlcoreContactPerson
Description: "Nictiz Example of RelatedPerson only to test validation"
Usage: #example
* id = "nl-core-ContactPerson-01-nictiz"
* patient
  * reference = "Patient/patient-volledige-naam-vrouw"
  * type = "Patient"
  * display = "Patient, Johanna Petronella Maria (Jo) van Putten-van der Giessen"
* relationship[0] = $rolcode-vektis-urn#01 "Eerste relatie/contactpersoon"
* relationship[+] = $rolcode-vektis-urn#07 "Hulpverlener"
* name[0]
  * use = #official
  * text = "J.P.M. van Putten-van der Giessen"
  * family = "van Putten-van der Giessen"
    * extension[0]
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-own-prefix"
      * valueString = "van"
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
      * valueString = "Putten"
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-partner-prefix"
      * valueString = "van der"
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-partner-name"
      * valueString = "Giessen"
  * given[0] = "J."
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #IN
  * given[+] = "P."
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #IN
  * given[+] = "M."
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #IN
* name[+]
  * use = #usual
  * given = "Jo"
* telecom[0]
  * system = #phone
    * extension
      * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
      * valueCodeableConcept = $v3-AddressUse#MC "mobile contact"
  * value = "+31611234567"
* telecom[+]
  * system = #email
  * value = "giesput@myweb.nl"
  * use = #work
* address
  * extension
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-AddressInformation.AddressType"
    * valueCodeableConcept = $v3-AddressUse#HP "Primary Home"
  * use = #home
  * type = #both
  * line = "1e Jacob van Campenstr 15"
    * extension[0]
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName"
      * valueString = "1e Jacob van Campenstr"
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber"
      * valueString = "15"
  * city = "Hoogmade"
  * district = "Kaag en Braassem"
  * postalCode = "1012 NX"
  * country = "Nederland"
    * extension
      * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
      * valueCodeableConcept.coding = urn:oid:2.16.840.1.113883.2.4.4.16.34#6030 "Nederland"
        * version = "2020-04-01T00:00:00"