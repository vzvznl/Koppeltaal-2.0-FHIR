Instance: auditevent-opschoning-unhold
InstanceOf: AuditEvent
Description: "Opschoning-lifecycle AuditEvent: een doelapplicatie heft haar noodrem op door haar eigen KT2_DeletePendingTask van `on-hold` naar `accepted` te zetten. ISO 21089 `type` = `unhold`, `action` = U."
Usage: #example
* meta
  * profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Noodrem opgeheven (unhold)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#unhold "Unhold Record Lifecycle Event"
* action = #U
* recorded = "2026-06-12T14:15:00+00:00"
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
