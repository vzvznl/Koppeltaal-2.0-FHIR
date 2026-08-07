Instance: device-externe-idp
InstanceOf: Device
Description: "Example of a Device representing an external identity provider (IdP)"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Device"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a Device representing an external identity provider (IdP)</div>"
* insert NLlang
* identifier
  * system = "http://vzvz.nl/fhir/NamingSystem/koppeltaal-client-id"
  * value = "externe-idp"
* type = $sct#9096001 "support"
* status = #active
* deviceName
  * name = "Externe IdP"
  * type = #user-friendly-name
