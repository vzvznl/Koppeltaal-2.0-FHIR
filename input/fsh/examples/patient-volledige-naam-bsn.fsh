Instance: patient-volledige-naam-bsn
InstanceOf: Patient
Description: "Example of Patient with full name and address"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Patient"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of Patient with full name and address</div>"
* insert NLlang
* identifier[0]
  * use = #official
  * system = "http://fhir.nl/fhir/NamingSystem/bsn"
  * value = "0123456789"
* identifier[+]
  * use = #usual
  * system = "https://irma.app"
  * value = "bertabotje1@vzvz.nl"
* active = true
* name[0]
  * use = #official
  * text = "B.F. (Berta) Botje-Pietersen"
  * family = "Botje-Pietersen"
    * extension[0]
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
      * valueString = "Pietersen"
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-partner-name"
      * valueString = "Botje"
  * given[0] = "B."
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #IN
  * given[+] = "F."
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #IN
* name[+]
  * use = #usual
  * given = "Berta"
* telecom
  * system = #email
  * value = "bertabotje1@vzvz.nl"
  * use = #home
* gender = #female
  * extension
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
    * valueCodeableConcept = $v3-AdministrativeGender#F "Female"
* birthDate = "1970-12-21"