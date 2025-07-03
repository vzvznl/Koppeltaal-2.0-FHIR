Instance: relatedperson-contactperson
InstanceOf: RelatedPerson
Description: "The RelatedPerson is the contact person"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2RelatedPerson"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>RelatedPerson is contact person</div>"
* identifier.use = #official
* identifier.system = "urn:oid:2.16.840.1.68469.16.4.3.5.6"
* identifier.value = "55779933"
* relationship[0] = $v3-RoleCode#DAUC "Daughter"
* relationship[+] = urn:oid:2.16.840.1.113883.2.4.3.11.22.472#23 "Contactpersoon"
* name.given = "M."
* name.given.extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
* name.given.extension.valueCode = #IN
* name.use = #official
* name.text = "M. Buurvrouw"
* name.family = "Buurvrouw"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "Buurvrouw"
* gender = #female
* birthDate = "1980-07-29"
* active = true
* patient = Reference(patient-met-resource-origin) "Patient, Berta Botje"
* communication.language = urn:ietf:bcp:47#en "English"
* communication.preferred = true