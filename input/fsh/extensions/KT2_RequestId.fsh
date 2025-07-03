Extension: KT2_RequestId
Id: request-id
Description: "ID of the request. Together with the trace-id it uniquely identifies a request in logging"
Context: AuditEvent
* ^url = "http://koppeltaal.nl/fhir/StructureDefinition/request-id"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* . ..1
* value[x] only id