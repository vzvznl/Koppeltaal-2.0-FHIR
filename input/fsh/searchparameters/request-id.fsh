Instance: request-id
InstanceOf: SearchParameter
Usage: #definition
* meta.lastUpdated = "2023-07-09T13:07:53.6125521+00:00"
* url = "http://koppeltaal.nl/fhir/SearchParameter/request-id"
* version = "0.1.0"
* name = "KT2_SearchRequestId"
* status = #active
* experimental = false
* date = "2023-07-10"
* insert ContactAndPublisherInstance
* description = "Search requestId for tracking audit events"
* code = #requestId
* base = #AuditEvent
* type = #token
* expression = "AuditEvent.extension('http://koppeltaal.nl/fhir/StructureDefinition/request-id')"
* xpath = "f:AuditEvent/f:extension[@url='http://koppeltaal.nl/fhir/StructureDefinition/request-id']"
* xpathUsage = #normal