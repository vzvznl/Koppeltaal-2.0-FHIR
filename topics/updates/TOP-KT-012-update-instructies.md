# TOP-KT-012 (a/b/c) — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-012a — FHIR REST API Foutafhandeling · TOP-KT-012b — FHIR REST Client foutafhandeling · TOP-KT-012c — Foutafhandeling bij de launch |
| Bron-PDF | topics/KTSA-TOP-KT-012a - FHIR REST API Foutafhandeling-140726-142632.pdf · topics/KTSA-TOP-KT-012b - FHIR REST Client foutafhandeling-140726-142719.pdf · topics/KTSA-TOP-KT-012c - Foutafhandeling bij de launch-140726-142919.pdf |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

TOP-KT-028 (Opschoning patiëntgegevens) introduceert een verwijderproces met nieuwe foutsituaties op alle drie de niveaus van het foutafhandelings-cluster: de **server** krijgt te valideren `Task.status`-writes op de `KT2_DeletePendingTask` en een nieuw post-delete-regime (harde erase → `404`, geen tombstone); de **client** moet correct omgaan met een geweigerde status-write, een `404` na verwijdering en gemiste subscription-notificaties; en de **launch** kan een patiënt betreffen die verwijderd is of in de grace period zit. De drie subtopics behandelen elk één van deze perspectieven; dit document geeft per subtopic de wijzigingen en sluit af met een advies over de vraag of een subtopic 012d (foutafhandeling bij niet-geleverde subscription-notificaties) nodig is.

---

## Deel A — TOP-KT-012a (FHIR REST API Foutafhandeling)

Het topic (PDF v0.2.0, 16 jan 2023) beschrijft statuscodes en OperationOutcome-beleid vanuit de server. TOP-KT-028 voegt twee dingen toe die hier thuishoren: de servervalidatie van status-writes op de delete-pending Task, en het statuscode-gedrag ná de definitieve verwijdering.

### W1 — Sectie "Toepassing en restricties" › "Overige fouten en status codes": statuscodes voor de opschoon-flow

- **Actie**: toevoegen (nieuwe subsectie direct ná de bestaande statuscode-tabel, vóór "De OperationOutcome resource")
- **Voorstel** (letterlijk over te nemen):

> #### Statuscodes bij de opschoon-flow (TOP-KT-028)
>
> Bij het opschoonproces van patiëntgegevens (TOP-KT-028 — Opschoning patiëntgegevens) kondigt de Koppeltaalvoorziening een voorgenomen verwijdering aan via een per-applicatie `delete-pending` Task (`KT2_DeletePendingTask`). Een applicatie reageert met een `PUT` op haar **eigen** Task waarin uitsluitend `status` wijzigt (naar `on-hold`, met een coded `statusReason`, of naar `accepted`). De Koppeltaalvoorziening valideert elke overgang; optimistic concurrency via `If-Match`/ETag is hierbij normatief. De volgende situaties kunnen zich voordoen:
>
> | Situatie | HTTP Statuscode | Toelichting |
> | --- | --- | --- |
> | `PUT` op de delete-pending Task van een **andere** applicatie (`Task.owner` ≠ eigen Device) | 403 Forbidden | Buiten het toegekende schrijfrecht: het `kt2-delete-flow`-label geeft alleen schrijfrecht op de eigen Task. |
> | `PUT` die iets anders wijzigt dan `status` (en `statusReason` bij `on-hold`): de server-owned velden `owner`, `for`, `requester`, `code`, `restriction.period.end`, óf een `PUT` waarin het server-owned `kt2-delete-flow`-security-label ontbreekt of gewijzigd is | 403 Forbidden | De server-owned velden en het label mogen alleen ongewijzigd worden teruggestuurd; een `PUT` die het label dropt wordt geweigerd. |
> | `PUT` met een niet-toegestane statusovergang (bijv. naar `cancelled` of `completed` — die zijn server-only — of van `accepted` terug naar `on-hold`) | 403 Forbidden (422 Unprocessable Entity is verdedigbaar wanneer de server dit als profielvalidatie implementeert) | Toegestaan voor de eigenaar is uitsluitend `requested`/`on-hold` → `on-hold`/`accepted`. |
> | `PUT` naar `on-hold` zónder coded `statusReason` | 422 Unprocessable Entity | Profielvalidatie (`KT2_DeletePendingTask`): de noodrem vereist een coded, niet-herleidbare reden. |
> | `PUT` zonder `If-Match`-header | 400 Bad Request (412 of 428 komen in de praktijk ook voor) | `If-Match` is bij deze status-write verplicht. |
> | `PUT` met een verouderde `If-Match`-waarde | 409 Conflict / 412 Precondition Failed | Zie het onderdeel "If-Match header probleem: 409 of 412" — beide codes zijn correct. |
> | `POST` (create) of `DELETE` op een delete-pending Task of een delete-AuditEvent | 403 Forbidden | Deze resources zijn server-owned; er is geen create-/delete-recht. |
>
> Voor de `403`-situaties geldt dat de OperationOutcome — anders dan bij de reguliere autorisatiefouten — **informatief mag zijn**: de opschoon-flow is binnen het domein transparant leesbaar, dus het benoemen van het geweigerde veld of de geweigerde overgang lekt geen bestaan van gegevens. Voorbeeld bij een niet-toegestane overgang:
>
> ```json
> {
>   "resourceType": "OperationOutcome",
>   "issue": [
>     {
>       "severity": "error",
>       "code": "business-rule",
>       "diagnostics": "Niet-toegestane statusovergang op delete-pending Task: 'accepted' -> 'on-hold'. Toegestaan voor de eigenaar: 'requested'/'on-hold' -> 'on-hold'/'accepted'.",
>       "expression": ["Task.status"]
>     }
>   ]
> }
> ```
>
> Het algemene advies van dit topic blijft gelden: met uitzondering van `401` en `403` liggen de exacte codes niet vast en behoort een client op range-niveau te controleren. Hoe een client op deze weigeringen reageert staat in TOP-KT-012b.

- **Motivatie**: TOP-KT-028 maakt servervalidatie van de Task-overgangen normatief (eisen 5, 7, 8 en 9: owner-scoped schrijfrecht, alleen `status` → `on-hold`/`accepted`, `If-Match`/ETag verplicht, weigeren van marker-drop en server-owned-veldmutaties) maar benoemt geen statuscodes; dat is precies het domein van dit topic. De code-keuzes volgen de ontwerptekst ("al het andere — een vreemde Task, een ander veld, `create`/`delete` — blijft 403") en de bestaande 012a-conventies (422 voor validatiefouten, 409/412 voor If-Match).

### W2 — Nieuw onderdeel: statuscodes ná de definitieve verwijdering

- **Actie**: toevoegen (nieuwe subsectie direct ná W1); daarnaast één toelichtende noot bij de bestaande statuscode-tabel
- **Voorstel** (letterlijk over te nemen):

> #### Statuscodes ná de definitieve verwijdering (opschoning)
>
> De definitieve verwijdering in het opschoonproces is een **harde erase**: alle versies van de resources worden gewist. Dit is géén reguliere FHIR `DELETE` (die de history behoudt, waarna een read `410 Gone` geeft). Na de erase is de id voor de server onbekend; het gedrag is daarom:
>
> | Actie | Resource state | HTTP Statuscode |
> | --- | --- | --- |
> | GET /Patient/\<id> (of een andere mee-verwijderde resource) | Verwijderd via opschoning | 404 Not Found |
> | GET /Task/\<id> (delete-pending of historische `cancelled`-Task van de verwijderde patiënt) | Mee-verwijderd | 404 Not Found |
> | GET /Patient/\<id>/_history/\<version> (vread) | History is gewist | 404 Not Found |
> | PUT /Patient/\<id> | Resource bestaat niet | 404 Not Found |
>
> Er wordt bewust **géén `410 Gone`** en geen tombstone gegeven: een `410` zou het eerdere bestaan van de patiënt prijsgeven en vereist behoud van history, waarmee PII via een vread terugleesbaar zou blijven. De OperationOutcome bij deze `404` is summier (`issue.code` = `not-found`) en maakt géén onderscheid tussen "heeft nooit bestaan" en "is verwijderd".
>
> De **gezaghebbende bevestiging** van een uitgevoerde verwijdering is niet de `404`, maar de `destroy`-AuditEvent (`AuditEvent.type` = `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|destroy`) die de verwijdering overleeft; de `GET` → `404` is de fallback. Zie TOP-KT-028 en het onderdeel over de opschoning-lifecycle in Topic 11.

Noot toe te voegen onder de bestaande tabel "Overige fouten en status codes" (bij de rij "Resource is soft-deleted → 410 Gone"):

> De `410 Gone` geldt uitsluitend voor een reguliere FHIR `DELETE` waarbij de history behouden blijft. De definitieve verwijdering uit het opschoonproces (TOP-KT-028) is géén reguliere `DELETE` en geeft `404 Not Found` — zie "Statuscodes ná de definitieve verwijdering (opschoning)".

- **Motivatie**: TOP-KT-028 legt het post-delete-gedrag expliciet vast (eis 14: harde erase, latere `GET` → `404`, geen tombstone, geen vread) en positioneert de `destroy`-AuditEvent als gezaghebbende bevestiging. Zonder deze subsectie spreekt de bestaande tabelrij "soft-deleted → 410" het ontwerp schijnbaar tegen.

### W3 — Overwegingen › "If-Match header probleem: 409 of 412": aanvulling

- **Actie**: wijzigen (één zin toevoegen aan het einde van het bestaande informatieblok)
- **Voorstel** (letterlijk over te nemen):

> Voor de status-writes op de delete-pending Task uit het opschoonproces (TOP-KT-028) is het meesturen van `If-Match` verplicht en is servervalidatie met optimistic concurrency normatief; ook daar zijn zowel `409` als `412` correct.

- **Motivatie**: verankert de normatieve `If-Match`/ETag-eis van TOP-KT-028 (eis 8) op de plek waar lezers het 409/412-gedrag al opzoeken.

### W4 — "Links naar gerelateerde onderwerpen"

- **Actie**: toevoegen
- **Voorstel** (letterlijk over te nemen):

> - TOP-KT-028 — Opschoning patiëntgegevens (statusovergangen delete-pending Task, definitieve verwijdering en `destroy`-AuditEvent)

- **Motivatie**: W1–W3 verwijzen naar TOP-KT-028; de linklijst moet dat volgen.

---

## Deel B — TOP-KT-012b (FHIR REST Client foutafhandeling)

Het topic beschrijft hoe een client verwerkingsfouten meldt (AuditEvent) en onderscheidt verwachte/onverwachte en herstelbare/onherstelbare fouten. TOP-KT-028 voegt drie situaties toe die een client correct moet afhandelen — en die juist géén fout-AuditEvent vereisen.

### W5 — "Toepassing, restricties en eisen" › "Aanleiding": extra situatie

- **Actie**: wijzigen (één opsommingsitem toevoegen aan de lijst met typische situaties)
- **Voorstel** (letterlijk over te nemen):

> - De verwerking van het opschoonproces van patiëntgegevens (TOP-KT-028): het reageren op een delete-pending Task en het afhandelen van de gevolgen van een uitgevoerde verwijdering.

- **Motivatie**: de opschoon-flow is een nieuwe, structurele bron van client-side afhandelsituaties naast de bestaande drie (eigen verwerking, subscription-updates, launch).

### W6 — Nieuw onderdeel: omgaan met de opschoon-flow (TOP-KT-028)

- **Actie**: toevoegen (nieuwe subsectie onder "Toepassing, restricties en eisen", na "Wanneer een AuditEvent aan te maken")
- **Voorstel** (letterlijk over te nemen):

> #### Omgaan met de opschoon-flow (TOP-KT-028)
>
> Het opschoonproces van patiëntgegevens confronteert een applicatie met drie situaties die géén fouten zijn, maar verwachte uitkomsten van het proces. Ze vereisen dan ook geen fout-AuditEvent, wél de juiste afhandeling.
>
> **1. `404` ná een verwijdering — data is definitief weg; geen retry.**
> Na de definitieve verwijdering geeft elke `GET` op de verwijderde resources (Patient, gekoppelde resources, de eigen delete-pending Task) een `404 Not Found`. Dit is geen tijdelijke fout: opnieuw proberen heeft geen zin, de gegevens bestaan niet meer en komen niet terug. De applicatie behoort:
>
> - de retry-logica voor deze resource te stoppen (dit is géén "tijdelijke fout" uit de fouttypologie van dit topic);
> - de eigen administratie af te ronden: lokale verwijzingen naar de verwijderde resources opschonen of afsluiten conform het eigen beleid;
> - géén fout-AuditEvent aan te maken — de verwijdering is door de Koppeltaalvoorziening al vastgelegd in de `destroy`-AuditEvent.
>
> Bij twijfel of een onverwachte `404` het gevolg is van de opschoning, controleert de applicatie op de bijbehorende `destroy`-AuditEvent (`AuditEvent?type=http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|destroy&entity=Patient/{id}`); die is de gezaghebbende bevestiging. Ontbreekt zo'n event, dan geldt de reguliere foutafhandeling van dit topic.
>
> **2. Een geweigerde status-write — herlezen en opnieuw bepalen.**
> Een `PUT` op de eigen delete-pending Task kan worden geweigerd. De afhandeling hangt af van de soort weigering:
>
> - **`409 Conflict` / `412 Precondition Failed`** (verouderde `If-Match`): de Task is intussen gewijzigd. Herlees de Task met een `GET` (actuele status én nieuwe ETag) en bepaal het besluit opnieuw: staat de Task op `cancelled`, dan is de verwijdering afgebroken en is geen actie meer nodig; geeft de `GET` een `404` (of staat de Task op `completed`), dan is de verwijdering voltooid — zie situatie 1; anders kan de status-write met de nieuwe `If-Match`-waarde opnieuw worden aangeboden. Dit is een verwachte, herstelbare situatie: geen fout-AuditEvent, geen beheerdersalarm.
> - **`403 Forbidden` / `422 Unprocessable Entity`**: het verzoek zelf is niet toegestaan — bijvoorbeeld een write op andermans Task, een wijziging van een server-owned veld, een niet-toegestane overgang, een `on-hold` zonder coded `statusReason`, of een `PUT` waarin het server-owned `kt2-delete-flow`-security-label ontbreekt. Ongewijzigd herhalen heeft geen zin; corrigeer het verzoek. Let op: stuur bij een status-write altijd de **volledige** Task terug met alle server-owned velden (inclusief `meta.security`) ongewijzigd.
>
> **3. Gemiste subscription-notificaties — de pull is de garantie.**
> Notificaties via een `Subscription` zijn best-effort. Een applicatie mag er niet van uitgaan dat elke aankondiging als push binnenkomt en behoort daarom periodiek actief te controleren op openstaande verwijderingen:
>
> ```
> GET [base]/Task?code=delete-pending&status=requested
> ```
>
> (Eventueel aangevuld met `&owner=Device/{eigen-device}`; ook zonder dat filter levert de search-narrowing alleen de Tasks die de applicatie mag zien.) Aanbevolen frequentie: ten minste dagelijks — ruim binnen de grace period (`Task.restriction.period.end`, zie TOP-KT-028, Termijnen). Deze poll vangt ook de **grace-reset** af: op de grace-deadline wist de Koppeltaalvoorziening alle holds en herstart de grace period, waarna de Task weer op `requested` staat — een applicatie die wil blijven blokkeren moet dat via de poll opmerken en opnieuw, met reden, `on-hold` zetten.
>
> Voor het post-delete-signaal geldt hetzelfde: subscriben op de `destroy`-AuditEvent (zie TOP-KT-028 voor de criteria) met als pull-fallback een periodieke search op `AuditEvent?type=http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|destroy&_security=https://koppeltaal.nl/fhir/CodeSystem/security-label|kt2-delete-flow`.

- **Motivatie**: dit zijn de drie client-side gedragingen die het TOP-KT-028-ontwerp veronderstelt maar nergens vanuit clientperspectief bijeenbrengt: "geen tombstone" impliceert 404-afhandeling zonder retry, de normatieve servervalidatie impliceert conflict-afhandeling (herlezen → opnieuw), en "push is best-effort, pull is de garantie" impliceert een polling-plicht bij de app. De query's komen letterlijk uit het ontwerp.

### W7 — "Wanneer een AuditEvent aan te maken": afbakening t.o.v. de opschoon-flow

- **Actie**: wijzigen (alinea toevoegen aan het einde van de subsectie)
- **Voorstel** (letterlijk over te nemen):

> De situaties uit het onderdeel "Omgaan met de opschoon-flow (TOP-KT-028)" — een `404` na een uitgevoerde verwijdering, een geweigerde status-write en een gemiste notificatie — zijn verwachte uitkomsten van het opschoonproces en vereisen géén AuditEvent van de applicatie: de Koppeltaalvoorziening legt de procesovergangen zelf geaggregeerd vast (zie de opschoning-lifecycle-events in Topic 11). Alleen wanneer de applicatie de aankondiging niet kán verwerken — bijvoorbeeld een interne fout bij het veiligstellen van data binnen de grace period — geldt de reguliere afhandeling uit dit topic (tijdelijke fout of interne fout, `type` = `transmit`, `outcome` 4/8/12).

- **Motivatie**: voorkomt dat applicaties de opschoon-flow met fout-AuditEvents gaan "melden" en daarmee ruis creëren naast de geaggregeerde lifecycle-events die de Voorziening al aanmaakt (memo Topic 11, §3.8).

---

## Deel C — TOP-KT-012c (Foutafhandeling bij de launch)

Het topic (PDF v1.01, 14 mrt 2025) beschrijft de foutpagina richting de eindgebruiker en de AuditEvent-mapping bij een mislukte launch. TOP-KT-028 voegt het scenario toe van een launch voor een patiënt die verwijderd is — en het spiegel-scenario tijdens de grace period, dat juist géén fout is.

### W8 — Nieuw onderdeel: launch voor een verwijderde patiënt

- **Actie**: toevoegen (nieuwe subsectie onder "Toepassing, restricties en eisen", ná "Foutpagina")
- **Voorstel** (letterlijk over te nemen):

> #### Launch voor een verwijderde patiënt (TOP-KT-028)
>
> Na de definitieve verwijdering uit het opschoonproces (TOP-KT-028) bestaan de Patient en de bijbehorende Taken niet meer; elke `GET` geeft `404 Not Found`. Een launch waarvan het token of de context naar zulke verwijderde resources verwijst (bijvoorbeeld een verouderde koppeling of bookmark) kán daardoor niet slagen: de ontvangende applicatie — of eerder al de autorisatieservice — kan de entiteiten niet valideren of ophalen.
>
> De afhandeling volgt het bestaande beleid van dit topic:
>
> - **Richting de eindgebruiker**: de foutpagina, zónder technische details, mét een referentie (`extension.request-id` en/of `extension.trace-id`). De van toepassing zijnde HTTP-status is `404 Not Found` (4xx: de oorzaak ligt bij het verouderde vertrekpunt van de launch). De pagina maakt géén onderscheid tussen "heeft nooit bestaan" en "is verwijderd" — consistent met het `404`-zonder-tombstone-beleid uit TOP-KT-012a.
> - **Richting de infrastructuur**: een AuditEvent conform de mapping in dit topic (`type` DCM `110100`, `subtype` DCM `110120`, `action` `E`), met `outcome` = `4` ("verwacht"): een launch die strandt op een verwijderde patiënt is een voorspelbaar gevolg van de opschoning en vereist geen aandacht van beheerders. `outcomeDesc` bevat een begrijpelijke melding zonder herleidbare gegevens. Voor `entity.what` wordt de Taak-referentie zonder `_history`-versie gevuld (`Task/<id>`) — de versie is na de erase niet meer op te vragen — of weggelaten als de referentie niet uit het launch-token te herleiden is.
>
> Een applicatie die wil vaststellen dat de `404` inderdaad een uitgevoerde verwijdering betreft, controleert op de bijbehorende `destroy`-AuditEvent (zie TOP-KT-012b, "Omgaan met de opschoon-flow"). Dit scenario kan zich ook als race voordoen wanneer de verwijdering plaatsvindt tijdens een lopende launch (het freeze-window vlak vóór de erase); de afhandeling is gelijk.

- **Motivatie**: het ontwerp garandeert dat verwijderde resources als `404` verschijnen; de launch is het enige kanaal waar dat een eindgebruiker direct raakt. De keuze `outcome = 4` volgt de bestaande fouttypologie van 012b (voorspelbaar = verwacht); de summiere foutpagina en het niet-lekken van "verwijderd vs. nooit bestaan" volgen het bestaande beveiligingsbeleid van dit topic en TOP-KT-028.

### W9 — Nieuw onderdeel (of vervolg-alinea in W8): launch tijdens de grace period is géén foutscenario

- **Actie**: toevoegen (direct aansluitend op W8)
- **Voorstel** (letterlijk over te nemen):

> #### Launch tijdens de grace period — geen foutscenario
>
> Zolang de verwijdering is aangekondigd maar nog niet uitgevoerd (de grace period van de delete-pending Task), blijven alle gegevens actief en ongewijzigd beschikbaar; er bestaat geen archief- of read-only-tussentoestand. Een launch verloopt in deze periode dus **normaal** — er is geen foutpagina en geen fout-AuditEvent.
>
> Sterker: een geslaagde launch/authenticatie van de **patiënt of een gekoppelde naaste** (RelatedPerson) geldt als **hernieuwde betrokkenheid**. De activiteitscheck van de Koppeltaalvoorziening detecteert het nieuwe authenticatie-event en breekt de verwijdering af: de delete-pending Task(s) gaan naar `cancelled` (met een `reactivate`-AuditEvent) en de bewaartermijn herstart. De betrokken applicaties hoeven daarvoor niets te doen; zij zien het terug doordat hun delete-pending Task op `cancelled` staat — de Task blijft bewaard, juist om dit te kunnen onderscheiden van een uitgevoerde verwijdering.
>
> Een launch door een **behandelaar** (Practitioner) tijdens de grace period slaagt eveneens, maar telt níet als patiëntbetrokkenheid en breekt de verwijdering niet af.

- **Motivatie**: zonder deze passage ligt de misinterpretatie voor de hand dat een launch tijdens een aangekondigde verwijdering geweigerd of als fout behandeld moet worden. Het ontwerp zegt het omgekeerde: de launch werkt, en patiënt-/naaste-authenticatie annuleert de verwijdering juist (`T_auth`-hercontrole → `cancelled` + `reactivate`; Practitioner-activiteit telt niet mee in `T_auth`).

### W10 — Verwijzing toevoegen

- **Actie**: toevoegen (onder "Links naar gerelateerde onderwerpen", die nu leeg is)
- **Voorstel** (letterlijk over te nemen):

> - TOP-KT-028 — Opschoning patiëntgegevens (grace period, activiteitscheck, `cancelled`/`reactivate`, definitieve verwijdering)
> - TOP-KT-012a — FHIR REST API Foutafhandeling (statuscodes ná de definitieve verwijdering)
> - TOP-KT-012b — FHIR REST Client foutafhandeling (omgaan met de opschoon-flow)

- **Motivatie**: W8/W9 leunen op deze onderwerpen; de linklijst is nu leeg (`{}`).

---

## Advies 012d-vraag: "foutafhandeling bij het niet leveren van een subscription — is dit elders belegd?"

**Onderzocht.** TOP-KT-006 (PDF v1.0.0, definitief) bevat al een onderdeel **"Events en foutafhandeling"**: bij het verzénden van een notificatie maakt de FHIR resource service een `transmit`-AuditEvent aan, bij het ontvángen maakt de applicatie een `recieve`-AuditEvent aan (met verwijzingen naar TOP-KT-011 en TOP-KT-012b voor verwerkingsfouten). Daarnaast documenteert TOP-KT-006 het read-only veld `Subscription.error` ("de laatste error die is voorgekomen bij het uitvoeren van de rest-hook door de server"). Wat TOP-KT-006 **niet** regelt: het retrygedrag van de server, het op `error` zetten van `Subscription.status` bij herhaald falen, en wiens verantwoordelijkheid het signaleren van een dode webhook is. Het TOP-KT-028-ontwerp legt dat laatste vast (zie de ontwerp-samenvatting): verzendpogingen worden gelogd; bij herhaald falen gaat de `Subscription` op `status=error`; de opschoon-lifecycle loopt gewoon **door** (een dode webhook betekent dus: geen noodrem meer — de pull is de garantie); alerting op delivery-failures is de verantwoordelijkheid van de leverancier.

**Advies: géén nieuw subtopic 012d.** Verwijzen volstaat, om drie redenen:

1. Delivery-failure-afhandeling is een **generieke eigenschap van het subscriptionmechanisme**, niet van foutafhandeling in brede zin — de natuurlijke plek is TOP-KT-006, dat het mechanisme (rest-hook, geen payload, `Subscription.error`) al beschrijft.
2. De enige opschoning-specifieke consequentie — de lifecycle loopt door, óók als notificaties niet aankomen — is al onderdeel van TOP-KT-028 zelf.
3. De client-kant (niet vertrouwen op push; periodieke pull) landt via wijziging W6 in TOP-KT-012b.

Een apart 012d zou dezelfde inhoud over drie bestaande plekken dupliceren zonder eigen normatieve kern. **Voorwaarde** bij dit advies: de update-instructies voor TOP-KT-006 (apart cluster) moeten een onderdeel "Bezorgfouten (delivery failures)" bevatten. Ter afstemming met dat cluster wordt de volgende strekking voorgesteld:

> De FHIR resource service logt elke verzendpoging van een rest-hook-notificatie. Bij herhaald falen zet de service de `Subscription` op `status=error`, met de laatste fout in `Subscription.error`; er worden dan geen notificaties meer afgeleverd totdat de beheerder van de applicatie-instantie het endpoint herstelt en het abonnement heractiveert. Het monitoren van de eigen abonnementen (status en `error`-veld) en het alerteren op afleverfouten is de verantwoordelijkheid van de leverancier van de applicatie. Lopende processen in het domein wachten niet op een niet-afleverbare notificatie: voor het opschoonproces van patiëntgegevens (TOP-KT-028) betekent een dode webhook dat de grace period en de verwijdering gewoon doorlopen — de periodieke pull (TOP-KT-012b) is de garantie, niet de push.

**Mocht de architectuurbespreking tóch een 012d willen** (bijvoorbeeld omdat TOP-KT-006 definitief is en men die niet wil openbreken), dan is de voorgestelde scope strikt: de verantwoordelijkheidsverdeling bij niet-afgeleverde notificaties (server: loggen, `status=error`; leverancier: monitoren en alerteren; domein: processen lopen door) plus de verplichte pull-fallback per use-case — en expliciet **niet** het opnieuw beschrijven van het subscriptionmechanisme of de opschoon-lifecycle.

---

## Verwijzingen

- `topics/TOP-KT-028-opschoning-patientgegevens.md` — besloten ontwerp: status-lifecycle en servervalidatie (eisen 5, 7–9), definitieve verwijdering en 404-gedrag (eis 14), activiteitscheck/`cancelled` (eis 11), delete-AuditEvents (eisen 12–13)
- `input/pagecontent/opschoning-patient-data.md` — IG-pagina (v0.2.1): identieke ontwerptekst, incl. Subscription-voorbeelden en "push is best-effort / pull is de garantie"
- `input/pagecontent/memo-wijzigingen-topic11.md` — §3.6–3.7 (User Authentication / HTI-introspectie, `T_auth`), §3.8 (authenticatie aan applicatiezijde), §3.9 (opschoning-lifecycle-AuditEvents, `destroy` als post-delete-signaal)
- `topics/updates/_briefing-topic-28-updates.md` — gedeelde ontwerp-samenvatting (o.a. de delivery-failure-afspraken)
- TOP-KT-006 — Abonneren op en signaleren van gebeurtenissen (PDF 140726): "Events en foutafhandeling", `Subscription.error`
- TOP-KT-005 — Toegangsbeheersing: de autorisatiematrix waarop de `kt2-delete-flow`-marker een additieve grant is

## Open punten

1. **Delivery-failure-afspraken nog niet in het topicdocument.** De afspraken "verzendpogingen loggen, `Subscription.status=error` bij herhaald falen, alerting bij de leverancier" staan momenteel alleen in de gedeelde ontwerp-samenvatting (briefing), niet letterlijk in TOP-KT-028 of op de IG-pagina (die zegt alleen "push is best-effort … pull is de garantie"). Vóór overname in TOP-KT-006 verifiëren dat dit inderdaad zo is besloten — *afhankelijk van de verdere uitwerking van TOP-KT-028*.
2. **Duur van de grace period.** De briefing noemt 10 dagen (vast; SHOULD), TOP-KT-028 en de IG-pagina noemen 30 dagen default (per domein aanpasbaar). De voorstelteksten verwijzen daarom naar de Termijnen-tabel van TOP-KT-028 zonder zelf een duur te noemen; de aanbevolen pollingfrequentie ("ten minste dagelijks") past bij beide waarden.
3. **Exacte marker-code onder voorbehoud.** De code/het CodeSystem van `kt2-delete-flow` is nog te bevestigen (*afhankelijk van besluit TOP-KT-028 discussiepunt 4/5 — "marker formeel vastleggen"*); de zoekvoorbeelden in W6 nemen de huidige ontwerpwaarde over.
4. **Statuscode bij een niet-toegestane statusovergang.** Het ontwerp zegt "alles buiten het toegekende schrijfrecht blijft 403"; W1 stelt daarom 403 voor, met 422 als verdedigbaar alternatief wanneer de server de overgang als profielvalidatie afdwingt. Definitieve keuze bij de uitwerking van de servervalidatie; voor clients maakt het per het bestaande 012a-advies (range-check) niet uit.
5. **Subscription-provisioning.** Of de app zelf de `Subscription`(s) aanmaakt of de Koppeltaalvoorziening ze vóór-provisioneert is open (*afhankelijk van besluit TOP-KT-028 discussiepunt 5/7*). De pull-fallback uit W6 geldt in beide varianten onverkort.
6. **ERR-eisenpagina niet aangeleverd.** TOP-KT-012a verwijst voor de eisen naar "ERR — Eisen (en aanbevelingen) voor foutafhandeling"; die pagina zat niet bij de bronnen. Controleren of daar eisen over de status-write-validatie en het 404-na-erase-gedrag moeten worden toegevoegd (spiegel van W1/W2).
7. Alle vier de PDF's waren volledig leesbaar; er zijn geen onleesbare delen genoteerd.
