Instance: patient-volledigenaam
InstanceOf: Patient
Description: "Example of Patient with name and initials"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Patient"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of Patient with name and initials</div>"
* insert NLlang
* identifier[0]
  * use = #usual
  * system = "urn:oid:2.16.840.1.113883.16.4.3.2.5"
  * value = "BerendBotje-03"
* identifier[+]
  * use = #official
  * system = "https://irma.app"
  * value = "schemer04@vzvz.nl"
* active = true
* name
  * use = #official
  * text = "Hendrik Willem Schemer"
  * family = "Schemer"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
      * valueString = "Schemer"
  * given[0] = "Hendrik"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #BR
  * given[+] = "Willem"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #BR
  * given[+] = "H."
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #IN
  * given[+] = "W."
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #IN
* telecom
  * system = #email
  * value = "berendbotje01@vzvz.nl"
  * use = #home
* gender = #male
  * extension
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
    * valueCodeableConcept = $v3-AdministrativeGender#M "Male"
* birthDate = "1970-12-20"