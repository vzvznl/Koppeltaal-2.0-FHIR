Profile: KT2_Subscription
Parent: Subscription
Id: KT2Subscription
Description: "The (FHIR) Subscription (resource) is used to define a push-based subscription from a server to another system. Once a Subscription is registered with the server, the server checks every resource that is created or updated, and if the resource matches the given criteria, it sends a message on the defined \"channel\" so that another system can take an appropriate action."
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