Instance: task-delete-pending
InstanceOf: KT2_DeletePendingTask
Description: "Voorbeeld van een aankondigings-Task waarmee de Koppeltaalvoorziening een opt-in doelapplicatie informeert dat de data van een patiënt gepland staat voor verwijdering. De grace-deadline staat in `restriction.period.end`."
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Aankondiging van geplande verwijdering van patiëntdata</div>"
* insert NLlang
* status = #requested
* intent = #order
* code = $koppeltaal-task-code#delete-pending
* for = Reference(Patient/patient-volledigenaam)
  * type = "Patient"
* requester = Reference(Device/autorisatieserver)
  * type = "Device"
* owner = Reference(Device/device-volledig)
  * type = "Device"
* restriction.period.end = "2026-09-09T00:00:00+02:00"
