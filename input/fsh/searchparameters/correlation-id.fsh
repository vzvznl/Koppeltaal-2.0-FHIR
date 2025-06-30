Instance: correlation-id
InstanceOf: SearchParameter
Usage: #definition
* meta.lastUpdated = "2023-07-10T08:36:17.8901013+00:00"
* url = "http://koppeltaal.nl/fhir/SearchParameter/correlation-id"
* version = "0.1.0"
* name = "KT2_SearchCorrelationId"
* status = #active
* experimental = false
* date = "2023-07-10"
* insert ContactAndPublisherInstance
* description = "Search correlationId for tracking audit events"
* code = #correlationId
* base = #AuditEvent
* type = #token
* expression = "AuditEvent.extension('http://koppeltaal.nl/fhir/StructureDefinition/correlation-id')"
* xpath = "f:AuditEvent/f:extension[@url='http://koppeltaal.nl/fhir/StructureDefinition/correlation-id']"
* xpathUsage = #normal