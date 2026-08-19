ValueSet: KoppeltaalDeletePendingTaskStatus_VS
Id: koppeltaal-delete-pending-task-status
Title: "Koppeltaal Delete Pending Task Status"
Description: "ValueSet for Task.status on the KT2_DeletePendingTask. The deletion announcement only moves through these five of the twelve R4 task statuses; the Koppeltaal service validates every transition between them."
* ^name = "KoppeltaalDeletePendingTaskStatus_ValueSet"
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/shareablevalueset"
* ^url = "http://vzvz.nl/fhir/ValueSet/koppeltaal-delete-pending-task-status"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/ValueSet/koppeltaal-delete-pending-task-status"
* ^status = #active
* ^experimental = false
* ^version = "2026-08-19"
* ^date = 2026-08-19T12:00:00+02:00
* insert ContactAndPublisher
* $task-status#requested "Requested"
* $task-status#on-hold "On Hold"
* $task-status#accepted "Accepted"
* $task-status#cancelled "Cancelled"
* $task-status#completed "Completed"
