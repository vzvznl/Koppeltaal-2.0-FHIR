Profile: KT2_Subscription
Parent: Subscription
Id: KT2Subscription
Description: "

## Overview

The Subscription resource defines push-based notifications between systems in the Koppeltaal ecosystem. It enables applications to receive real-time updates when resources matching specified criteria are created or modified. The subscription mechanism ensures timely data synchronization and event-driven communication between healthcare applications.

## Channel Type

The channel type is fixed to `rest-hook` - this is the only type available in Koppeltaal for sending notifications.

## Error Handling

The `error` element contains the last error message if the subscription fails, providing debugging information for subscription issues.

## Important Considerations

### Preventing Loops

**Warning**: It is the responsibility of the developer to prevent endless loops caused by sending a subscription notification to the original resource owner. Developers must implement appropriate logic to avoid circular subscription chains.

## Implementation Notes

- Only REST hook channels are supported in the Koppeltaal environment
- Payload elements are not used in this profile
- Proper error handling and loop prevention are critical for stable operation"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* extension ^slicing.discriminator.type = #value
  * ^slicing.discriminator.path = "url"
  * ^slicing.rules = #open
  * ^min = 0
* insert Origin
* error ^comment = "Contains the last error message if the subscription fails."
* channel
  * type = #rest-hook (exactly)
    * ^short = "rest-hook"
    * ^definition = "Only `rest-hook` is available in Koppeltaal\r\nThe type of channel to send notifications on."
  * payload ..0