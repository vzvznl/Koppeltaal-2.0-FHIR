CodeSystem: KoppeltaalDeleteHoldReason
Id: koppeltaal-delete-hold-reason
Title: "Koppeltaal Delete Hold Reason"
Description: "Reasons a target application can give when it pauses the deletion of patient data by setting its KT2_DeletePendingTask to `on-hold` (`Task.statusReason`). The list is deliberately closed and free of PII: the delete-pending Task is readable domain-wide, so the reason must not be able to carry demographics or free text."
* ^status = #active
* ^content = #complete
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/CodeSystem"
* ^date = 2026-07-09T12:00:00+02:00
* insert ContactAndPublisher
* ^url = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-delete-hold-reason"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-delete-hold-reason"
* ^version = "2026-07-09"
* ^experimental = false
* ^caseSensitive = true
* ^count = 5
* #data-export-pending "Export naar bronsysteem loopt nog" "The application is still retrieving or exporting data to the source system and needs more time before the data may be deleted."
* #treatment-ongoing "Behandeling loopt nog" "The application observes ongoing treatment activity that is not visible to the Koppeltaal service as patient engagement."
* #patient-objection "Bezwaar tegen verwijdering" "The patient or their representative has objected to the deletion; the objection is being assessed."
* #legal-hold "Wettelijke bewaarplicht of juridische procedure" "A legal retention obligation or pending legal procedure prevents deletion at this moment."
* #other "Overige reden" "None of the defined reasons applies. Note that the reason detail cannot be recorded on the Task (no free text); coordinate with the domain administrator."
