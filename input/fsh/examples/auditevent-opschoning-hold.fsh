Instance: auditevent-opschoning-hold
InstanceOf: AuditEvent
Description: "Opschoning-lifecycle AuditEvent: een doelapplicatie trekt de noodrem door haar eigen KT2_DeletePendingTask op `on-hold` te zetten. ISO 21089 `type` = `hold`, `action` = U; de reden is afgeleid van `Task.statusReason`."
Usage: #example
* meta
  * profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Noodrem getrokken (hold)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#hold "Hold Record Lifecycle Event"
* action = #U
* recorded = "2026-06-11T09:30:00+00:00"
* outcome = #0
* agent
  * type = $DCM#110153 "Source Role ID"
  * who = Reference(device-volledig)
    * type = "Device"
  * requestor = true
* source
  * site = "module.example.com"
  * observer = Reference(device-volledig)
    * type = "Device"
* entity
  * what = Reference(task-delete-pending)
    * type = "Task"
  * type = $resource-types#Task "Task"
