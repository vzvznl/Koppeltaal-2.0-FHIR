Instance: auditevent-login-idp-login
InstanceOf: KT2_AuditEvent
Title: "auditevent-login-idp-login"
Description: "Example of a User Authentication AuditEvent for the redirect back from the external IdP with the IdP decision: outcome 0 for success, outcome 8 for a denied login (outcomeDesc prefix 'idp login')"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a User Authentication AuditEvent for the redirect back from the external IdP with the IdP decision: outcome 0 for success, outcome 8 for a denied login (outcomeDesc prefix 'idp login')</div>"
* insert NLlang
* type = $DCM#110114 "User Authentication"
* subtype = $DCM#110122 "Login"
* action = #E
* recorded = "2026-06-17T10:15:41+00:00"
* outcome = #0
* outcomeDesc = "idp login: Login bij externe IdP geslaagd"
* agent[0]
  * type = $DCM#110152 "Destination Role ID"
  * who = Reference(device-volledig)
    * type = "Device"
  * requestor = true
* agent[+]
  * type = $DCM#110153 "Source Role ID"
  * who = Reference(device-externe-idp)
    * type = "Device"
  * requestor = false
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
  * valueId = "c9d2a4f1-6e3b-4c8d-9f0a-2b5e7d1c8a43"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "Bx2kF6vJs8yQe3Md"
