CodeSystem: KoppeltaalDeleteHoldReason
Id: koppeltaal-delete-hold-reason
Title: "Koppeltaal Delete Hold Reason"
Description: "Reasons a target application can give when it pauses the deletion of patient data by setting its KT2_DeletePendingTask to `on-hold` (`Task.statusReason`). The list is deliberately closed: the delete-pending Task is readable domain-wide, so the reason must not convey demographics. `Task.statusReason.text` is closed off to keep the reason from becoming a free-text field."
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
* #other "Overige reden" "None of the defined reasons applies. Note that `Task.statusReason.text` is not available for recording reason detail; coordinate with the domain administrator."
