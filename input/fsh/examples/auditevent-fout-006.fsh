Instance: auditEvent-fout-006
InstanceOf: KT2_AuditEvent
Title: "auditEvent-fout-006"
Description: "Example of an AuditEvent with an OperationOutcome indicating an error in the update"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an AuditEvent with an OperationOutcome indicating an error in the update</div>"
* insert NLlang
* type = $audit-event-type#rest "Restful Operation"
* subtype = $restful-interaction#update "update"
* action = #U
* recorded = "2013-06-20T23:42:24Z"
* outcome = #4
* agent
  * type = $DCM#110153
  * who = Reference(Device/device-volledig)
  * requestor = true
* source.observer = Reference(ba33314a-795a-4777-bef8-e6611f6be645)
  * type = "Device"
  * identifier.value = "Koppeltaal.nl"
* entity
  * what = Reference(Patient/patient-botje-minimaal)
  * type = $resource-types#OperationOutcome "OperationOutcome"
  * description = "Failed to parse request body as JSON resource…."
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
  * valueId = "000000000000000053ce929d0e0e9877"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "53ce929d0e0e9877"