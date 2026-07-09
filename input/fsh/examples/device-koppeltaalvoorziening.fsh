Instance: device-koppeltaalvoorziening
InstanceOf: Device
Description: "Example of a Device representing the Koppeltaal service (Koppeltaalvoorziening), producer of server-owned resources such as the deletion lifecycle AuditEvents"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Device"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a Device representing the Koppeltaal service (Koppeltaalvoorziening)</div>"
* insert NLlang
* identifier
  * system = "http://vzvz.nl/fhir/NamingSystem/koppeltaal-client-id"
  * value = "koppeltaalvoorziening"
* type = $sct#9096001 "support"
* status = #active
* deviceName
  * name = "Koppeltaalvoorziening"
  * type = #user-friendly-name
