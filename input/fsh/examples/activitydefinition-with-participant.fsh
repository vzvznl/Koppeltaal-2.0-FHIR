Instance: activitydefinition-with-participant
InstanceOf: ActivityDefinition
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2ActivityDefinition"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Activitydefinition with participant</div>"
* extension[0].url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
* extension[=].valueReference = Reference(endpoint123)
* extension[=].valueReference.type = "Endpoint"
* extension[+].url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2PublisherId"
* extension[=].valueId = "ID1234-002"
* url = "https://int-381-kt2-sprint-7.minddistrict.dev/catalogue/F9288512-009C-420A-8A3A-F02C5DA8B810"
* identifier.use = #official
* identifier.system = "http://ns.minddistrict.com/content/id"
* identifier.value = "F9288512-009C-420A-8A3A-F02C5DA8B810"
* version = "2024-08-15T13:11:34"
* name = "ROMlijst_F9288512_009C_420A_8A3A_F02C5DA8B810"
* title = "Routine outcome monitoring"
* subtitle = "voor GGZ Testland"
* status = #active
* description = "Vragenlijst ROM"
* topic = $koppeltaal-definition-topic#self-assessment
* participant[0].type = #related-person
* participant[=].role = $v3-RoleCode#AUNT
* participant[+].type = #practitioner
* participant[=].role = $sct#224588003 "Psychotherapist"