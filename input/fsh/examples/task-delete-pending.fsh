Instance: task-delete-pending
InstanceOf: KT2_DeletePendingTask
Description: "Example of a delete-pending Task announcing that a patient's data is scheduled for definitive deletion. The grace deadline (30 days after the announcement) is recorded in restriction.period.end and is managed by the server."
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2DeletePendingTask"
* meta.security = $koppeltaal-security-label#kt2-delete-flow "KT2 delete flow"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a delete-pending Task announcing the planned deletion of a patient's data</div>"
* insert NLlang
* status = #requested
* intent = #order
* code = $koppeltaal-task-code#delete-pending "Delete pending"
* authoredOn = "2026-07-01T06:00:00+00:00"
* for = Reference(patient-botje-minimaal)
  * type = "Patient"
* requester = Reference(device-koppeltaalvoorziening)
  * type = "Device"
* owner = Reference(device-volledig)
  * type = "Device"
* restriction.period.end = "2026-07-31T06:00:00+00:00"
