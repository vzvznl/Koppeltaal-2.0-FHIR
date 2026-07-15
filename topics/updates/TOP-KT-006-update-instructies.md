# TOP-KT-006 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-006 — Abonneren op en signaleren van gebeurtenissen |
| Bron-PDF | topics/KTSA-TOP-KT-006 - Abonneren op en signaleren van gebeurtenissen-140726-142332.pdf |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

TOP-KT-028 (Opschoning patiëntgegevens) leunt voor de signalering volledig op het Subscription-mechanisme van dit topic: applicaties abonneren zich op de aankondigings-Tasks (`delete-pending`) en op de `destroy`-AuditEvent die de uitgevoerde verwijdering bevestigt. Daarnaast stelt TOP-KT-028 expliciete eisen aan het gedrag bij afleverfouten (delivery failures), omdat een gemiste notificatie in dit proces betekent dat de noodrem onbereikbaar wordt. TOP-KT-006 beschrijft deze patronen en dat gedrag nu niet.

## Wijzigingen

### W1 — Overwegingen › Search Narrowing en Subscription Narrowing

- **Actie**: wijzigen (alinea toevoegen aan de bestaande sectie)
- **Voorstel**: onderstaande alinea letterlijk toevoegen aan het einde van de sectie:

> De subscription-narrowing neemt — net als de search-narrowing — ook de server-owned resources van het opschoningsproces mee waar de applicatie recht op heeft (de delete-pending Tasks en de opschoning-AuditEvents, herkenbaar aan de `kt2-delete-flow`-`meta.security`-marker). Deze resources worden dus niet weggefilterd uit de notificatie-matching: een `owner=`-filter in de criteria stuurt enkel de routering, niet de toegang. Zie TOP-KT-028 - Opschoning patiëntgegevens.

- **Motivatie**: zonder deze regel zou een strikte lezing van de narrowing de server-owned delete-flow-resources uit de matching kunnen filteren, waardoor de Subscriptions uit W3 en W4 nooit zouden afgaan. TOP-KT-028 ("Toegang buiten de matrix" en "Notificatie via een gewone Subscription") stelt dit normatief; TOP-KT-006 is de plek waar narrowing wordt beschreven.

### W2 — Overwegingen › Events en foutafhandeling

- **Actie**: wijzigen (alinea's toevoegen aan de bestaande sectie)
- **Voorstel**: onderstaande tekst letterlijk toevoegen aan het einde van de sectie:

> **Afleverfouten (delivery failures).** Verzendpogingen van notificaties worden door de FHIR resource service gelogd. Bij herhaald falen van de rest-hook zet de FHIR resource service de `Subscription.status` op `error`. Een falende of gestopte Subscription schort lopende processen niet op: in het bijzonder loopt de opschonings-lifecycle van TOP-KT-028 - Opschoning patiëntgegevens gewoon door — de grace period wacht niet op een geslaagde aflevering.
>
> Het bewaken van de eigen Subscriptions en het alerteren op afleverfouten is de verantwoordelijkheid van de leverancier van de applicatie. Een niet-werkend rest-hook-endpoint betekent voor het opschoningsproces dat de applicatie aankondigingen mist en de noodrem feitelijk onbereikbaar wordt. Push is best-effort; de pull (een reguliere Task-search op openstaande aankondigingen) is de garantie.

- **Motivatie**: TOP-KT-028 legt vast dat de lifecycle doorloopt bij delivery failures en dat alerting bij de leverancier ligt (zie aldaar, "Subscription-delivery-failures"). De sectie "Events en foutafhandeling" behandelt nu alleen AuditEvents (`transmit`/`receive`) en verwerkingsfouten; het failure-gedrag van het kanaal zelf ontbreekt. Het `error`-veld en de status `error` bestaan al in de Subscription-beschrijving van dit topic; dit voorstel maakt de consequentie expliciet.

### W3 — Subscription Criteria

- **Actie**: wijzigen (voorbeeldpatroon toevoegen aan de bestaande sectie)
- **Voorstel**: onderstaande tekst letterlijk toevoegen aan het einde van de sectie:

> **Abonneren op aankondigingen van het opschoningsproces.** Een deelnemende applicatie abonneert zich op haar eigen delete-pending Tasks (zie TOP-KT-028 - Opschoning patiëntgegevens) met criteria op de Task-code en -status:
>
> ```json
> {
>   "resourceType": "Subscription",
>   "status": "active",
>   "reason": "Aankondiging delete-pending (eigen Tasks)",
>   "criteria": "Task?code=delete-pending&owner=Device/{appDevice}&status=requested",
>   "channel": { "type": "rest-hook", "endpoint": "https://module.example.com/notifications/delete-pending" }
> }
> ```
>
> De `owner`-filter beperkt de notificaties tot de eigen Tasks; hij bepaalt de routering, niet de toegang. Mist de applicatie een notificatie, dan vindt zij openstaande aankondigingen terug met dezelfde query als gewone search — de pull is de garantie.

- **Motivatie**: de sectie "Subscription Criteria" geeft nu één voorbeeldpatroon (Tasks gekoppeld aan ActivityDefinitions). Het opschoningsproces introduceert een tweede, verplicht te ondersteunen patroon; het JSON-voorbeeld komt letterlijk uit TOP-KT-028 ("Notificatie via een gewone Subscription").

### W4 — Nieuwe subsectie na "Subscription Criteria": "Signalering van de uitgevoerde verwijdering (post-delete)"

- **Actie**: toevoegen (nieuwe subsectie)
- **Voorstel**: onderstaande tekst letterlijk overnemen:

> **Signalering van de uitgevoerde verwijdering (post-delete)**
>
> Bij de definitieve verwijdering van patiëntgegevens (TOP-KT-028 - Opschoning patiëntgegevens) verdwijnt de delete-pending Task **mee** in de erase. Een Subscription op de Task kan het voltooiingsmoment dus niet signaleren. Het post-delete-signaal is de `destroy`-AuditEvent die de Koppeltaalvoorziening bij de verwijdering vastlegt: die overleeft de verwijdering en is daarmee de gezaghebbende bevestiging. Een applicatie abonneert zich daarop via het `type` van de AuditEvent:
>
> ```json
> {
>   "resourceType": "Subscription",
>   "status": "requested",
>   "reason": "Bevestiging definitieve verwijdering",
>   "criteria": "AuditEvent?type=http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|destroy&_security=https://koppeltaal.nl/fhir/CodeSystem/security-label|kt2-delete-flow",
>   "channel": { "type": "rest-hook", "endpoint": "https://module.example.com/notifications/erased" }
> }
> ```
>
> Als fallback kan een applicatie een `GET` op haar eigen Task doen (`404` = verwijderd); `GET Patient/{id}` → `404` is alleen bruikbaar als de applicatie de Patient eerder mocht lezen. Omdat de notificatie geen payload bevat (zie "Geen payload"), haalt de applicatie de AuditEvent na de notificatie op met dezelfde criteria als search.

- **Motivatie**: dit is het tweede signaleringspatroon uit de instructie: de Task verdwijnt mee in de erase, dus de `destroy`-AuditEvent is de enige bron voor het post-delete-signaal (zie TOP-KT-028, "AuditEvents bij statusovergangen", en memo Wijzigingen TOPKT011 §3.8, "Impact voor leveranciers"). De criteria en JSON komen letterlijk uit TOP-KT-028.

## Verwijzingen

- TOP-KT-028 — Opschoning patiëntgegevens (repo: `topics/TOP-KT-028-opschoning-patientgegevens.md`), m.n. "Notificatie via een gewone Subscription", "AuditEvents bij statusovergangen" en "Subscription-delivery-failures" (eis 13).
- Memo Wijzigingen TOPKT011 (`input/pagecontent/memo-wijzigingen-topic11.md`), §3.8 — AuditEvents voor de opschoning-lifecycle en het post-delete-signaal.
- IG-pagina "Opschoning Patient-data" (`input/pagecontent/opschoning-patient-data.md`).

## Open punten

- **Subscription-provisioning** — *afhankelijk van besluit TOP-KT-028 discussiepunt 5*: maakt elke applicatie de Subscription zelf aan (zoals dit topic nu veronderstelt: "geen use case vanuit domeinbeheer"), of provisioneert de Koppeltaalvoorziening deze vóór? Bij vóór-provisioneren moet ook de passage "De FHIR Subscription" in dit topic worden bijgesteld.
- **Marker-code** — *afhankelijk van besluit TOP-KT-028 discussiepunt 4*: de exacte code/het CodeSystem van `kt2-delete-flow` in de `_security`-criteria (W4) en de narrowing-alinea (W1) kan nog wijzigen.
- **KT2Subscription-profiel**: bevestigen dat het Koppeltaal Subscription-profiel criteria op `AuditEvent` toestaat (het topic noemt nu alleen voorbeelden op `Task`); zo niet, dan moet het profiel daarop worden verruimd voordat W4 uitvoerbaar is.
