Extension: KT2_CorrelationId
Id: correlation-id
Description: "The correlation-id is an identifier related to the message and the workflow it's part of"
Context: AuditEvent
* ^url = "http://koppeltaal.nl/fhir/StructureDefinition/correlation-id"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* . ..1
* value[x] only id