Profile: KT2_DeletePendingTask
Parent: Task
Id: KT2DeletePendingTask
Title: "KT2 Delete Pending Task"
Description: "Het KT2_DeletePendingTask profiel representeert de aankondiging dat de data van een patiënt binnen de Koppeltaalvoorziening gepland staat voor definitieve verwijdering (`$purge`). De Koppeltaalvoorziening maakt bij het ingaan van de grace period per opt-in doelapplicatie één Task aan (Patient × doelapplicatie). De doelapplicatie reageert via de native Task-lifecycle: `on-hold` als tijdelijke noodrem en `accepted` als groen licht. De Task valt in het Patient-compartiment en verdwijnt mee in de `$purge`. Dit profiel is een eerste voorstel; zie de pagina Opschoning Patient-data."
* ^version = "0.1.0"
* ^status = #draft
* ^date = "2026-06-09"
* insert ContactAndPublisher
* insert Origin
// Vaste code; markeert dit als aankondigings-Task voor het opschoningsproces.
* code = $koppeltaal-task-code#delete-pending
  * ^short = "Type van de aankondigings-Task"
// Een vaststaande purge wordt aangekondigd.
* intent = #order (exactly)
* status ^comment = "Native Task-lifecycle. De Koppeltaalvoorziening zet `requested` (create), `cancelled` (hernieuwde betrokkenheid) en `completed` (`$purge` uitgevoerd). De doelapplicatie zet uitsluitend `on-hold` (tijdelijke noodrem) of `accepted` (groen licht / opheffen noodrem)."
// De Patient die wordt opgeschoond; plaatst de Task in het Patient-compartiment.
* for 1..1
* for only Reference(KT2_Patient)
  * ^short = "De Patient die wordt opgeschoond"
// De opt-in doelapplicatie (altijd een Device); nooit de Patient/RelatedPerson,
// omdat dat de bewaartermijn-klok (T_task_owner) zou resetten.
* owner 1..1
* owner only Reference(KT2_Device)
  * ^short = "De opt-in doelapplicatie waarvoor deze aankondiging geldt"
  * ^comment = "Altijd een Device. Nooit de Patient of een RelatedPerson, omdat een Task met de patiënt als owner als patiëntbetrokkenheid telt en de bewaartermijn zou resetten."
// De Koppeltaalvoorziening.
* requester 1..1
* requester only Reference(KT2_Device)
  * ^short = "De Koppeltaalvoorziening die de verwijdering aankondigt"
// Geplande $purge; de doelapplicatie leest hieruit hoeveel tijd resteert.
* restriction 1..1
* restriction.period 1..1
* restriction.period.end 1..1
  * ^short = "Grace-deadline: het geplande moment van de `$purge`"
