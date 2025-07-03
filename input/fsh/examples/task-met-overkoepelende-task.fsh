Instance: task-met-overkoepelende-task
InstanceOf: Task
Description: "Example of a sub task, part of another task"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Task"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a sub task, part of another task</div>"
* insert NLlang
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(device-volledig)
    * type = "Device"
* extension[+]
  * url = $task-instantiates
  * valueReference = Reference(activitydefinition123)
    * type = "ActivityDefinition"
* identifier
  * system = "http://koppeltaal.nl/taskIdentifier"
  * value = "1234"
* partOf = Reference(task-overkoepelend)
* for = Reference(Patient/patient-volledige-naam-bsn)
  * type = "Patient"
* intent = #order
* priority = #routine
* code = $task-code#fulfill
* executionPeriod
  * start = "2023-01-20T08:25:05+01:00"
  * end = "2023-01-21T08:25:05+01:00"
* requester = Reference(practitioner-minimaal)
  * type = "Practitioner"
* owner = Reference(patient-volledige-naam-bsn)
  * type = "Patient"
* status = #ready
* authoredOn = "2023-01-19T08:25:05+01:00"
* lastModified = "2023-01-19T09:45:05+01:00"