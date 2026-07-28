Instance: auditevent-opschoning-grace-reset
InstanceOf: KT2_AuditEvent
Title: "auditevent-opschoning-grace-reset"
Description: "Example of an aggregated deletion lifecycle AuditEvent: a hold was still present when the grace deadline passed, so the Koppeltaal service clears all holds and restarts the grace period with a new deadline (ISO 21089 type 'archive', action U — action C marks the initial announcement)"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* meta.security = $koppeltaal-security-label#kt2-delete-flow "KT2 delete flow"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an aggregated deletion lifecycle AuditEvent: holds cleared, grace period restarted (archive, action U)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#archive "Archive Record Lifecycle Event"
* action = #U
* recorded = "2026-07-31T06:00:00+00:00"
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
  * valueId = "3c8f5e4d-1a6b-4f9c-0e3d-7b4a8c1f2e53"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "Hr4xM9oFz6sYp1Ud"
