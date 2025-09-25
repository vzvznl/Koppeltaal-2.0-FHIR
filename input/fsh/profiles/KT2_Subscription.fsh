Profile: KT2_Subscription
Parent: Subscription
Id: KT2Subscription
Description: "The Subscription resource defines push-based notifications between systems in the Koppeltaal ecosystem. It enables applications to receive real-time updates when resources matching specified criteria are created or modified. The subscription mechanism ensures timely data synchronization and event-driven communication between healthcare applications."
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