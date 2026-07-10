Instance: auditevent-opschoning-destroy
InstanceOf: KT2_AuditEvent
Title: "auditevent-opschoning-destroy"
Description: "Example of an aggregated deletion lifecycle AuditEvent: the definitive deletion has been executed (ISO 21089 type 'destroy', action D). This event survives the erase, contains no PII — only the technical Patient reference — and carries the post-delete signal to which applications can subscribe"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* meta.security = $koppeltaal-security-label#kt2-delete-flow "KT2 delete flow"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an aggregated deletion lifecycle AuditEvent: definitive deletion executed (destroy, action D)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#destroy "Destroy/Delete Record Lifecycle Event"
* action = #D
* recorded = "2026-08-30T03:00:00+00:00"
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
  * valueId = "6f1c8b7a-4d9e-4c2f-3b6a-0e7d1f4c5b86"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "Lu7aP2rIc9vBs4Xg"
