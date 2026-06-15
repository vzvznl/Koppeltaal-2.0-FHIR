Instance: auditevent-opschoning-destroy
InstanceOf: AuditEvent
Description: "Opschoning-lifecycle AuditEvent: de Koppeltaalvoorziening heeft de `$purge` uitgevoerd. ISO 21089 `type` = `destroy`, `action` = D; `entity.what` is de opgeschoonde `Patient` (technische referentie, effectief geanonimiseerd ná de `$purge`). Dit event overleeft de `$purge` en draagt het post-delete signaal."
Usage: #example
* meta
  * profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Definitieve verwijdering uitgevoerd (destroy)</div>"
* insert NLlang
* type = $iso-21089-lifecycle#destroy "Destroy/Delete Record Lifecycle Event"
* action = #D
* recorded = "2026-06-19T03:00:00+00:00"
* outcome = #0
* agent
  * type = $DCM#110153 "Source Role ID"
  * who = Reference(autorisatieserver)
    * type = "Device"
  * requestor = true
* source
  * site = "domeinnaam"
  * observer = Reference(autorisatieserver)
    * type = "Device"
* entity
  * what = Reference(patient-volledigenaam)
    * type = "Patient"
  * type = $resource-types#Patient "Patient"
