---
topic: kt2endpoint
---
# {{page-title}}

{{tree:http://koppeltaal.nl/fhir/StructureDefinition/KT2Endpoint}}

## Overview

The Endpoint resource represents a technical contact point of an application that offers one or more eHealth services for a healthcare provider. It defines how to connect to and interact with the application.

## Connection Type

The `connectionType` element is fixed to `hti-smart-on-fhir` from the Koppeltaal endpoint connection type value set. This indicates that all Koppeltaal endpoints use the HTI (Healthcare Token Interface) with SMART on FHIR for authentication and authorization.

Example:
```json
{
  "connectionType": {
    "system": "http://koppeltaal.nl/CodeSystem/endpoint-connection-type",
    "code": "hti-smart-on-fhir"
  }
}
```

## Managing Organization

When specified, the `managingOrganization` element must reference a KT2_Organization resource. This indicates which organization manages this endpoint.

Example:
```json
{
  "managingOrganization": {
    "reference": "Organization/example-org"
  }
}
```

## Payload Type

The `payloadType` element is fixed to `any` from the endpoint payload type value set, indicating that the endpoint can handle any type of FHIR resource payload.

Example:
```json
{
  "payloadType": [{
    "coding": [{
      "system": "http://terminology.hl7.org/CodeSystem/endpoint-payload-type",
      "code": "any"
    }]
  }]
}
```

## Address

The `address` element contains the actual URL where the endpoint can be accessed. This should be a fully qualified HTTPS URL.

Example:
```json
{
  "address": "https://example-app.com/fhir/launch"
}
```

## Status

The `status` element indicates the operational status of the endpoint:
- `active` - Endpoint is available for use
- `suspended` - Endpoint is temporarily unavailable
- `error` - Endpoint is in error state
- `off` - Endpoint is turned off
- `test` - Endpoint is in test mode