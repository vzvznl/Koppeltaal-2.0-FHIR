Instance: organization-afdeling
InstanceOf: Organization
Description: "Example of an Organization department"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Organization"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an Organization department</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://zorginstelling-uniekecode/agb-z"
  * value = "25654321"
* active = true
* type = urn:oid:2.16.840.1.113883.2.4.6.7#0335 "Medisch specialisten, geriatrie"
* name = "Geriatrie afdeling van St. Testziekenhuis"
* partOf = Reference(organization-naam-type)
  * type = "Organization"