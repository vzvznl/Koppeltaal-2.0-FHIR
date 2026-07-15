Instance: auditevent-application-login
InstanceOf: KT2_AuditEvent
Title: "auditevent-application-login"
Description: "Example of an Application User Authentication AuditEvent: the application authenticates the user outside the Koppeltaal authentication chain (subtype DCM#110126 Node Authentication), created by the application itself"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an Application User Authentication AuditEvent: the application authenticates the user outside the Koppeltaal authentication chain (subtype DCM#110126 Node Authentication), created by the application itself</div>"
* insert NLlang
* type = $DCM#110114 "User Authentication"
* subtype = $DCM#110126 "Node Authentication"
* action = #E
* recorded = "2026-06-19T19:03:12+00:00"
* outcome = #0
* outcomeDesc = "Applicatie-login geslaagd (zonder Koppeltaal-interactie)"
* agent
  * type = $DCM#110153 "Source Role ID"
  * who = Reference(device-volledig)
    * type = "Device"
  * requestor = true
* source
  * site = "applicatie.example.nl"
  * observer = Reference(device-volledig)
    * type = "Device"
* entity
  * what = Reference(patient-botje-minimaal)
    * type = "Patient"
  * type = $resource-types#Patient "Patient"
  * role = $object-role#1 "Patient"
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
  * valueId = "7f4a1c9e-2d6b-4e8f-a3c5-0b9d8e7f6a21"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "Nc8dR4tGy1wZk5Xj"
