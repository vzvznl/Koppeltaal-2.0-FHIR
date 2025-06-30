Instance: task-in-progress
InstanceOf: Task
Description: "Example of a task in progress"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Task"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a task in progress</div>"
* insert NLlang
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(device-volledig)
    * type = "Device"
* extension[+]
  * url = $task-instantiates
  * valueReference = Reference(activitydefinition234)
    * type = "ActivityDefinition"
* identifier
  * system = "http://koppeltaal-systeem.nl/koppeltaal-TaskIdentifier"
  * value = "54321"
* for
  * identifier
    * use = #official
    * system = "https://irma.app"
    * value = "bertabotje01@vzvz.nl"
  * type = "Patient"
* intent = #order
* priority = #routine
* executionPeriod.start = "2021-01-11T08:25:05+10:00"
* requester
  * identifier
    * system = "urn:oid:2.16.528.1.1007.3.1"
    * value = "938273695"
  * type = "Practitioner"
* owner
  * identifier
    * system = "https://irma.app"
    * value = "bertabotje01@vzvz.nl"
  * type = "Patient"
* status = #in-progress
* authoredOn = "2020-12-31T08:25:05+10:00"
* lastModified = "2020-12-31T09:45:05+10:00"