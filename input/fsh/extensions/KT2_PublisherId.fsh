Extension: KT2_PublisherId
Id: KT2PublisherId
Description: "Identifier of the publisher (organization or individual). This extension is used as id in the ActivityDefinition."
Context: ActivityDefinition
* ^meta.versionId = "7"
* ^meta.lastUpdated = "2023-01-24T13:04:50.8095698+00:00"
* ^url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2PublisherId"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* . ..1
* . ^comment = "This extension allows every module vendor to search for tasks with linked to their module."
* value[x] only id