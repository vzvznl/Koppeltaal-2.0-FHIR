Instance: task-overkoepelend
InstanceOf: Task
Description: "Example of an overarching task"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Task"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an overarching task</div>"
* insert NLlang
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/device-volledig)
    * type = "Device"
* extension[+]
  * url = $task-instantiates
  * valueReference = Reference(ActivityDefinition/activitydefinition234)
    * type = "ActivityDefinition"
* identifier
  * system = "https://irma.app"
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
* status = #ready
* authoredOn = "2020-12-31T08:25:05+10:00"
* lastModified = "2020-12-31T09:45:05+10:00"