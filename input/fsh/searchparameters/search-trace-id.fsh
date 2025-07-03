Instance: trace-id
InstanceOf: SearchParameter
Usage: #definition
* meta.lastUpdated = "2023-01-24T13:07:53.6125521+00:00"
* url = "http://koppeltaal.nl/fhir/SearchParameter/trace-id"
* version = "0.8.0"
* name = "KT2_SearchTraceId"
* status = #active
* experimental = false
* date = "2023-01-24"
* publisher = "VZVZ"
* contact.name = "VZVZ"
* contact.telecom.system = #url
* contact.telecom.value = "https://www.vzvz.nl"
* contact.telecom.use = #work
* description = "Search trace id for tracking audit events"
* code = #traceId
* base = #AuditEvent
* type = #token
* expression = "AuditEvent.extension('http://koppeltaal.nl/fhir/StructureDefinition/trace-id')"
* xpath = "f:AuditEvent/f:extension[@url='http://koppeltaal.nl/fhir/StructureDefinition/trace-id']"
* xpathUsage = #normal