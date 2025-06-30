Instance: activitydefinition123
InstanceOf: KT2_ActivityDefinition
Title: "Piekermoment (md)"
Description: "Example of an ActivityDefinition that defines the use of a journal"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2ActivityDefinition"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an ActivityDefinition that defines the use of a journal</div>"
* insert NLlang
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
  * valueReference = Reference(endpoint123)
    * type = "Endpoint"
* extension[+]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2PublisherId"
  * valueId = "ID1234-001"
* url = "https://int-381-kt2-sprint-7.minddistrict.dev/catalogue/6bea89a73b3d48d0963d627d93d071c2"
* identifier
  * use = #official
  * system = "http://ns.minddistrict.com/content/id"
  * value = "6bea89a73b3d48d0963d627d93d071c2"
* version = "2022-12-20.19:00:123"
* name = "Pieker_6bea89a73b3d48d0963d627d93d071c2"
* title = "Piekermoment (md)"
* subtitle = "voor jongeren"
* status = #active
* description = """In dit dagboek wordt per piekermoment geregistreerd over welk onderwerp werd gepiekerd, 
welke piekergedachten er voorkwamen en wat hielp om te stoppen met piekeren. """