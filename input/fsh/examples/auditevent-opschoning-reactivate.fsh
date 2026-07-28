Instance: auditevent-opschoning-reactivate
InstanceOf: KT2_AuditEvent
Title: "auditevent-opschoning-reactivate"
Description: "Example of an aggregated deletion lifecycle AuditEvent: the deletion is aborted because of renewed patient engagement; the delete-pending Task(s) go to 'cancelled' and the retention period restarts (ISO 21089 type 'reactivate', action U). This is the alternative ending of the process, instead of 'destroy'"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* meta.security = $koppeltaal-security-label#kt2-delete-flow "KT2 delete flow"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an aggregated deletion lifecycle AuditEvent: deletion aborted because of renewed patient engagement (reactivate, action U)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#reactivate "Re-activate Record Lifecycle Event"
* action = #U
* recorded = "2026-08-20T11:00:00+00:00"
* outcome = #0
* agent
  * type = $DCM#110153 "Source Role ID"
  * who = Reference(device-koppeltaalvoorziening)
    * type = "Device"
  * requestor = true
* source
  * site = "Koppeltaal Domein X"
  * observer = Reference(device-koppeltaalvoorziening)
    * type = "Device"
* entity
  * what = Reference(patient-botje-minimaal)
    * type = "Patient"
  * type = $resource-types#Patient "Patient"
  * role = $object-role#1 "Patient"
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
  * valueId = "5e0b7a6f-3c8d-4b1e-2a5f-9d6c0e3b4a75"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "Kt6zO1qHb8uAr3Wf"
