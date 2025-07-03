Instance: auditevent-launch-application
InstanceOf: KT2_AuditEvent
Title: "auditevent-launch-application"
Description: "Example of AuditEvent on application launch"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of AuditEvent on application launch</div>"
* insert NLlang
* type = $DCM#110100 "Application Activity"
* subtype = $DCM#110120 "Application Start"
* action = #E
* recorded = "2023-01-19T23:42:24+00:00"
* outcome = #0
* agent
  * type = $DCM#110151 "Application Launcher"
  * who = Reference(device-volledig)
    * type = "Device"
  * requestor = true
* source
  * site = "Koppeltaal Domein X"
  * observer = Reference(ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"
* entity
  * what = Reference(device-volledig)
    * type = "Device"
  * type = $resource-types#Device "Device"
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
  * valueId = "8385f600-9bf7-4b96-8467-268070c27677"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "L4t9tLExU6oQr3cT"