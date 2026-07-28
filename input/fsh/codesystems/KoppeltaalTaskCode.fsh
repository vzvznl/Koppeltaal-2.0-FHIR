CodeSystem: KoppeltaalTaskCode
Id: koppeltaal-task-code
Title: "Koppeltaal Task Code"
Description: "Type of Task.code specifically used in Koppeltaal"
* ^status = #active
* ^content = #complete
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/CodeSystem"
* ^date = 2026-07-09T12:00:00+02:00
* insert ContactAndPublisher
* ^url = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-task-code"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-task-code"
* ^version = "2026-07-09"
* ^experimental = false
* ^caseSensitive = true
* ^count = 2
* #view "This task can be viewed"
* #delete-pending "Delete pending" "Announcement Task indicating that a patient's data is scheduled for definitive deletion from the Koppeltaal service."
