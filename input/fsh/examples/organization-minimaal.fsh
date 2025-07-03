Instance: organization-minimaal
InstanceOf: Organization
Description: "Bare minimum definition of an Organization"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Organization"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Bare minimum definition of an Organization</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://fhir.nl/fhir/NamingSystem/agb-z"
  * value = "25123456"
* active = true