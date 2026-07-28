Instance: auditevent-opschoning-unhold
InstanceOf: KT2_AuditEvent
Title: "auditevent-opschoning-unhold"
Description: "Example of an aggregated deletion lifecycle AuditEvent: the last emergency brake is released while the process still continues to the grace deadline — not all Tasks are 'accepted' (ISO 21089 type 'unhold', action U). If that same release completes the process (all Tasks 'accepted'), a 'destroy' follows directly instead of an 'unhold'"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* meta.security = $koppeltaal-security-label#kt2-delete-flow "KT2 delete flow"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an aggregated deletion lifecycle AuditEvent: last emergency brake released, process continues (unhold, action U)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#unhold "Remove Legal Hold Record Lifecycle Event"
* action = #U
* recorded = "2026-08-10T14:15:00+00:00"
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
  * valueId = "4d9a6f5e-2b7c-4a0d-1f4e-8c5b9d2a3f64"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "Js5yN0pGa7tZq2Ve"
