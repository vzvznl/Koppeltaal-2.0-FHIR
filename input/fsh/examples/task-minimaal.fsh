Instance: task-minimaal
InstanceOf: Task
Description: "Example of a Task"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Task"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a Task</div>"
* insert NLlang
* extension
  * url = $task-instantiates
  * valueReference = Reference(ActivityDefinition/activitydefinition123)
    * type = "ActivityDefinition"
* identifier
  * system = "http://systeem.nl"
  * value = "12345"
* intent = #order
* for = Reference(Patient/patient-botje-minimaal)
  * type = "Patient"
* owner = Reference(Patient/patient-botje-minimaal)
  * type = "Patient"
* status = #ready