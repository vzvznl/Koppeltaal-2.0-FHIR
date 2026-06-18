Profile: KT2_DocumentReference
Parent: DocumentReference
Id: KT2DocumentReference
Title: "KT2 DocumentReference"
Description: "Het DocumentReference resource representeert een document dat vanuit een interventie (module) wordt gedeeld met de dossierhouder (EPD) binnen het Koppeltaal-ecosysteem. De Koppeltaal FHIR store bevat alleen de metadata; de inhoud blijft als externe referentie (`content.attachment.url`) bij de bronapplicatie. Dit profiel is een eerste voorstel; cardinaliteit, target-profielen en bindingen worden na afstemming met leveranciers verder uitgewerkt. Zie de pagina Documenten delen."
* ^version = "0.1.0"
* ^status = #draft
* ^date = "2026-06-09"
* insert ContactAndPublisher
* insert Origin
// Het document moet routeerbaar zijn naar het juiste dossier.
* subject 1..1
* subject only Reference(KT2_Patient)
  * ^short = "De patiënt op wie het document betrekking heeft"
// Ontvangers moeten het type document kunnen herkennen zonder de Binary te openen.
// De binding/ValueSet (LOINC of een Koppeltaal-specifieke ValueSet) is nog een open punt.
* type 1..1
  * ^short = "Soort document (rapportage, vragenlijst-uitkomst, voortgangsverslag, etc.)"
  * ^comment = "De binding/ValueSet voor `type` is nog uit te werken; zie de pagina Documenten delen (Open punten)."
// Ankerpunt voor onder andere de bewaartermijn in de Koppeltaal-store.
* date 1..1
  * ^short = "Tijdstip waarop de DocumentReference is aangemaakt door de module"
// Het document is altijd traceerbaar naar de Task waaruit het is voortgekomen.
* context.related 1..*
  * ^slicing.discriminator.type = #profile
  * ^slicing.discriminator.path = "resolve()"
  * ^slicing.rules = #open
  * ^slicing.description = "Gerelateerde resources; minimaal een verwijzing naar de Task die de interventie representeert."
* context.related contains task 1..1
* context.related[task] only Reference(KT2_Task)
  * ^short = "De Task waaruit het document is voortgekomen"
  * ^definition = "Verwijzing naar de Task die de interventie representeert. Hiermee blijft het document traceerbaar naar de specifieke behandelopdracht."
// De inhoud wordt uitgewisseld via externe referentie; de data blijft aan de bron.
* content.attachment.url 1..
  * ^short = "Externe referentie naar de Binary bij de bronapplicatie"
