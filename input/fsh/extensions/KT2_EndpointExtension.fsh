Extension: KT2_EndpointExtension
Id: KT2EndpointExtension
Description: "Reference extension to the service application (endpoint) that provides the eHealth activity."
Context: ActivityDefinition
* ^meta.versionId = "9"
* ^meta.lastUpdated = "2023-01-24T13:04:45.2923549+00:00"
* ^url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* value[x] only Reference(KT2_Endpoint)