Instance: relatedperson-minimal
InstanceOf: RelatedPerson
Description: "Example of a RelatedPerson (neighbour) 2"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2RelatedPerson"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a RelatedPerson mimimal</div>"
* insert NLlang
* identifier.use = #official
* identifier.system = "urn:oid:2.16.840.1.68469.16.4.3.5.6"
* identifier.value = "55779933"
* relationship = $v3-RoleCode#DAUC "Daughter"
* relationship[+] = $rolcode-vektis-urn#21 "Cliëntondersteuner"
* name[0]
  * use = #official
  * text = "M. Buurvrouw"
  * given[0] = "M."
    * extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
    * extension.valueCode = #IN
  * family = "Buurvrouw"
    * extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
    * extension.valueString = "Buurvrouw"
* gender = #female
* birthDate = "1980-07-29"
* active = true
* patient = Reference(patient-met-resource-origin) "Patient, Berta Botje"
* communication.language = urn:ietf:bcp:47#nl