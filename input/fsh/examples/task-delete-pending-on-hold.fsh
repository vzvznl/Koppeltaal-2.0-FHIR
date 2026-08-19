Instance: task-delete-pending-on-hold
InstanceOf: KT2_DeletePendingTask
Description: "Example of a delete-pending Task on which the target application has pulled the emergency brake. The coded statusReason states why the deletion is paused; it comes from a closed list and takes no free text, so the reason itself cannot carry demographics. The Koppeltaal service clears statusReason as soon as on-hold is left."
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2DeletePendingTask"
* meta.security = $koppeltaal-security-label#kt2-delete-flow "KT2 delete flow"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a delete-pending Task paused by the target application</div>"
* insert NLlang
* status = #on-hold
* statusReason = $koppeltaal-delete-hold-reason#data-export-pending "Export naar bronsysteem loopt nog"
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
