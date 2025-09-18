Profile: KT2_Device
Parent: Device
Id: KT2Device
Description: "

## Overview

The Device resource represents a software application or system that is used in the provision of healthcare services. Within the Koppeltaal context, this typically includes modules, portals, or eHealth applications that facilitate patient care and data exchange between healthcare systems.

## Identifier

The `identifier` element is mandatory and must use the Koppeltaal client ID naming system.

Example:
```json
{
  \"identifier\": [{
    \"system\": \"http://vzvz.nl/fhir/NamingSystem/koppeltaal-client-id\",
    \"value\": \"example-client-123\"
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
  \"deviceName\": [{
    \"name\": \"My eHealth Application\",
    \"type\": \"user-friendly-name\"
  }]
}
```

## Owner

When specified, the `owner` element must reference a KT2_Organization resource. This indicates which organization owns or is responsible for the device.

Example:
```json
{
  \"owner\": {
    \"reference\": \"Organization/example-org\"
  }
}
```

## Usage Notes

- The Device resource in Koppeltaal is primarily used to represent software applications rather than physical medical devices
- Each application instance should have a unique client ID in the identifier
- The device name should be meaningful to end users who will see it in the system"
* ^version = "0.8.1"
* ^status = #draft
* ^date = "2023-02-07"
* insert ContactAndPublisher
* insert Origin
* extension ^slicing.discriminator.type = #value
  * ^slicing.discriminator.path = "url"
  * ^slicing.rules = #open
  * ^min = 0
* identifier 1..
  * system = "http://vzvz.nl/fhir/NamingSystem/koppeltaal-client-id" (exactly)
* definition ..0
* udiCarrier ..0
* status 1..
  * ^comment = "The default value should be set to 'active'."
* statusReason ..0
  * ^definition = "Reason for the status of the Device availability."
* distinctIdentifier ..0
* manufacturer ..0
* manufactureDate ..0
* expirationDate ..0
* lotNumber ..0
* serialNumber ..0
* deviceName 1..
  * type = #user-friendly-name (exactly)
* modelNumber ..0
* partNumber ..0
* specialization ..0
* version ..0
* property ..0
* patient ..0
* owner only Reference(KT2_Organization)
* contact ..0
* location ..0
* url ..0
* note ..0
* safety ..0
* parent ..0