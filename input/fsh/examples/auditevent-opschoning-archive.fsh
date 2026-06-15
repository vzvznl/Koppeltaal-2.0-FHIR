Instance: auditevent-opschoning-archive
InstanceOf: AuditEvent
Description: "Opschoning-lifecycle AuditEvent: de Koppeltaalvoorziening kondigt de verwijdering aan door een KT2_DeletePendingTask aan te maken (Task `requested`). ISO 21089 `type` = `archive`, `action` = C."
Usage: #example
* meta
  * profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Opschoning aangekondigd (archive)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#archive "Archive Record Lifecycle Event"
* action = #C
* recorded = "2026-06-09T08:00:00+00:00"
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
