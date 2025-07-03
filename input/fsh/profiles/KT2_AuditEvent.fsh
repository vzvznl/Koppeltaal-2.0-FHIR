Profile: KT2_AuditEvent
Parent: AuditEvent
Id: KT2AuditEvent
Description: "Koppeltaal AuditEvent profile as used to consolidate logging information."
* ^version = "0.10.0"
* ^status = #draft
* ^date = "2023-01-31"
* insert ContactAndPublisher
* insert Origin
* insert Tracing
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