Instance: auditevent-with-outcome-4
InstanceOf: AuditEvent
Description: "Example of AuditEvent with create Operation resulting in outcome code 4"
Usage: #example
* meta
  * profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of AuditEvent with create Operation resulting in outcome code 4</div>"
* insert NLlang
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(device-volledig)
    * type = "Device"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "f272ae9f83a49bdd"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
  * valueId = "decc45dd65cb97ea25e6d2a53e067f09"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/correlation-id"
  * valueId = "58aafb4e-0283-4c12-b95f-16be1425c96c"
* type = $audit-event-type#rest "RESTful Operation"
* subtype = $restful-interaction#create
* action = #C
* recorded = "2023-01-10T12:50:22+01:00"
* outcome = #4
* agent
  * type = $DCM#110153
  * who = Reference(device-volledig)
  * requestor = true
* source
  * site = "domein1"
  * observer = Reference(device-volledig)
    * type = "Device"
  * type = $security-source-type#4 "Application Server"
* entity[0]
  * what = Reference(no-matching-profile)
  * type = $resource-types#OperationOutcome "OperationOutcome"
* entity[+].type = $resource-types#Patient "Patient"
* contained = no-matching-profile