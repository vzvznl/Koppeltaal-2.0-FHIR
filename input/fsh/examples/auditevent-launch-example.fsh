Instance: auditevent-launch-example
InstanceOf: AuditEvent
Description: "Example of AuditEvent on user authentication"
Usage: #example
* meta
  * profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of AuditEvent on user authentication</div>"
* insert NLlang
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/autorisatieserver)
    * type = "Device"
* type = $DCM#110114 "User Authentication"
* subtype = $DCM#110122 "Login"
* action = #E
* recorded = "2023-06-12T10:27:31.389+00:00"
* outcome = #0
* agent
  * type = $DCM#110153
  * who = Reference(autorisatieserver)
    * type = "Device"
  * requestor = true
* source
  * site = "domeinnaam"
  * observer = Reference(autorisatieserver)
    * type = "Device"
* entity
  * what = Reference(patient-volledigenaam)
    * type = "Patient"
  * role = $object-role#1 "Patient"