Instance: auditevent-opschoning-archive
InstanceOf: KT2_AuditEvent
Title: "auditevent-opschoning-archive"
Description: "Example of an aggregated deletion lifecycle AuditEvent: the Koppeltaal service announces the deletion by creating the delete-pending Task(s); the grace period starts (ISO 21089 type 'archive', action C)"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* meta.security = $koppeltaal-security-label#kt2-delete-flow "KT2 delete flow"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an aggregated deletion lifecycle AuditEvent: deletion announced, grace period starts (archive, action C)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#archive "Archive Record Lifecycle Event"
* action = #C
* recorded = "2026-07-01T06:00:00+00:00"
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
  * valueId = "1a6f3c2d-9e4b-4d7a-b8c1-5f2e6a9d0c31"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "Fp2vK7mDx4qWn9Sb"
