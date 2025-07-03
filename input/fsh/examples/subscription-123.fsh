Instance: subscription-123
InstanceOf: Subscription
Description: "Example of a subscription"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Subscription"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a subscription</div>"
* insert NLlang
* status = #active
* reason = "Meld afgeronde taken"
* criteria = "Task?status=ready"
* channel
  * type = #rest-hook
  * endpoint = "https://koppeltaal-testteam6.nl/fictief-subscription"
  * header = "X-KTSubscription: TaskReady"