Instance: auditevent-introspect-hti
InstanceOf: AuditEvent
Description: "Voorbeeld van een AuditEvent bij de `/introspect`-call voor een HTI launch token. Dit hergebruikt het User Authentication AuditEvent (`DCM#110114`) met het voorgestelde subtype `DCM#110143`; alleen introspectie van een HTI launch token telt als hernieuwde patiëntbetrokkenheid voor de bewaartermijn. Het subtype is een voorstel en wordt bevestigd in TOP-KT-021."
Usage: #example
* meta
  * profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>AuditEvent bij introspectie van een HTI launch token</div>"
* insert NLlang
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/autorisatieserver)
    * type = "Device"
* type = $DCM#110114 "User Authentication"
* subtype = $DCM#110143 "Introspection HTI launch token"
* action = #E
* recorded = "2026-06-09T10:27:31.389+00:00"
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
