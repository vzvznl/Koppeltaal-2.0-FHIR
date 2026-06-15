Instance: auditevent-entity
InstanceOf: SearchParameter
Usage: #definition
* url = "http://koppeltaal.nl/fhir/SearchParameter/auditevent-entity"
* version = "0.1.0"
* name = "KT2_SearchAuditEventEntity"
* status = #active
* experimental = false
* date = "2026-06-15"
* insert ContactAndPublisherInstance
* description = "Search AuditEvents based on the referenced entity (`AuditEvent.entity.what`). Used by the opschoning activity-check to find the most recent User Authentication event for a Patient or a linked RelatedPerson (`entity=Patient/{id}` resp. chained `entity:RelatedPerson.patient`)."
* purpose = "Determine last patient engagement (`T_auth`) by filtering AuditEvents on the authenticated user that is recorded on `entity.what`."
* code = #entity
* base = #AuditEvent
* type = #reference
* expression = "AuditEvent.entity.what"
* target = #Patient
* target[+] = #RelatedPerson
* target[+] = #Practitioner
* target[+] = #Task
* target[+] = #Device
* chain[0] = "patient"
