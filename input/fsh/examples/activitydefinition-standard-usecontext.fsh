Instance: activitydefinition-standard-usecontext
InstanceOf: KT2_ActivityDefinition
Title: "Mindfulness exercise for adults"
Description: "Example of an ActivityDefinition using standard FHIR useContext values (age and gender)"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2ActivityDefinition"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an ActivityDefinition using standard FHIR useContext for age and gender targeting</div>"
* insert NLlang
* extension[endpoint]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
  * valueReference = Reference(endpoint123)
    * type = "Endpoint"
* url = "https://example.com/activities/mindfulness-adult"
* identifier
  * use = #official
  * system = "http://example.com/activity/id"
  * value = "mindfulness-001"
* version = "2025-01-15"
* name = "Mindfulness_Adult_001"
* title = "Mindfulness exercise for adults"
* status = #active
* description = "A guided mindfulness exercise designed for adults aged 18-65, suitable for all genders"
// Standard FHIR useContext for age range
* useContext[0].code = http://terminology.hl7.org/CodeSystem/usage-context-type#age
* useContext[=].valueRange
  * low = 18 'a' "years"
  * high = 65 'a' "years"
// Standard FHIR useContext for gender
* useContext[+].code = http://terminology.hl7.org/CodeSystem/usage-context-type#gender
* useContext[=].valueCodeableConcept = http://hl7.org/fhir/administrative-gender#other "Other"
// Koppeltaal-specific useContext for feature
* useContext[+].code = http://terminology.hl7.org/CodeSystem/usage-context-type#feature
* useContext[=].valueCodeableConcept = http://vzvz.nl/fhir/CodeSystem/koppeltaal-features#026-RolvdNaaste "Rol van de naaste"
* topic = $koppeltaal-definition-topic#self-treatment
