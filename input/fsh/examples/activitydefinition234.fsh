Instance: activitydefinition234
InstanceOf: KT2_ActivityDefinition
Title: "Routine outcome monitoring"
Description: "Example of an ActivityDefinition that defines a questionnaire"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2ActivityDefinition"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an ActivityDefinition that defines a questionnaire</div>"
* insert NLlang
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
  * valueReference = Reference(endpoint123)
    * type = "Endpoint"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2PublisherId"
  * valueId = "ID1234-002"
* url = "https://int-381-kt2-sprint-7.minddistrict.dev/catalogue/E0E49199-B329-4A52-8B9C-7635E59B8EE2"
* identifier
  * use = #official
  * system = "http://ns.minddistrict.com/content/id"
  * value = "E0E49199-B329-4A52-8B9C-7635E59B8EE2"
* version = "2022-12-20.19:00:123"
* name = "ROMlijst_E0E49199_B329_4A52_8B9C_7635E59B8EE2"
* title = "Routine outcome monitoring"
* subtitle = "voor GGZ Testland"
* status = #active
* description = "Vragenlijst ROM"
* topic.coding = $koppeltaal-definition-topic#self-assessment