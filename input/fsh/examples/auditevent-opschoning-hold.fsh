Instance: auditevent-opschoning-hold
InstanceOf: KT2_AuditEvent
Title: "auditevent-opschoning-hold"
Description: "Example of an aggregated deletion lifecycle AuditEvent: the first application pulls the emergency brake (its Task goes to 'on-hold'), so the aggregated process state becomes blocked (ISO 21089 type 'hold', action U). A second hold does not produce another event. The per-application reason lives on the Task ('Task.statusReason'), not in this aggregated event"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* meta.security = $koppeltaal-security-label#kt2-delete-flow "KT2 delete flow"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an aggregated deletion lifecycle AuditEvent: process blocked by the first emergency brake (hold, action U)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#hold "Add Legal Hold Record Lifecycle Event"
* action = #U
* recorded = "2026-07-05T09:30:00+00:00"
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
  * valueId = "2b7e4d3c-0f5a-4e8b-9d2c-6a3f7b0e1d42"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "Gq3wL8nEy5rXo0Tc"
