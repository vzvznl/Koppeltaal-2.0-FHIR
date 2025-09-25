Profile: KT2_Organization
Parent: NlcoreHealthcareProviderOrganization
Id: KT2Organization
Description: "The Organization resource represents a formally or informally recognized grouping of people or organizations that collectively provide healthcare services. This includes healthcare providers, departments, community groups, and healthcare practice groups operating within the Koppeltaal ecosystem. The profile extends the NlcoreHealthcareProviderOrganization profile with Koppeltaal-specific requirements."
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* extension ^slicing.discriminator.type = #value
  * ^slicing.discriminator.path = "url"
  * ^slicing.rules = #open
  * ^min = 0
* insert Origin
* identifier 1..
* active 1..
* alias ..0
* telecom ..0
* address ..0
* partOf only Reference(KT2_Organization)
* contact ..0
* endpoint ..0
* endpoint only Reference(KT2_Endpoint)