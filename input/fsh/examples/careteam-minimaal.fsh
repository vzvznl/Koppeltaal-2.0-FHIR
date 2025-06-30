Instance: careteam-minimaal
InstanceOf: CareTeam
Description: "Example of bare minimum of CareTeam"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of bare minimum of CareTeam</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://myTeam/id"
  * value = "1234"
* status = #active
* subject = Reference(Patient/patient-met-resource-origin) "Patient, Berta Botje"
  * type = "Patient"
  