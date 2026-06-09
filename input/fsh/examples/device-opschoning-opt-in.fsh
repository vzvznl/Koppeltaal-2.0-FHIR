Instance: device-opschoning-opt-in
InstanceOf: KT2_Device
Description: "Voorbeeld van een doelapplicatie (Device) die zich heeft aangemeld voor het opschoningsproces. De opt-in is vastgelegd als `Device.property` met type `deletion-process-opt-in`."
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Doelapplicatie met opt-in voor het opschoningsproces</div>"
* insert NLlang
* identifier
  * system = "http://vzvz.nl/fhir/NamingSystem/koppeltaal-client-id"
  * value = "module-opschoning-opt-in"
* status = #active
* deviceName
  * name = "Behandelmodule met opt-in"
  * type = #user-friendly-name
* type = $sct#86967005 "tool"
* property[deletionOptIn].type = $koppeltaal-device-property-type#deletion-process-opt-in "Deletion process opt-in"
