Instance: activitydefinition-documenten-delen
InstanceOf: ActivityDefinition
Usage: #example
Description: "Voorbeeld van een ActivityDefinition die via de useContext aankondigt dat de interventie een document oplevert (uitbreiding Documenten Delen)."
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2ActivityDefinition"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>ActivityDefinition met de uitbreiding Documenten Delen</div>"
* extension[0].url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2PublisherId"
* extension[=].valueId = "ID1234-003"
* url = "https://module.example.org/catalogue/A1B2C3D4-0001-0002-0003-000400050006"
* identifier.use = #official
* identifier.system = "http://module.example.org/content/id"
* identifier.value = "A1B2C3D4-0001-0002-0003-000400050006"
* version = "2026-06-09T10:00:00"
* name = "InterventieMetDocument"
* title = "Interventie met documentoplevering"
* status = #active
* description = "Interventie die bij afronding een document (DocumentReference) oplevert."
* useContext.code = http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context-type#koppeltaal-expansion
* useContext.valueCodeableConcept = http://vzvz.nl/fhir/CodeSystem/koppeltaal-expansion#029-DocumentenDelen "Documenten Delen"
* topic = $koppeltaal-definition-topic#self-assessment
