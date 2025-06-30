Instance: resource-origin-extension
InstanceOf: SearchParameter
Usage: #definition
* meta
  * versionId = "2"
  * lastUpdated = "2023-01-24T13:07:37.3263512+00:00"
* url = "http://koppeltaal.nl/fhir/SearchParameter/resource-origin-extension"
* version = "0.8.0"
* name = "KT2_SearchResourceOrigin"
* status = #active
* date = "2023-01-24"
* insert ContactAndPublisherInstance
* description = "Search domain resources by resource-origin."
* code = #resource-origin
* base[0] = #ActivityDefinition
* base[+] = #CareTeam
* base[+] = #Device
* base[+] = #Organization
* base[+] = #Patient
* base[+] = #Practitioner
* base[+] = #RelatedPerson
* base[+] = #Task
* base[+] = #AuditEvent
* base[+] = #Endpoint
* base[+] = #Subscription
* base[+] = #OperationOutcome
* base[+] = #Bundle
* type = #reference
* expression = "ActivityDefinition.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | CareTeam.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | Device.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | Organization.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | Patient.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | Practitioner.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | RelatedPerson.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | Task.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | AuditEvent.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | Endpoint.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin') | Subscription.extension('http://koppeltaal.nl/fhir/StructureDefinition/resource-origin')"
* xpathUsage = #normal