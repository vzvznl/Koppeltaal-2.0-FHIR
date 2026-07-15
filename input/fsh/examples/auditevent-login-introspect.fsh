Instance: auditevent-login-introspect
InstanceOf: KT2_AuditEvent
Title: "auditevent-login-introspect"
Description: "Example of a User Authentication AuditEvent for a launch via HTI: introspection of the HTI launch token (outcomeDesc prefix 'introspect')"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a User Authentication AuditEvent for a launch via HTI: introspection of the HTI launch token (outcomeDesc prefix 'introspect')</div>"
* insert NLlang
* type = $DCM#110114 "User Authentication"
* subtype = $DCM#110122 "Login"
* action = #E
* recorded = "2026-06-17T09:14:07+00:00"
* outcome = #0
* outcomeDesc = "introspect: Introspectie van het HTI launch token geslaagd"
* agent
  * type = $DCM#110153 "Source Role ID"
  * who = Reference(device-volledig)
    * type = "Device"
  * requestor = true
* source
  * site = "Koppeltaal Domein X"
  * observer = Reference(autorisatieserver)
    * type = "Device"
* entity
  * what = Reference(patient-botje-minimaal)
    * type = "Patient"
  * type = $resource-types#Patient "Patient"
  * role = $object-role#1 "Patient"
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
  * valueId = "5b0e5adc-3d0c-4a55-8a2e-9c1f4d6b7a10"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "Qw7bT2xVfR9sLm4Z"
