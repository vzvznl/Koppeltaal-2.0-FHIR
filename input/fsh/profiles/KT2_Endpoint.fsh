Profile: KT2_Endpoint
Parent: Endpoint
Id: KT2Endpoint
Description: "The (FHIR) Endpoint (resource) is a representation of a technical contact point of an application that offers one or more eHealth services for a healthcare provider."
* ^version = "0.8.1"
* ^status = #draft
* ^date = "2023-08-17"
* insert ContactAndPublisher
* insert Origin
* connectionType = KoppeltaalEndpointConnectionType#hti-smart-on-fhir (exactly)
* connectionType from $koppeltaal-endpoint-connection-type-vs (extensible)
* managingOrganization only Reference(KT2_Organization)
* contact ..0
* period ..0
* payloadType = $endpoint-payload-type#any (exactly)
* payloadMimeType ..0