Instance: auditevent-opschoning-reactivate
InstanceOf: AuditEvent
Description: "Opschoning-lifecycle AuditEvent: de Koppeltaalvoorziening breekt de verwijdering af wegens hernieuwde patiëntbetrokkenheid en zet de KT2_DeletePendingTask(s) op `cancelled`. ISO 21089 `type` = `reactivate`, `action` = U."
Usage: #example
* meta
  * profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Verwijdering afgebroken (reactivate)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#reactivate "Re-activate Record Lifecycle Event"
* action = #U
* recorded = "2026-06-13T07:45:00+00:00"
* outcome = #0
* agent
  * type = $DCM#110153 "Source Role ID"
  * who = Reference(autorisatieserver)
    * type = "Device"
  * requestor = true
* source
  * site = "domeinnaam"
  * observer = Reference(autorisatieserver)
    * type = "Device"
* entity
  * what = Reference(task-delete-pending)
    * type = "Task"
  * type = $resource-types#Task "Task"
