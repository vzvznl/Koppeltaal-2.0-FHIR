Instance: careteam-deelnemers
InstanceOf: CareTeam
Description: "Example of CareTeam with multiple participants"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of CareTeam with multiple participants</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://myTeam/id"
  * value = "careteam-1234"
* status = #active
* name = "Careteam depressie"
* subject = Reference(patient-met-resource-origin) "Patient, Berta Botje"
  * type = "Patient"
* participant[0]
  * role
    * coding = $v3-ParticipationType#RESP
    * text = "Hoofdbehandelaar"
  * member = Reference(practitioner-volledig) "K. Jongen"
    * type = "Practitioner"
* participant[+]
  * role
    * coding = $sct#768832004
    * text = "casemanager"
  * member = Reference(practitioner-minimaal) "M. Splinter"
    * type = "Practitioner"
* managingOrganization = Reference(organization-naam-type)
  * type = "Organization"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"