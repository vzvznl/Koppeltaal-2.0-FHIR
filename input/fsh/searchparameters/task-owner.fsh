Instance: task-owner
InstanceOf: SearchParameter
Usage: #definition
* url = "http://koppeltaal.nl/fhir/SearchParameter/task-owner"
* version = "0.1.0"
* name = "KT2_SearchTaskOwner"
* status = #active
* experimental = false
* date = "2026-06-15"
* insert ContactAndPublisherInstance
* description = "Search Tasks based on the owner (executor) of the Task (`Task.owner`). Used by the opschoning activity-check to find the most recent Task for which a Patient or a linked RelatedPerson is the executor (`owner=Patient/{id}` resp. chained `owner:RelatedPerson.patient`). The aankondigings-Task (KT2_DeletePendingTask, `owner` = Device) valt buiten een `owner=Patient`-query en beïnvloedt de bewaartermijn-klok dus niet."
* purpose = "Determine last patient engagement (`T_task_owner`) by filtering Tasks on the executing Patient or RelatedPerson."
* code = #owner
* base = #Task
* type = #reference
* expression = "Task.owner"
* target = #Patient
* target[+] = #RelatedPerson
* target[+] = #Practitioner
* target[+] = #CareTeam
* target[+] = #Device
* chain[0] = "patient"
