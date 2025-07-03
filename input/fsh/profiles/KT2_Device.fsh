Profile: KT2_Device
Parent: Device
Id: KT2Device
Description: "The (FHIR) Device (resource) is a representation of an application that is used in the provision of healthcare without being substantially changed through that activity. The device may be a module, portal or eHealth app."
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