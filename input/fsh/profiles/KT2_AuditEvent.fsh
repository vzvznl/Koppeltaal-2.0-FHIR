Profile: KT2_AuditEvent
Parent: AuditEvent
Id: KT2AuditEvent
Description: "The AuditEvent resource is used to consolidate and track logging information within the Koppeltaal ecosystem. It captures details about system activities, data access, and interactions between applications for security and compliance purposes."
* ^version = "0.10.0"
* ^status = #draft
* ^date = "2023-01-31"
* insert ContactAndPublisher
* extension contains
    KT2_ResourceOrigin named resource-origin 0..1 and
    KT2_TraceId named traceId 0..* and
    KT2_CorrelationId named correlationId 0..* and
    KT2_RequestId named requestId 0..*
* extension[resource-origin] ^isModifier = false
* extension[traceId] ^isModifier = false
* extension[correlationId] ^isModifier = false
* extension[requestId] ^isModifier = false
* type from $audit-event-type-vs (extensible)
  * insert docAuditEvent
* subtype 
  * insert docAuditEvent
* purposeOfEvent ..0
* agent
  * type 1..
  * type from ParticipationRoleType (extensible)
    * insert docAuditEvent
  * role
    * insert notUsedKT2
  * who 1..
  * who only Reference(KT2_Device)
  * altId ..0
  * name ..0
  * location ..0
  * policy ..0
  * media ..0
  * purposeOfUse ..0
* source
  * site ^definition = "Domainname of the observer"
  * observer only Reference(KT2_Device)
    * ^definition = "Reporter that creates the event"
* entity 1..
  * type 
    * insert docAuditEvent
  * lifecycle
    * insert notUsedKT2
  * securityLabel
    * insert notUsedKT2
  * query ^comment = "Warning: name and query are mutually exclusive. Use query to register the full query, including parameters."
  * detail ..0
// Keep the inherited Reference(Any) target UNVERSIONED. The IG Publisher (2.2.x) otherwise
// version-pins it to .../Resource|4.0.1 during snapshot generation, which defeats the
// org.hl7.fhir.core validator's "any resource" short-circuit (exact unversioned match) and
// makes AuditEvent.entity.what -> Patient fail validation (Reference_REF_WrongTarget).
// The trailing |* marker instructs the publisher not to pin this canonical.
* entity.what only Reference(http://hl7.org/fhir/StructureDefinition/Resource|*)
