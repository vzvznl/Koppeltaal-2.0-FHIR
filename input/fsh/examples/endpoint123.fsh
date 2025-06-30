Instance: endpoint123
InstanceOf: Endpoint
Description: "Example of an Endpoint as used in Koppeltaal"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Endpoint"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an Endpoint as used in Koppeltaal</div>"
* insert NLlang
* status = #active
* connectionType = $koppeltaal-endpoint-connection-type#hti-smart-on-fhir
* name = "nu.nl"
* payloadType = $endpoint-payload-type#any
* address = "https://nu.nl"