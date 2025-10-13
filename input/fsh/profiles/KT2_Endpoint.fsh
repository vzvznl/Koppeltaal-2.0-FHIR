Profile: KT2_Endpoint
Parent: Endpoint
Id: KT2Endpoint
Description: "The Endpoint resource represents the technical contact point for an application that provides eHealth services. It defines the network address, connection protocols, and communication parameters necessary for systems to connect and interact with healthcare applications within the Koppeltaal ecosystem."
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