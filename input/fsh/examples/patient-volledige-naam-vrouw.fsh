Instance: patient-volledige-naam-vrouw
InstanceOf: Patient
Description: "Example of Patient with full name and maiden name"
Usage: #example
* meta.profile = "http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of Patient with full name and maiden name</div>"
* insert NLlang
* extension
  * extension
    * url = "code"
    * valueCodeableConcept = urn:oid:2.16.840.1.113883.2.4.4.16.32#0001 "Nederlandse"
  * url = "http://hl7.org/fhir/StructureDefinition/patient-nationality"
* identifier
  * system = "http://fhir.nl/fhir/NamingSystem/bsn"
  * value = "111222333"
* name[0]
  * use = #official
  * text = "Johanna Petronella Maria (Jo) van Putten-van der Giessen"
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
  * given[0] = "Johanna"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #BR
  * given[+] = "Petronella"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #BR
  * given[+] = "Maria"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #BR
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
  * use = #home
* gender = #female
  * extension
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
    * valueCodeableConcept = $v3-AdministrativeGender#F "Female"
* birthDate = "1934-04-28"
* deceasedBoolean = false
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
      * valueCodeableConcept.coding = urn:iso:std:iso:3166#NL "Netherlands"
        * version = "2020-10-26T00:00:00"
* maritalStatus = $v3-MaritalStatus#D "Divorced"
* contact
  * relationship[0] = $rolcode-vektis-urn#01 "Eerste relatie/contactpersoon"
  * relationship[+] = $rolcode-vektis-urn#07 "Hulpverlener"
  * name
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
* communication
  * extension[0]
    * extension[0]
      * url = "level"
      * valueCoding = $v3-LanguageAbilityProficiency#G "Good"
    * extension[+]
      * url = "type"
      * valueCoding = $v3-LanguageAbilityMode#RSP "Received spoken"
    * url = "http://hl7.org/fhir/StructureDefinition/patient-proficiency"
  * extension[+]
    * extension[0]
      * url = "level"
      * valueCoding = $v3-LanguageAbilityProficiency#F "Fair"
    * extension[+]
      * url = "type"
      * valueCoding = $v3-LanguageAbilityMode#ESP "Expressed spoken"
    * url = "http://hl7.org/fhir/StructureDefinition/patient-proficiency"
  * extension[+]
    * extension[0]
      * url = "level"
      * valueCoding = $v3-LanguageAbilityProficiency#G "Good"
    * extension[+]
      * url = "type"
      * valueCoding = $v3-LanguageAbilityMode#RWR "Received written"
    * url = "http://hl7.org/fhir/StructureDefinition/patient-proficiency"
  * extension[+]
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-Comment"
    * valueString = "Bij gesprek met arts zoon uitnodigen voor vertalen"
  * language = urn:oid:1.0.639.1#nl "Nederlands"