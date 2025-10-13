Instance: auditevent-create-patient
InstanceOf: KT2_AuditEvent
Title: "auditevent-create-patient"
Description: "Example of an AuditEvent about creating a Patient"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an AuditEvent about creating a Patient</div>"
* insert NLlang
* type = $audit-event-type#rest "Restful Operation"
* subtype = $restful-interaction#create "create"
* action = #C
* recorded = "2023-01-19T23:42:24+00:00"
* outcome = #0
* agent[0]
  * type = $DCM#110153
  * who = Reference(ba33314a-795a-4777-bef8-e6611f6be645)
  * requestor = true
* agent[+]
  * type = $DCM#110152
  * who = Reference(Device/device-volledig)
  * requestor = false
* source
  * site = "Koppeltaal Domein X"
  * observer = Reference(ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"
  * type = $security-source-type#4 "Application Server"
* entity
  * what = Reference(Patient/patient-botje-minimaal/_history/1)
    * type = "Patient"
  * type = $resource-types#Patient "Patient"
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
  * valueId = "8385f600-9bf7-4b96-8467-268070c27677"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "L4t9tLExU6oQr3cT"