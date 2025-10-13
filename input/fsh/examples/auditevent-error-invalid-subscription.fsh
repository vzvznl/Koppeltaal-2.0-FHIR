Instance: auditevent-error-invalid-subscription
InstanceOf: AuditEvent
Description: "Auditevent with error about invalid subscription"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Auditevent with error about invalid subscription</div>"
* type = $audit-event-type#rest "Restful Operation"
* subtype = $restful-interaction#create "create"
* action = #C
* recorded = "2023-01-19T23:42:24+00:00"
* outcome = #4
* outcomeDesc = "Invalid subscription criteria submitted: Patient?status=active Failed to parse match URL[Patient?status=active] - Resource type Patient does not have a parameter with name: status"
* agent
  * type = $DCM#110153
  * who = Reference(device-volledig)
  * requestor = true
* source
  * site = "Koppeltaal Domein X"
  * observer = Reference(ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"
* entity
  * type = $resource-types#OperationOutcome "OperationOutcome"
  * description = "Subscription submission failed"
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
  * valueId = "000000000000000053ce929d0e0e4744"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
  * valueId = "53ce929d0e0e4744"