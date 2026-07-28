# TOP-KT-002 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-002 — Basis interacties |
| Bron-PDF | topics/KTSA-TOP-KT-002 - Basis interacties-140726-142115.pdf |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

TOP-KT-028 (Opschoning patiëntgegevens) introduceert een systeemtaak waarmee de Koppeltaalvoorziening de voorgenomen verwijdering van patiëntgegevens aankondigt via een per-app `Task` en applicaties daarop reageren met gewone FHIR-interacties (`GET`, search, `PUT` met `If-Match`). Deze interactie hoort daarmee thuis in de set basisinteracties van TOP-KT-002: het topic beschrijft nu vier componenten, maar niet de systeemtaak rond het verwijderproces en het bijbehorende noodrem-mechanisme.

## Wijzigingen

### W1 — Beschrijving (componentenlijst)

- **Actie**: wijzigen (item toevoegen aan de bestaande opsomming)
- **Voorstel**: voeg aan de opsomming onder "Beschrijving" (na "4. Launchen van applicaties") toe:

> 5. Reageren op systeemtaken van de Koppeltaalvoorziening (waaronder het verwijderen van patiëntgegevens)

- **Motivatie**: de opschoon-flow van TOP-KT-028 verloopt volledig via de basisinteracties die dit topic beschrijft (lezen, zoeken, abonneren, status schrijven). Het is een nieuwe categorie interactie — geïnitieerd door de Koppeltaalvoorziening in plaats van door een applicatie — en verdient daarom een eigen plek in de componentenlijst.

### W2 — Nieuwe subsectie na "Launchen": "Systeemtaak: verwijderen van patiëntgegevens"

- **Actie**: toevoegen (nieuwe subsectie op hetzelfde niveau als "FHIR resource service", "Resources zoeken", "Abonneren op veranderingen" en "Launchen")
- **Voorstel**: onderstaande tekst letterlijk overnemen:

> **Systeemtaak: verwijderen van patiëntgegevens**
>
> De Koppeltaalvoorziening kondigt de voorgenomen definitieve verwijdering van patiëntgegevens aan via een aankondigings-`Task` (profiel `KT2_DeletePendingTask`, `code = delete-pending`) per combinatie van patiënt en deelnemende applicatie. De applicatie leest deze Task met de reguliere basisinteracties (`GET`/search, en optioneel een `Subscription` — zie TOP-KT-006 - Abonneren op en signaleren van gebeurtenissen) en reageert door de `Task.status` van haar **eigen** Task te schrijven (`PUT` met `If-Match`):
>
> - **Noodrem**: de applicatie zet haar eigen delete-pending Task op `on-hold`, met een coded reden in `statusReason` (bijvoorbeeld een nog lopende data-export). Zolang een Task van deze patiënt op `on-hold` staat, wordt er niet verwijderd.
> - **Noodrem opheffen / groen licht**: de applicatie zet haar Task op `accepted`. Daarmee vervalt haar noodrem; staan álle Tasks van de patiënt op `accepted`, dan kan de verwijdering vervroegd worden uitgevoerd.
>
> Andere mutaties zijn niet toegestaan: de statussen `cancelled` (afgebroken wegens hernieuwde betrokkenheid) en `completed` (verwijdering uitgevoerd) worden uitsluitend door de Koppeltaalvoorziening gezet, en de server valideert elke overgang. De aankondiging start de grace period; de deadline daarvan staat in `Task.restriction.period.end` en wordt door de server beheerd.
>
> Zie TOP-KT-028 - Opschoning patiëntgegevens voor het volledige proces (betrokkenheidsmodel, grace period, verwijderpad en AuditEvents).

- **Motivatie**: dit is de kern van de instructie: de systeemtaak wordt onderdeel van de set basisinteracties, met het noodrem-mechanisme (`on-hold` + `statusReason` op de eigen Task; opheffen via `accepted`) expliciet benoemd. De tekst volgt de status-lifecycle en server-validatie uit TOP-KT-028 (Oplossingsrichting, "Status-lifecycle & server-validatie") en verwijst voor de details naar dat topic, zodat TOP-KT-002 beknopt blijft.

### W3 — BIA - Eisen (en aanbevelingen) voor Basis interacties

- **Actie**: toevoegen (twee rijen onderaan de eisen-tabel, doornummerend na eis 13)
- **Voorstel**: onderstaande rijen letterlijk overnemen (kolommen: # / Eis / Applicatie-instantie / FHIR Resource service):

> | # | Eis | Applicatie-instantie | FHIR Resource service |
> | --- | --- | --- | --- |
> | 14 | Een applicatie-instantie MAG uitsluitend op haar **eigen** delete-pending Task (`Task.owner` = het eigen Device) de `status` wijzigen, en uitsluitend naar `on-hold` (met een coded `statusReason`) of `accepted`. De `PUT` MOET een `If-Match` header bevatten (zie eis 3). Zie TOP-KT-028 - Opschoning patiëntgegevens. | X |  |
> | 15 | De FHIR resource service MOET de statusovergangen van de delete-pending Task valideren: `on-hold`/`accepted` alleen door de applicatie die `Task.owner` is, `cancelled` en `completed` alleen door de Koppeltaalvoorziening. Elke andere mutatie van deze Task MOET geweigerd worden. Zie TOP-KT-028 - Opschoning patiëntgegevens. | | X |

- **Motivatie**: de eisen-tabel van TOP-KT-002 is de plek waar de interactieregels per rol (applicatie-instantie / FHIR resource service) normatief zijn samengevat. Eis 14 en 15 vatten de schrijfregels en server-validatie uit TOP-KT-028 samen (eisen 7 en 8 aldaar) zonder het proces zelf te dupliceren.

## Verwijzingen

- TOP-KT-028 — Opschoning patiëntgegevens (repo: `topics/TOP-KT-028-opschoning-patientgegevens.md`), m.n. "Status-lifecycle & server-validatie" en de eisen 7–10.
- IG-pagina "Opschoning Patient-data" (`input/pagecontent/opschoning-patient-data.md`) — bron van het ontwerp.
- TOP-KT-006 — Abonneren op en signaleren van gebeurtenissen (voor de notificatiekant van de aankondiging; zie de aparte update-instructies voor dat topic).

## Open punten

- **Duur van de grace period**: de voorsteltekst noemt bewust géén concrete duur maar verwijst naar TOP-KT-028. De gedeelde briefing noemt "10 dagen (vast; SHOULD, onderbouwd afwijken MAY)", terwijl TOP-KT-028 (v0.3, besloten) en de IG-pagina "30 dagen (default; per domein aanpasbaar)" vermelden. De hoofdsessie dient deze discrepantie te beslechten vóór publicatie.
- **Deelname/opt-in** (TOP-KT-028 discussiepunt 5): welke applicaties een delete-pending Task krijgen (elke app in het domein of expliciete opt-in) is nog open; de voorsteltekst spreekt daarom neutraal van "deelnemende applicatie".
- De exacte code/het CodeSystem van de `kt2-delete-flow`-marker is *afhankelijk van besluit TOP-KT-028 discussiepunt 4*; de voorsteltekst voor TOP-KT-002 noemt de marker daarom niet en laat de autorisatiekant bij TOP-KT-005/TOP-KT-028.
