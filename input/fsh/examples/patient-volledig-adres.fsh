Instance: patient-volledig-adres
InstanceOf: Patient
Description: "Example of Patient with full address"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Patient"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of Patient with full address</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "https://irma.app"
  * value = "bertabotje01@vzvz.nl"
* active = true
* name
  * use = #official
  * text = "B. Botje"
  * family = "Botje"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-partner-name"
      * valueString = "Botje"
  * given = "B"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #IN
* telecom
  * system = #email
  * value = "bertabotje01@vzvz.nl"
  * use = #home
* gender = #female
  * extension
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
    * valueCodeableConcept.coding = $v3-AdministrativeGender#F "Female"
* birthDate = "1972-11-12"
* address
  * use = #home
  * line = "1e Jacob van Campenstr to 15 A 2e"
    * extension[0]
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName"
      * valueString = "1e Jacob van Campenstr"
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber"
      * valueString = "15"
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-buildingNumberSuffix"
      * valueString = "A 2e"
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-additionalLocator"
      * valueString = "to"
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-unitID"
      * valueString = "Testadres"
  * city = "Hoogmade"
  * postalCode = "1012 NX"