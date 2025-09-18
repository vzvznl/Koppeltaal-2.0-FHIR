Profile: KT2_Endpoint
Parent: Endpoint
Id: KT2Endpoint
Description: "

## Overview

The Endpoint resource represents the technical contact point for an application that provides eHealth services. It defines the network address, connection protocols, and communication parameters necessary for systems to connect and interact with healthcare applications within the Koppeltaal ecosystem.

## Connection Type

The `connectionType` element is fixed to `hti-smart-on-fhir` from the Koppeltaal endpoint connection type value set. This indicates that all Koppeltaal endpoints use the HTI (Healthcare Token Interface) with SMART on FHIR for authentication and authorization.

Example:
```json
{
  \"connectionType\": {
    \"system\": \"http://koppeltaal.nl/CodeSystem/endpoint-connection-type\",
    \"code\": \"hti-smart-on-fhir\"
  }
}
```

## Managing Organization

When specified, the `managingOrganization` element must reference a KT2_Organization resource. This indicates which organization manages this endpoint.

Example:
```json
{
  \"managingOrganization\": {
    \"reference\": \"Organization/example-org\"
  }
}
```

## Payload Type

The `payloadType` element is fixed to `any` from the endpoint payload type value set, indicating that the endpoint can handle any type of FHIR resource payload.

Example:
```json
{
  \"payloadType\": [{
    \"coding\": [{
      \"system\": \"http://terminology.hl7.org/CodeSystem/endpoint-payload-type\",
      \"code\": \"any\"
    }]
  }]
}
```

## Address

The `address` element contains the actual URL where the endpoint can be accessed. This should be a fully qualified HTTPS URL.

Example:
```json
{
  \"address\": \"https://example-app.com/fhir/launch\"
}
```

## Status

The `status` element indicates the operational status of the endpoint:
- `active` - Endpoint is available for use
- `suspended` - Endpoint is temporarily unavailable
- `error` - Endpoint is in error state
- `off` - Endpoint is turned off
- `test` - Endpoint is in test mode"
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