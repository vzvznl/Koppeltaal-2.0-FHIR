Instance: documentreference-documenten-delen
InstanceOf: KT2_DocumentReference
Description: "Voorbeeld van een DocumentReference die vanuit een interventie een voortgangsverslag deelt. De inhoud staat als externe referentie bij de bronapplicatie."
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Voorbeeld van een gedeeld document (voortgangsverslag)</div>"
* insert NLlang
* status = #current
* type = http://loinc.org#11506-3 "Progress note"
* subject = Reference(Patient/patient-volledigenaam)
  * type = "Patient"
* date = "2026-06-09T10:00:00+02:00"
* content.attachment.contentType = #application/pdf
* content.attachment.url = "https://module.example.org/fhir/Binary/2f1c8e9a-7b3d-4c1e-9a2f-6d5b4c3a2e10"
* content.attachment.title = "Voortgangsverslag interventie"
* context.related[task] = Reference(Task/task-minimaal)
  * type = "Task"
