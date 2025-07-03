Instance: audit-event-with-outcome-4
InstanceOf: AuditEvent
Description: "Auditevent with OperationOutcome"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Auditevent with OperationOutcome</div>"
* extension[0].url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
* extension[=].valueReference = Reference(device-volledig)
* extension[=].valueReference.type = "Device"
* extension[+].url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
* extension[=].valueId = "f272ae9f83a49bdd"
* extension[+].url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
* extension[=].valueId = "decc45dd65cb97ea25e6d2a53e067f09"
* type = $audit-event-type#rest "RESTful Operation"
* subtype = $restful-interaction#create
* action = #C
* recorded = "2023-01-10T12:50:22+01:00"
* outcome = #4
* agent.type = $DCM#110153
* agent.who = Reference(device-volledig)
* agent.requestor = true
* source.site = "domein1"
* source.observer = Reference(device-volledig)
* source.observer.type = "Device"
* source.type = $security-source-type#4 "Application Server"
* entity[0].what = Reference(Inline-no-matching-profile)
* entity[=].type = $resource-types#OperationOutcome "OperationOutcome"
* entity[+].type = $resource-types#Patient "Patient"
* contained = Inline-no-matching-profile