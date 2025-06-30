ValueSet: AuditEventType
Id: audit-event-type
Title: "audit-event-type ValueSet"
Description: "ValueSet defining the allowed eventtypes for Koppeltaal"
* ^name = "AuditeventtypeValueSet"
* ^meta.versionId = "2"
* ^meta.lastUpdated = "2022-09-05T12:00:00+02:00"
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/shareablevalueset"
* ^extension.url = "http://hl7.org/fhir/StructureDefinition/resource-effectivePeriod"
* ^extension.valuePeriod.start = "2022-08-22T12:00:00+02:00"
* ^url = "http://koppeltaal.nl/fhir/ValueSet/audit-event-type"
* ^identifier.use = #official
* ^identifier.value = "http://koppeltaal.nl/fhir/ValueSet/audit-event-type"
* ^version = "2022-09-05"
* ^status = #draft
* ^experimental = false
* ^date = "2022-09-05T12:00:00+02:00"
* insert ContactAndPublisher

* include codes from system AuditEventID
* $DCM#110100 "Application Activity"
* $DCM#110114 "User Authentication"
* AuditEventID#hl7-v3
* $iso-21089-lifecycle#transmit "Transmit Record Lifecycle Event"