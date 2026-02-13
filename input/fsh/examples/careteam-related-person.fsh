Instance: careteam-related-person
InstanceOf: CareTeam
Description: "Example of CareTeam that has a RelatedPerson as one of the participants"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of CareTeam that has a RelatedPerson as one of the participants</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://myTeam/id"
  * value = "careteam-1222"
* status = #active
* name = "Careteam met related person"
* subject = Reference(Patient/patient-met-resource-origin) "Patient, Berta Botje"
  * type = "Patient"
* participant[0]
  * role
    * coding = $koppeltaal-careteam-role#behandelaar "Behandelaar"
    * text = "Behandelaar"
  * member = Reference(Practitioner/practitioner-volledig) "K. Jongen"
    * type = "Practitioner"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#case-manager "Case Manager"
    * text = "Case Manager"
  * member = Reference(Practitioner/practitioner-minimaal) "M. Splinter"
    * type = "Practitioner"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#naaste "Naaste"
    * text = "Naaste"
  * member = Reference(RelatedPerson/relatedperson-minimal) "M. Buurvrouw"
    * type = "RelatedPerson"
* managingOrganization = Reference(Organization/organization-naam-type)
  * type = "Organization"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"