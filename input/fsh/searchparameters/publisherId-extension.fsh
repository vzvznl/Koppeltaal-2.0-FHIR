Instance: publisherId-extension
InstanceOf: SearchParameter
Usage: #definition
* meta
  * versionId = "2"
  * lastUpdated = "2023-01-24T13:07:26.3087273+00:00"
* url = "http://koppeltaal.nl/fhir/SearchParameter/publisherId-extension"
* version = "0.8.0"
* name = "KT2_SearchPublisherId"
* status = #active
* experimental = false
* date = "2023-01-24"
* insert ContactAndPublisherInstance
* description = "Search by publisherId for an ActivityDefinition"
* code = #publisherId
* base = #ActivityDefinition
* type = #token
* expression = "ActivityDefinition.extension('http://koppeltaal.nl/fhir/StructureDefinition/KT2PublisherId')"
* xpath = "f:ActivityDefinition/f:extension[@url='http://koppeltaal.nl/fhir/StructureDefinition/KT2PublisherId']"
* xpathUsage = #normal
* target = #ActivityDefinition