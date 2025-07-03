Extension: KT2_TraceId
Id: trace-id
Description: "The ID of the workflow. The traceId is intended to track a log entry across multiple logs."
Context: AuditEvent
* ^url = "http://koppeltaal.nl/fhir/StructureDefinition/trace-id"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* . ..1
* . ^comment = "This traceId is intended to track a log entry across multiple logs"
* value[x] only id