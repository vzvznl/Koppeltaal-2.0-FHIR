Instance: auditevent-delete-patient
InstanceOf: KT2_AuditEvent
Title: "auditevent-delete-patient"
Description: "Example of an AuditEvent about deleting a patient"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an AuditEvent about deleting a patient</div>"
* insert NLlang
* type = $audit-event-type#rest "Restful Operation"
* subtype = $restful-interaction#delete "delete"
* action = #D
* recorded = "2023-01-19T23:42:24+00:00"
* outcome = #0
* agent
  * type = $DCM#110153
  * who = Reference(device-volledig)
  * requestor = true
* source
  * site = "Koppeltaal Domein X"
  * observer = Reference(ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"
* entity
  * what = Reference(Patient/patient-botje-minimaal/_history/2)
    * type = "Patient"
  * type = $resource-types#OperationOutcome "OperationOutcome"
  * lifecycle = $dicom-audit-lifecycle#14 "Logical deletion"
  * description = "Successfully deleted 1 resource(s) in 15ms"
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
  * valueId = "000000000000000053ce929d0e0e4736"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "53ce929d0e0e4736"