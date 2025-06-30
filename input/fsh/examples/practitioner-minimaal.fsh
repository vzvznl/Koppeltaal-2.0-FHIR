Instance: practitioner-minimaal
InstanceOf: Practitioner
Description: "Example of Practitioner"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Practitioner"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of Practitioner</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "https://irma.app/email"
  * value = "mario+vzvz@therapieland.nl"
* active = true
* name
  * use = #official
  * text = "M. Splinter"
  * family = "Splinter"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
      * valueString = "Splinter"
  * given = "M"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #IN
* telecom
  * system = #email
  * value = "mario+vzvz@therapieland.nl"
  * use = #work