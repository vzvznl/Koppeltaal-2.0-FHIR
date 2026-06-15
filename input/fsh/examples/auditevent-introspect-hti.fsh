Instance: auditevent-introspect-hti
InstanceOf: AuditEvent
Description: "Voorbeeld van een User Authentication AuditEvent dat de Koppeltaalvoorziening vastlegt bij de impliciete HTI-tokenintrospectie van een Koppeltaal-launch. Het gebruikt dezelfde coding als de SMART `/authorize`-call — `DCM#110114` / `DCM#110122` \"Login\" — met de geauthenticeerde gebruiker op `entity.what`. Beide signalen zijn daarmee query-equivalent (`T_auth`) voor de bewaartermijn-afleiding; zie de pagina Opschoning Patient-data."
Usage: #example
* meta
  * profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>AuditEvent bij HTI-introspectie van een Koppeltaal-launch</div>"
* insert NLlang
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/autorisatieserver)
    * type = "Device"
* type = $DCM#110114 "User Authentication"
* subtype = $DCM#110122 "Login"
* action = #E
* recorded = "2026-06-09T10:27:31.389+00:00"
* outcome = #0
* agent
  * type = $DCM#110153
  * who = Reference(device-volledig)
    * type = "Device"
  * requestor = true
* source
  * site = "domeinnaam"
  * observer = Reference(autorisatieserver)
    * type = "Device"
* entity
  * what = Reference(patient-volledigenaam)
    * type = "Patient"
  * role = $object-role#1 "Patient"
