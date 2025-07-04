---
topic: kt2device
---
# {{page-title}}

{{tree:http://koppeltaal.nl/fhir/StructureDefinition/KT2Device}}

## Overview

The Device resource represents an application that is used in the provision of healthcare without being substantially changed through that activity. In the Koppeltaal context, the device may be a module, portal, or eHealth app.

## Identifier

The `identifier` element is mandatory and must use the Koppeltaal client ID naming system.

Example:
```json
{
  "identifier": [{
    "system": "http://vzvz.nl/fhir/NamingSystem/koppeltaal-client-id",
    "value": "example-client-123"
  }]
}
```

## Status

The `status` element is required. The default value should be set to 'active' for devices that are currently in use.

Valid status values:
- `active` - Device is available for use (default)
- `inactive` - Device is no longer available for use
- `entered-in-error` - Device record entered in error

## Device Name

The `deviceName` element is mandatory and must have the type set to `user-friendly-name`. This provides a human-readable name for the device that can be displayed in user interfaces.

Example:
```json
{
  "deviceName": [{
    "name": "My eHealth Application",
    "type": "user-friendly-name"
  }]
}
```

## Owner

When specified, the `owner` element must reference a KT2_Organization resource. This indicates which organization owns or is responsible for the device.

Example:
```json
{
  "owner": {
    "reference": "Organization/example-org"
  }
}
```

## Usage Notes

- The Device resource in Koppeltaal is primarily used to represent software applications rather than physical medical devices
- Each application instance should have a unique client ID in the identifier
- The device name should be meaningful to end users who will see it in the system