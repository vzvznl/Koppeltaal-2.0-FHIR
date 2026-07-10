CodeSystem: KoppeltaalSecurityLabel
Id: koppeltaal-security-label
Title: "Koppeltaal Security Label"
Description: "Server-owned security labels (`meta.security`) specific to Koppeltaal. Only the Koppeltaal service assigns these labels; labels supplied by client applications are rejected. The Koppeltaal service interprets them as access-policy markers on top of the TOP-KT-005 authorization matrix."
* ^status = #active
* ^content = #complete
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/CodeSystem"
* ^date = 2026-07-09T12:00:00+02:00
* insert ContactAndPublisher
* ^url = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-security-label"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-security-label"
* ^version = "2026-07-09"
* ^experimental = false
* ^caseSensitive = true
* ^count = 1
* #kt2-delete-flow "KT2 delete flow" "Marks a server-owned resource of the patient-data deletion flow: the delete-pending Task and the deletion lifecycle AuditEvents. The Koppeltaal service interprets this label as an additive grant on top of the authorization matrix — domain-wide read, owner-scoped status writes on the Task. See the page Opschoning Patient-data."
