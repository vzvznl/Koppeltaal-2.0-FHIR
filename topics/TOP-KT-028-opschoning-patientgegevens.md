# TOP-KT-028 - Opschoning patiëntgegevens

| Versie | Datum | Status | Wijzigingen |
| --- | --- | --- | --- |
| 0.1 | 6 mei 2026 | Concept | Concept versie topic 28 opgesteld, onder de titel "Archivering" (lifecycle via `meta.tag` op de Patient). |
| 0.2 | 13 jul 2026 | Concept | Herontwerp overgenomen van de IG-pagina "Opschoning Patient-data" (v0.2.0). Het `meta.tag`-lifecycle-model is vervangen door een FHIR-native Task-workflow (`KT2_DeletePendingTask`) met een server-owned `meta.security`-marker (`kt2-delete-flow`). Betrokkenheidsmodel (`T_auth`), graceful/fast-track-verwijderpad en geaggregeerde AuditEvents op basis van standaard ISO 21089-lifecycle-codes toegevoegd. Titel gewijzigd van "Archivering" naar "Opschoning patiëntgegevens": het ontwerp kent geen aparte gearchiveerde (read-only) tussentoestand meer — data blijft actief tot de definitieve verwijdering. |

> **Status: besluitvormingsdocument.** Input voor de architectuurbespreking; openstaande keuzes staan onder [Discussiepunten](#discussiepunten). Profiel-/FSH-wijzigingen en interactiediagrammen volgen ná besluitvorming.

## Beschrijving

De Koppeltaalvoorziening slaat patiëntgerelateerde FHIR resources op binnen een Koppeltaal-domein. Om aan wettelijke en contractuele bewaartermijnen te kunnen voldoen (AVG, WGBO, NEN 7510, NEN 7513), moeten deze gegevens na verloop van tijd op een gecontroleerde en auditeerbare manier worden verwijderd. Wanneer gegevens worden verwijderd, is het essentieel dat de applicaties die (mogelijk) gebruik maken van deze gegevens hiervan vooraf op de hoogte worden gesteld, zodat zij kunnen acteren en data kunnen veiligstellen.

De gekozen oplossingsrichting is een **standaard FHIR Task-workflow**. De Koppeltaalvoorziening kondigt een voorgenomen verwijdering aan via een per-app delete-pending `Task`; apps lezen die met gewone FHIR-interacties en reageren met een `Task.status`-write (noodrem of groen licht); de server bewaakt de transities en voert na de grace period de definitieve verwijdering intern uit (harde erase). Eén server-owned `meta.security`-marker (`kt2-delete-flow`) regelt de toegang tot de opschoon-resources als **additieve grant** bovenop de bestaande autorisatiematrix — zonder de CRUD-matrix te wijzigen en zonder custom operations. Alle statusovergangen worden vastgelegd in immutable `AuditEvent`-registraties die de verwijdering overleven, zonder dat de regie van het ECD als dossierhouder wordt overgenomen.

> **Waarom niet "Archivering"?** Een eerdere versie van dit topic (0.1) beschreef een archiveringslifecycle op de Patient resource via `meta.tag` (`ARCHIVE_PENDING`, `ARCHIVED`, `PURGE_PENDING`), met een gearchiveerde read-only tussentoestand. Dat model is bij nadere uitwerking afgewezen (zie [Overwogen alternatieven](#overwogen-alternatieven)): het kent geen per-app status, muteert de Patient resource en vereist cross-tenant schrijven. In het huidige ontwerp bestaat er geen aparte archief-toestand: data blijft actief en ongewijzigd beschikbaar tot het moment van definitieve verwijdering. De titel is daarom gewijzigd naar "Opschoning patiëntgegevens".

> De PlantUML-bron van het overzichtsdiagram is beschikbaar in `input/images-source/opschoning-patient-data-overzicht.plantuml`.

## Overwegingen

### Scope

In scope van dit topic zijn de cliëntgerelateerde FHIR-resources binnen de client context en de lifecycle daarvan: bewaartermijnen, het betrokkenheidsmodel, de aankondiging aan betrokken applicaties en de onomkeerbare verwijdering op patiëntniveau. Daarnaast worden de bijbehorende rollen en verantwoordelijkheden binnen het Koppeltaal-stelsel vastgelegd.

Buiten scope zijn niet cliënt-specifieke resources en resources die geen onderdeel vormen van de uitwisselingsdata, waaronder `Practitioner`-resources en operationele of configuratieve resources zoals `Subscription`, `Endpoint` en `Device`. Ook de langdurige archivering van medische dossiers binnen het ECD, functionele of organisatorische processen buiten Koppeltaal en technische of infrastructurele implementatiedetails vallen buiten de scope van deze standaard.

### Uitgangspunten

**Verwijderen op patiëntniveau.** FHIR resources zijn referentieel verbonden; individueel verwijderen geeft integriteitsproblemen. Verwijdering vindt daarom op patiëntniveau plaats — alle aan de patiënt gerelateerde resources als geheel. `RelatedPerson` valt binnen de scope (altijd aan één patiënt gekoppeld); `Practitioner` niet (kan bij meerdere patiënten betrokken zijn).

**Logging en PII gescheiden.** Persoonsgegevens (PII): max. 2 jaar. AuditEvents (NEN 7513): min. 5 jaar. AuditEvents zijn immutable en bevatten geen demografie — alleen technische, **pseudonieme** referenties (zoals een `Patient`-UUID). Na verwijdering van de PII ontsluiten die binnen de voorziening geen herleidbare gegevens meer, maar ze gelden niet als volledig geanonimiseerd.

De Koppeltaalvoorziening initieert het proces zodra de 2-jaarstermijn (vanaf de laatste betrokkenheid) is verstreken. Het ECD heeft op grond van de [WGBO](https://wetten.overheid.nl/BWBR0005290) een eigen termijn (max. 20 jaar) en is zelf verantwoordelijk voor het tijdig veiligstellen van data.

**Geen dataclassificatie via de lifecycle.** FHIR security labels worden binnen dit ontwerp doel-specifiek ingezet (de `kt2-delete-flow`-marker, zie [Toegang buiten de matrix](#toegang-buiten-de-matrix-metasecurity)), niet voor het modelleren van generieke lifecycle-statussen op de data zelf.

### Rollen en verantwoordelijkheden

Opschoning raakt juridische verantwoordelijkheden. Zonder expliciete rolafbakening ontstaat het risico dat verantwoordelijkheden verschuiven of impliciet bij de Koppeltaalvoorziening worden neergelegd. De volgende rolverdeling is vastgelegd:

- **Koppeltaalvoorziening:** verwerker; initieert en faciliteert het opschoonproces op basis van overeengekomen bewaartermijnen, bewaakt de statusovergangen en voert de definitieve verwijdering uit.
- **ECD:** verwerkingsverantwoordelijke en dossierhouder; verantwoordelijk voor het veiligstellen en de langdurige bewaring. Het ECD blijft als bronsysteem leidend voor zorginhoudelijke bewaarplichten en kan aanvullende of afwijkende verwijderbesluiten initiëren (bijv. bij contractbeëindiging of verzoeken van betrokkenen).
- **Doelapplicaties:** autonome deelnemers; verantwoordelijk voor de eigen data en de opvolging van aankondigingen (veiligstellen, noodrem, groen licht).

Deze afbakening sluit aan bij AVG- en AORTA-principes en voorkomt scope-creep van het stelsel.

### Betrokkenheidsmodel: `last-patient-engagement`

Het startmoment voor de bewaartermijn is de **laatste betrokkenheid van de patiënt**. Een Patient is opschoonbaar wanneer `last-patient-engagement` > 2 jaar geleden is. De waarde wordt **niet als state opgeslagen** maar telkens **afgeleid uit bestaande events** — geen state, geen backfill (zie ook [Activiteitscheck](#activiteitscheck-selectie-en-hercontrole)).

**Primair signaal — `T_auth`.** Sinds de **Topic 11-uitbreiding** legt Koppeltaal per launch/authenticatie een geattribueerd `User Authentication`-AuditEvent vast, mét de geauthenticeerde gebruiker op `entity.what` (zie Topic 11, Logging en tracing). `T_auth` = de meest recente **geslaagde** (`outcome = 0`) daarvan (`DCM#110114` / subtype `DCM#110122` of `DCM#110126`) met de Patient of een gekoppelde RelatedPerson op `entity.what`. Een niet-geslaagde login (`outcome != 0`) telt niet mee. De betrokkenheid hangt aan de **geverifieerd ondertekende** launch/authenticatie (`introspect` of `authorize`), niet aan de externe IdP-stap: een `authorize` met `outcome = 0` telt mee, **ook als de daaropvolgende `idp login` mislukt** (`outcome = 8`) — dat IdP-event valt zelf weg via de `outcome = 0`-filter, terwijl de `introspect`/`authorize` de activiteit alsnog markeert. Die `authorize` níet meetellen bij een mislukte IdP-login zou semantisch zuiverder zijn, maar vergt het correleren van events binnen één sessie; die complexiteit nemen we bewust niet. Alle `DCM#110122`/`110126` met `outcome = 0` mogen daarom meetellen, zonder de `idp`-varianten apart uit te sluiten. Practitioner-logins vallen vanzelf buiten `T_auth` (ze staan niet als Patient/RelatedPerson op `entity.what`).

**Selectiecriteria.** Een Patiënt is opschoonbaar (kandidaat voor delete-pending) wanneer aan **álle** voorwaarden is voldaan:

1. de Patiënt **bestaat minimaal 2 jaar** (aanmaakdatum ≥ 2 jaar geleden — de ondergrens: jonger kan nooit);
2. er is **geen geslaagd `T_auth`-event in de afgelopen 2 jaar** (Patiënt of een gekoppelde RelatedPerson op `entity.what`, `outcome = 0`);
3. **én — zolang de Topic 11-uitrol (`C`) nog geen 2 jaar live is** — geen `Task` met deze Patiënt als `Task.for` met een `meta.lastUpdated` in de afgelopen 2 jaar, **de delete-pending Task zelf uitgezonderd** (de tijdelijke `T_legacy`-brug).

De terugkerende selectie slaat daarnaast Patiënten over die **al een actieve delete-pending Task** hebben (idempotentie — anders wordt elke run opnieuw aangekondigd).

**Voorwaarde 3 is tijdelijk.** Patiënten van vóór de uitrol missen `T_auth`-attributie voor hun oude activiteit; de Task-check overbrugt dat domein-breed. Vanaf `C + 2 jaar` ligt het 2-jaarsvenster volledig ná de uitrol — wie nog actief was heeft per definitie een `T_auth`-event — en vervalt de brug; `T_auth` plus de leeftijdsondergrens volstaan dan. Het is dus een **tijdelijke switch**, geen per-patiënt-kenmerk: tot `C + 2 jaar` is elke kandidaat per definitie van vóór de uitrol.

> Dit definieert betrokkenheid als **authenticatie van de Patiënt/RelatedPerson**. Ná de overgang wordt een Patiënt die alléén via Practitioner-activiteit "in zorg" is maar 2 jaar niet inlogde, opschoonbaar — maar het [verwijderpad](#verwijderpad-graceful-of-fast-track) bepaalt het vangnet: met een recente `Task` loopt 'ie via de graceful flow (noodrem bereikbaar), zonder recente `Task` via fast-track.

### Verwijderpad: graceful of fast-track

Vóór `C + 2 jaar` (het overgangsvenster) doorloopt **elke** kandidaat de graceful flow — een per-app delete-pending `Task`, de grace period en de noodrem (zie [Oplossingsrichting](#oplossingsrichting)). Tijdens de overgang is de `T_auth`-attributie nog onvolledig; dit is bewust conservatief — er wordt nooit direct verwijderd.

Vanaf `C + 2 jaar` is de selectie volledig op `T_auth` gebaseerd en bepaalt een **fallback op `Task.meta.lastUpdated`** (dezelfde Task-afleiding als voorwaarde 3, de delete-pending Task uitgezonderd) het pad:

| `Task.meta.lastUpdated` (Patiënt, non-delete-pending) | Pad |
| --- | --- |
| **≤ 2 jaar** | **Graceful** — delete-pending Task(s), grace period, noodrem mogelijk. Vangt een nog lopende behandeling die alleen via Practitioner-activiteit zichtbaar is. |
| **geen / > 2 jaar** | **Fast-track** — directe interne erase, géén aankondiging/grace/noodrem; alleen het `destroy`-AuditEvent als bewijs. |

De `Task` telt hier **niet** mee voor de selectie (een Patiënt zonder login blijft opschoonbaar), alléén voor de **routekeuze**. Beide paden eindigen in dezelfde [definitieve verwijdering](#definitieve-verwijdering), met vlak vóór de erase een laatste auth-hercontrole.

### Termijnen

Vaste termijnen voor een voorspelbaar kader; **alleen de grace period is per domein aanpasbaar** (omhoog of omlaag, begrensd en geaudit).

| Termijn | Waarde | Toelichting |
| --- | --- | --- |
| Grace period | **30 dagen** (default; per domein aanpasbaar) | Window tussen aankondiging (`requested`) en geplande verwijdering; vastgelegd in `restriction.period.end` (server-beheerd; schuift mee bij een grace-reset) |
| Bewaartermijn PII | 2 jaar | Vanaf `last-patient-engagement` (KT2-uitgangspunt) |
| Bewaartermijn AuditEvents | 5 jaar | Minimale logging-bewaartermijn (bevestigen tegen NEN 7513); geen demografie |
| Noodrem-time-out (`on-hold`) | oneindig | Op de grace-deadline worden alle holds gewist en herstart de grace period; om te blijven blokkeren trekt een app telkens opnieuw — met een reden — aan de handrem |

De grace period geldt **niet** voor het [fast-track-pad](#verwijderpad-graceful-of-fast-track) — daar wordt direct verwijderd.

## Oplossingsrichting

De opschoon-flow is een **standaard FHIR Task-workflow**. De Koppeltaalvoorziening zet per deelnemende app een delete-pending `Task` klaar; apps **lezen** die met gewone FHIR-interacties en **reageren** met een `Task.status`-write; de server **bewaakt de transities** en voert de definitieve verwijdering intern uit. Eén mechanisme maakt dit mogelijk zónder de CRUD-matrix te wijzigen: één server-owned **`meta.security`-marker** (`kt2-delete-flow`) die de Koppeltaalvoorziening als **additieve grant** bovenop de matrix leest. Apps gebruiken dezelfde FHIR-interacties die ze al hebben — geen aparte operation: ze **lezen** de flow (Task én delete-AuditEvents) domein-breed en **schrijven** alleen de toegestane status-overgang op hun eigen Task.

| Concern | Mechanisme |
| --- | --- |
| Coördinatie per app | `KT2_DeletePendingTask` (server-owned, app-leesbaar) |
| Toegang buiten de matrix | `meta.security`-marker (`kt2-delete-flow`): **additieve grant** bovenop de matrix — lezen domein-breed, schrijven owner-scoped op de Task |
| App-besluit (noodrem / groen licht) | `Task.status`-write op de **eigen** Task, server-gevalideerd (owner + toegestane overgangen) |
| Notificatie + bevestiging | standaard `Subscription` (Task / delete-`AuditEvent`s); bevestiging via de `destroy`-AuditEvent of `GET` Task/Patient → 404 |
| Definitieve verwijdering | interne harde erase (server-agnostisch, 404, geen tombstone) |

Hieronder eerst de marker (de toegang), daarna de concrete Task-workflow en de verwijdering.

### Toegang buiten de matrix (`meta.security`)

De opschoon-resources — de `KT2_DeletePendingTask` en de delete-`AuditEvent`s — zijn **server-owned** en vallen buiten het reguliere [TOP-KT-005](TOP-KT-005-toegangsbeheersing.md)-CRUD-vlak. Eén **`meta.security`-marker** regelt de toegang: `https://koppeltaal.nl/fhir/CodeSystem/security-label#kt2-delete-flow`. De marker is **doel-specifiek** (géén "overschrijf de hele matrix"-label — dat zou te breed granten) en **server-owned**: alleen de Koppeltaalvoorziening zet 'm, door apps aangeleverde labels worden geweigerd. FHIR laat de betekenis van een security-label aan het lokale toegangsbeleid (i.t.t. `meta.tag`, dat voor workflow is); de Koppeltaalvoorziening interpreteert deze marker als een **additieve leesgrant** ([Security Labels](https://hl7.org/fhir/R4/security-labels.html); access-control is per [FHIR Security](https://hl7.org/fhir/R4/security.html) bewust extern beleid).

**In de gewone resultaten — geen aparte operation.** Een app leest de flow met dezelfde `GET`/search/`Subscription` die ze al heeft. De Koppeltaalvoorziening neemt de server-owned delete-resources waar de app recht op heeft **mee in de search- én subscription-narrowing** — ze worden dus niet weggefilterd, óók niet uit `$count`/paging of notificatie-matching. Wat `GET /Task` oplevert volgt simpelweg uit het matrix-leesrecht:

| Matrix-leesrecht op `Task` | `GET /Task` levert |
| --- | --- |
| mag Tasks lezen | **alle** Tasks — de delete-flow-Tasks zitten er gewoon tussen (één set, dus géén duplicaten) |
| géén leesrecht | **alleen** de delete-flow-Tasks die je mag zien (deelnemer ∩ zelfde-DPA), anders leeg |

Voor `AuditEvent` geldt hetzelfde. Wil je gericht **alléén** de delete-flow-set, dan filter je expliciet op de marker: `_security=…|kt2-delete-flow` (een gewone token-search — opt-in, geen aparte ingang, en de domein-autorisatie blijft gelden). De server **filtert** dan i.p.v. een `403` te geven; een lege Bundle is niet te onderscheiden van "niets bekend" en lekt zo geen bestaan ([FHIR Security](https://hl7.org/fhir/R4/security.html)).

- **Schrijven — owner-scoped.** Het enige schrijfrecht dat erbij komt: een `PUT` op de **eigen** gelabelde Task (`Task.owner` = haar Device), uitsluitend `status` en alleen een legale overgang (zie [Status-lifecycle](#status-lifecycle--server-validatie)). Al het andere — een vreemde Task, een ander veld, `create`/`delete` — blijft `403`. *Let op:* dit is `Task.owner` (de aangewezen app), **niet** de matrix-`own` (resource-origin); KT2 maakt de Task.

De marker is dus de **enige** as: lezen = domein-breed, schrijven = owner-scoped op de Task. AuditEvents zijn **read-only** — dat is **KT2-beleid**, geen FHIR-norm: R4 zegt over AuditEvent alléén dat servers update/delete "would not generally" accepteren ([AuditEvent §6.4.1](https://hl7.org/fhir/R4/auditevent.html)).

**Borging (server, normatief).** (a) De marker is server-owned: weiger 'm op elke client-`create`/`PUT`/transactie/`$meta-add`. (b) Het **DPA-domein van de aanroeper** leidt de server af uit de **geauthenticeerde Device-registratie** + een immutable server-side tenant/partitie — nooit uit een Patient-referentie (die na erase weg is) of uit client-queryparameters. (c) Autoriseer doorsijpel-paden onafhankelijk: `_include`/`_revinclude`, contained resources, history, Subscription-delivery en exports; buiten de KT2-trust-boundary is de marker inert.

> **Privacy.** Domein-transparant: elke deelnemende app ziet de hele opschoon-flow (welke patiënten, welke overgangen) — **pseudonieme UUID's en coded data, geen demografie/directe identifiers**, binnen één DPA-domein. App-leesbare delete-AuditEvents bevatten **geen vrije-tekstvelden** (alleen coded), zodat er geen PII kan lekken. Dat is een bewuste keuze; footprint-versmalling (AVG art. 19) blijft een mogelijke v2 ([discussiepunt](#discussiepunten)).

### Coördinatie via Task (`KT2_DeletePendingTask`)

Het proces wordt aangekondigd via één FHIR `Task` per (Patient × deelnemende applicatie); de Patient zelf wordt niet aangeraakt. Een Task-per-applicatie geeft elke app een eigen, onafhankelijk **workflow**-statusobject (haar eigen handrem en groen licht). De **AuditEvents** zijn daarentegen **geaggregeerd** op procesniveau — de Voorziening logt de geaggregeerde status (zie [AuditEvents](#auditevents-bij-statusovergangen)), niet elke losse Task-write. De Task is **server-owned maar door deelnemende apps leesbaar** (domein-breed, zie [Toegang buiten de matrix](#toegang-buiten-de-matrix-metasecurity)): apps lezen 'm met een gewone `GET` en de **eigen** app reageert met een `Task.status`-write (zie [Status-lifecycle](#status-lifecycle--server-validatie)).

> De PlantUML-bron van het interactiediagram is beschikbaar in `input/images-source/opschoning-patient-data-interactie.plantuml`.

**Per deelnemende applicatie een Task.** De Koppeltaalvoorziening maakt en bezit de aankondigings-Task(s) (`requester` = de Koppeltaalvoorziening). Onder de deelnemers krijgt vooralsnog elke app een Task per opschoning.

**Notificatie via een gewone `Subscription`.** Een app maakt **zelf** een standaard FHIR `Subscription` op haar delete-pending Tasks. De **subscription-narrowing** van de server moet, net als de search-narrowing, de service-Tasks waar de app recht op heeft **meenemen** zodat de criteria matchen (de `owner`-filter stuurt enkel de routering, niet de toegang). Push is best-effort; mist een app een melding, dan vindt ze openstaande verwijderingen met een gewone Task-search — die **pull is de garantie**. *(Of de Koppeltaalvoorziening Subscriptions vóór-provisioneert in plaats van de app, is een [discussiepunt](#discussiepunten).)*

```json
{
  "resourceType": "Subscription",
  "status": "active",
  "reason": "Aankondiging delete-pending (eigen Tasks)",
  "criteria": "Task?code=delete-pending&owner=Device/{appDevice}&status=requested",
  "channel": { "type": "rest-hook", "endpoint": "https://module.example.com/notifications/delete-pending" }
}
```

| Element | Waarde / constraint | Toelichting |
| --- | --- | --- |
| `code` | `delete-pending` (`koppeltaal-task-code`) | Type van de aankondigings-Task |
| `for` | `Reference(KT2_Patient)` (1..1) | Patiënt-anker (`Task?patient=`) én verwijderdoel |
| `owner` | `Reference(KT2_Device)` — **Device van de doelapplicatie** | De app die mag reageren; per-app scoping. **Nooit** Patient/RelatedPerson (zou de klok resetten) |
| `requester` | `Reference(KT2_Device)` — de Koppeltaalvoorziening |  |
| `restriction.period.end` | grace-deadline (**1..1, afgedwongen**) | Geplande verwijdering; server-beheerd — bij een grace-reset zet de server een nieuwe deadline (apps muteren 'm nooit) |
| `statusReason` | reden bij `on-hold` (**coded, geen demografie**) | De noodrem-reden; gezet bij de status-write naar `on-hold` |
| `intent` | `order` | Een vaststaande verwijdering wordt aangekondigd |

**Apart profiel (`Parent: Task`), naast `KT2_Task`.** `KT2_Task` is onverenigbaar (bindt `owner` aan mens-actoren, verbiedt `restriction`/`statusReason`); de aankondigings-Task heeft die juist nodig. Een eigen profiel borgt de exacte vorm als validatiecontract, houdt `owner = Device` dragend (valt buiten de retentieklok), en blijft losgekoppeld van het KoppelMij-openstellen van `KT2_Task`. (Afleiden van een geopend `KT2_Task` kan heroverwogen worden zodra dat traject `KT2_Task` compatibel maakt.)

### Status-lifecycle & server-validatie

De app reageert door **`Task.status` te schrijven** (`PUT` met `If-Match`) op haar eigen Task — geen custom operation; KT2 ondersteunt geen `PATCH`. De Koppeltaalvoorziening **valideert** elke overgang.

> De PlantUML-bron van het statusdiagram is beschikbaar in `input/images-source/opschoning-patient-data-statusflow.plantuml`.

| `Task.status` | Hoe gezet | Betekenis |
| --- | --- | --- |
| `requested` | Koppeltaalvoorziening | Aangekondigd; grace period loopt |
| `on-hold` | app · status-write | Tijdelijke noodrem (coded `statusReason`); vervalt bij de grace-reset of zodra de app `accepted` zet |
| `accepted` | app · status-write | Groen licht: data veiliggesteld/akkoord; telt voor vervroegde voltooiing |
| `cancelled` | Koppeltaalvoorziening | Afgebroken wegens hernieuwde betrokkenheid; **Task blijft behouden** zodat een latere `GET` 'm onderscheidt van een uitgevoerde verwijdering |
| `completed` | Koppeltaalvoorziening | Verwijderd; de Task wordt **mét de Patiënt** opgeruimd |

**Server-validatie (normatief).** De Koppeltaalvoorziening **MOET** de overgangen valideren (optimistic concurrency via `If-Match`/ETag): een app mag op haar **eigen** Task (`owner` = haar Device) alleen `status` → `on-hold`/`accepted` zetten (+ `statusReason` bij `on-hold`), en **niet** `owner`/`for`/`requester`/`code`/`restriction.period.end` of de server-owned `kt2-delete-flow`-marker muteren — een `PUT` die de marker dropt wordt geweigerd. Bij het verlaten van `on-hold` (door de app naar `accepted`, of door de server bij de grace-reset) **wist de server `statusReason`**. De hold-reden is per-applicatie en leeft **op de Task**: inzichtelijk zolang er nog geen verwijdering is; ná de erase verdwijnt hij mee. De geaggregeerde `hold`-AuditEvent draagt geen per-app reden. `cancelled`/`completed` zijn **server-only**.

Noodrem trekken met een coded (non-PII) reden — `PUT Task/{id}` met `If-Match: W/"{etag}"`. De app stuurt de **volledige** Task terug met `status` → `on-hold` en een gezette `statusReason`; de server-owned velden (`code`/`for`/`owner`/`requester`/`restriction`/`meta.security`) gaan ongewijzigd mee — de server weigert wijziging daarvan:

```json
{
  "resourceType": "Task",
  "id": "{id}",
  "meta": { "security": [{ "system": "https://koppeltaal.nl/fhir/CodeSystem/security-label", "code": "kt2-delete-flow" }] },
  "status": "on-hold",
  "statusReason": {
    "coding": [{ "system": "https://koppeltaal.nl/fhir/CodeSystem/delete-hold-reason", "code": "data-export-pending", "display": "Export naar bronsysteem loopt nog" }]
  },
  "intent": "order",
  "code": { "coding": [{ "system": "https://koppeltaal.nl/fhir/CodeSystem/koppeltaal-task-code", "code": "delete-pending" }] },
  "for": { "reference": "Patient/{patientId}" },
  "owner": { "reference": "Device/{appDevice}" }
}
```

De verwijdering mag pas wanneer **geen enkele** Task voor deze Patient op `on-hold` staat, **én** ofwel de grace-deadline is verstreken, **ofwel** álle relevante Tasks staan op `accepted` (vervroegde voltooiing). Staat er bij het verstrijken van de grace-deadline nog een hold, dan worden **alle holds gewist en herstart de grace period** — een app moet dan opnieuw (met reden) aan de handrem trekken (zie [Termijnen](#termijnen)).

### AuditEvents bij statusovergangen

De AuditEvents leggen de **geaggregeerde status van het opschoon-proces per Patiënt** vast — niet de losse `Task.status`-write van een individuele applicatie. De **Koppeltaalvoorziening** maakt ze en logt **één event per aggregaat-overgang**. De codes zijn **standaard ISO 21089 record-lifecycle-codes** op `AuditEvent.type` (`http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle`) — een R4-zoekparameter (`AuditEvent?type=…`), dát is waarop apps de events vinden en subscriben; de flow als geheel is daarnaast vindbaar via het `kt2-delete-flow`-`_security`-label. Een **eigen subtype/CodeSystem is niet nodig**: de ISO 21089-code op `type` is al onderscheidend én doorzoekbaar. Deze records worden bij de verwijdering expliciet behouden.

Een event wordt **alleen** vastgelegd wanneer de **geaggregeerde** toestand wijzigt. Trekt een tweede applicatie ook de handrem, dan gebeurt er niets — de aggregaat-status stond al op `hold`. Laat één van meerdere applicaties los, dan blijft het `hold`; pas wanneer de **laatste** handrem eraf gaat — **én niet meteen álle Tasks op `accepted` staan** — volgt een `unhold`: de blokkade is opgeheven maar het proces loopt door naar de grace-deadline (een echte tussenstand). Betekent diezelfde laatste release dat álle Tasks nú `accepted` zijn, dan is de vervroegde voltooiing bereikt en volgt **direct `destroy`, géén `unhold`** — consistent met het feit dat een kale `accepted` ook geen eigen event krijgt. Een `accepted` zonder voorafgaande hold verschuift de aggregaat-status niet en levert dus **geen** event op. De losse `Task.status`-writes van applicaties worden via de reguliere create/update-AuditEvent gelogd, niet als lifecycle-event.

| Aggregaat-overgang (Patiënt) | ISO 21089 `type` | `action` |
| --- | --- | --- |
| Aangekondigd — Task(s) aangemaakt (`requested`) | `archive` | `C` |
| Geblokkeerd — eerste handrem (`on-hold`) | `hold` | `U` |
| Gedeblokkeerd — laatste handrem eraf (`accepted`) | `unhold` | `U` |
| Grace-reset — holds gewist, grace herstart (`→ requested`) | `archive` | `U` |
| Afgebroken — hernieuwde betrokkenheid (`cancelled`) | `reactivate` | `U` |
| Verwijderd — interne erase (`completed`) | `destroy` | `D` |

Aankondiging en grace-reset delen `archive` — onderscheidbaar via `action` (`C` = eerste aankondiging, `U` = grace-reset). De **grace-reset** is server-gedreven (de Voorziening wist de holds en herstart de grace: `hold → requested`); de **`unhold`** is app-gedreven (de applicaties hebben hun handremmen losgelaten). Enkele velden zijn voor **álle** events gelijk en staan daarom niet in de tabel: `agent.who` = de **Koppeltaalvoorziening** (`Device`), `agent.type` = `DCM#110153` "Source Role ID" (`requestor = true`), `outcome` = `0`, en `entity.what` = **altijd de `Patient`** (`entity=Patient/{id}`, niet de Task). De generieke velden (`request-id`/`correlation-id`/`trace-id`, `source.*`, `recorded`) gelden ook; geen demografie. De reden van een hold (`Task.statusReason`) leeft **op de Task** — per applicatie, inzichtelijk zolang de Task bestaat — en staat niet in de geaggregeerde AuditEvent. Bij **fast-track** ([Verwijderpad](#verwijderpad-graceful-of-fast-track)) ontbreken de aankondigings- en tussenevents; alleen het `destroy`-event wordt vastgelegd.

De `destroy`-AuditEvent overleeft de verwijdering als centraal NEN 7513-record en draagt de `kt2-delete-flow`-marker — deelnemende apps mogen 'm (en de overige delete-`AuditEvent`s) **lezen/subscriben** voor de bevestiging en de flow. Het erase-event heeft `type` `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle#destroy`; daarop abonneert een app:

```json
{
  "resourceType": "Subscription",
  "status": "requested",
  "reason": "Bevestiging definitieve verwijdering",
  "criteria": "AuditEvent?type=http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|destroy&_security=https://koppeltaal.nl/fhir/CodeSystem/security-label|kt2-delete-flow",
  "channel": { "type": "rest-hook", "endpoint": "https://module.example.com/notifications/erased" }
}
```

De `destroy`-AuditEvent is daarmee de **gezaghebbende** bevestiging; een `GET` op de eigen Task (`→ 404`) is fallback, en `GET Patient/{id}` → 404 alleen bruikbaar als de app de Patient eerder mocht lezen.

### Activiteitscheck (selectie en hercontrole)

De **criteria** uit het Betrokkenheidsmodel bepalen de initiële selectie. Vlak vóór de verwijdering wordt **alleen de auth-check** opnieuw gedraaid om **hernieuwde betrokkenheid** te detecteren — bij het graceful pad tijdens de grace period, bij fast-track in de freeze-window vlak vóór de erase. Is er een nieuw geslaagd auth-event, dan stopt de verwijdering: bij graceful gaat de Task → `cancelled` (een `reactivate`-AuditEvent op `type`) en herstart de 2-jaarstermijn; bij fast-track wordt simpelweg niet verwijderd. De overige criteria (leeftijd, transitie-brug) liggen vast bij de selectie.

> De PlantUML-bron van het activiteitscheck-diagram is beschikbaar in `input/images-source/opschoning-patient-data-activiteitscheck.plantuml`.

> *Niet-normatief — implementatie.* Hóé een voorziening deze criteria evalueert (bijvoorbeeld als één interne query met negatie, of als losse FHIR-searches per kandidaat — waarbij chaining naar `RelatedPerson.patient` de gekoppelde RelatedPersons meeneemt en de delete-pending Task zelf wordt uitgesloten) is vrij; alleen de criteria zijn normatief.

### Definitieve verwijdering

De definitieve verwijdering is een **interne server-stap** — alleen de Koppeltaalvoorziening voert 'm uit, na de [activiteitscheck](#activiteitscheck-selectie-en-hercontrole). De erase-semantiek is **server-agnostisch**; *hoe* een server het uitvoert (HAPI `$expunge`, IRIS-eigen mechanisme) is implementatie-detail (FHIR R4 kent geen Patient-`$purge`).

- **Echte erase, geen tombstone.** Dit is een *harde* verwijdering en **geen reguliere FHIR `DELETE`** (die behoudt de history; een latere `read` geeft dan `410 Gone`). De erase wist alle versies, waardoor de id daarna **onbekend** is: een latere `GET` geeft **404** en een `vread` is onmogelijk — anders zou je via de history alsnog PII teruglezen. Bevestiging verloopt via de **gezaghebbende** `destroy`-AuditEvent of een `GET` → 404, zoals beschreven onder [AuditEvents](#auditevents-bij-statusovergangen).
- **Precondities** — *graceful pad*: geen Task op `on-hold`; grace verstreken óf alle relevante Tasks `accepted`; geen hernieuwde betrokkenheid. *Fast-track pad* (vanaf `C + 2 jaar`, geen recente `Task` — zie [Verwijderpad](#verwijderpad-graceful-of-fast-track)): geen aankondiging/grace, direct na een laatste auth-hercontrole. Beide paden: een **lock/freeze-window** tussen de check en de verwijdering voorkomt een race.
- **Scope**: het Patient Compartment, **met `AuditEvent` uitgesloten** — die overleeft als centraal record en mag de verwijderde `Patient/{id}` blijven refereren (referentiële integriteit op dat punt uitgezonderd). De Tasks van deze Patient (`Task` valt niet in het compartiment) worden **apart** mee-verwijderd: de `delete-pending`-Tasks én de historische `cancelled`-Tasks (die verwijzen nu naar een gewiste Patient). Tijdens een lopende cyclus blijft een `cancelled`-Task juist behouden (onderscheidt reactivering van een uitgevoerde verwijdering). Omvat o.a. Patient, RelatedPerson, CareTeam.
- **cascade** vastgezet door policy; de stap is **idempotent** — een herhaling ná een voltooide erase leunt op de overlevende `destroy`-AuditEvent (de instance bestaat dan niet meer), met gedefinieerd failure/retry-gedrag.

### Rechten van betrokkenen & contractbeëindiging

Zolang data aanwezig is, faciliteert de Koppeltaalvoorziening inzage (AVG art. 15) zonder de termijn te herstarten (inzage is geen wijziging); in de praktijk via het EPD. Het **recht om vergeten te worden** (art. 17) is een aparte procedure met eigen toetsing en valt buiten dit topic. Bij **contractbeëindiging** verwijdert of retourneert de Koppeltaalvoorziening de PII aan de verwerkingsverantwoordelijke en legt dat vast via AuditEvents — de interne erase kan hiervoor worden ingezet.

### Overwogen alternatieven

Afgewezen of als variant genoteerd:

- **`meta.tag`-lifecycle op de Patient** — het model uit concept 0.1 van dit topic: archiveringsstatussen (`ARCHIVE_PENDING`, `ARCHIVED`, `PURGE_PENDING`, `ARCHIVE_HOLD`) als `meta.tag` op de Patient resource, met notificatie via Subscriptions op `_tag`. Afgewezen: geen per-app status (één gedeelde noodrem zonder eigenaar), muteert de Patient resource, en vereist cross-tenant schrijven. Ook de aparte gearchiveerde (read-only) tussentoestand is hiermee vervallen.
- **Operation-/webhook-model ("hide-fully")** — de Task verstoppen (search-narrowing) en app-interactie via custom operations + een custom notificatie-payload; afgewezen als te ver van FHIR voor wat het oplost. Het exposed-Task-model (dit topic) houdt de CRUD-matrix intact en is FHIR-native.
- **FHIR soft delete** — geen revert bij cascading delete, geen DELETE-notificaties in R4, onzekere server-ondersteuning.
- **Geen notificatie** — eenvoudigst, maar geen veiligstellen/bezwaar.
- **Two-phase commit** — maximale coördinatie, maar blokkerende apps.
- **`meta.extension last-patient-engagement`** als state — afgewezen t.g.v. de querybenadering: geen tweede bron van waarheid.

## Eisen

> **Concept.** Onderstaande eisen zijn afgeleid uit de normatieve passages van de oplossingsrichting en worden pas definitief na besluitvorming over de [discussiepunten](#discussiepunten).

| # | Eis |
| --- | --- |
| 1 | De Koppeltaalvoorziening MOET verwijdering van patiëntgegevens uitvoeren op patiëntniveau: alle aan de patiënt gerelateerde resources als geheel (Patient Compartment plus de bijbehorende Tasks), met `AuditEvent` uitgezonderd. |
| 2 | De Koppeltaalvoorziening MOET de selectie van opschoonbare patiënten afleiden uit bestaande events (`T_auth`, aanmaakdatum en — tot `C + 2 jaar` — de `Task`-brug), zonder aparte state bij te houden. |
| 3 | De Koppeltaalvoorziening MOET vóór `C + 2 jaar` elke kandidaat via het graceful pad laten lopen; vanaf `C + 2 jaar` MOET de routekeuze (graceful of fast-track) worden bepaald op basis van `Task.meta.lastUpdated` (de delete-pending Task uitgezonderd). |
| 4 | De Koppeltaalvoorziening MOET bij het graceful pad per (Patient × deelnemende applicatie) een `KT2_DeletePendingTask` aanmaken met `code = delete-pending`, `for` = de patiënt, `owner` = het Device van de doelapplicatie, `requester` = de Koppeltaalvoorziening, `intent = order` en een server-beheerde grace-deadline in `restriction.period.end`. |
| 5 | De Koppeltaalvoorziening MOET de `kt2-delete-flow`-`meta.security`-marker exclusief zelf zetten en MOET door clients aangeleverde markers weigeren op elke `create`/`PUT`/transactie/`$meta-add`. |
| 6 | De Koppeltaalvoorziening MOET de marker interpreteren als additieve grant: domein-breed leesrecht op de gelabelde delete-flow-resources (Task en delete-AuditEvents) voor deelnemende applicaties binnen hetzelfde DPA-domein, meegenomen in search- én subscription-narrowing. |
| 7 | De Koppeltaalvoorziening MOET schrijfrecht beperken tot een `PUT` op de eigen Task (`Task.owner` = het Device van de app), uitsluitend voor de statusovergangen `requested/on-hold → on-hold/accepted` (met coded `statusReason` bij `on-hold`); elke andere mutatie — een vreemde Task, andere velden, `create`/`delete`, het droppen van de marker — MOET worden geweigerd. |
| 8 | De Koppeltaalvoorziening MOET statusovergangen valideren met optimistic concurrency (`If-Match`/ETag); de statussen `cancelled` en `completed` MOGEN alleen door de server worden gezet. |
| 9 | De Koppeltaalvoorziening MOET `statusReason` wissen bij het verlaten van `on-hold`. |
| 10 | De Koppeltaalvoorziening MAG pas verwijderen wanneer geen enkele Task voor de patiënt op `on-hold` staat én de grace-deadline is verstreken, óf alle relevante Tasks op `accepted` staan (vervroegde voltooiing). Bij een hold op de grace-deadline MOET de server alle holds wissen en de grace period herstarten. |
| 11 | De Koppeltaalvoorziening MOET vlak vóór de definitieve verwijdering de auth-hercontrole uitvoeren en MOET bij hernieuwde betrokkenheid de verwijdering afbreken (graceful: Task → `cancelled`; fast-track: niet verwijderen), met een lock/freeze-window tussen check en erase. |
| 12 | De Koppeltaalvoorziening MOET de geaggregeerde procesovergangen per patiënt vastleggen als `AuditEvent` met standaard ISO 21089-lifecycle-codes op `AuditEvent.type` (`archive`/`hold`/`unhold`/`reactivate`/`destroy`), met de patiënt op `entity.what` en zonder demografie of vrije tekst. |
| 13 | De delete-AuditEvents — inclusief het `destroy`-event — MOETEN de verwijdering overleven (bewaartermijn min. 5 jaar, NEN 7513) en MOETEN voor deelnemende applicaties leesbaar en subscribebaar zijn via de `kt2-delete-flow`-marker. |
| 14 | De definitieve verwijdering MOET een harde erase zijn: alle versies gewist, een latere `GET` geeft `404`, geen tombstone en geen `vread`. De stap MOET idempotent zijn met gedefinieerd failure/retry-gedrag. |
| 15 | De Koppeltaalvoorziening MOET het DPA-domein van de aanroeper afleiden uit de geauthenticeerde Device-registratie en een immutable server-side tenant/partitie — nooit uit een Patient-referentie of client-queryparameters — en MOET doorsijpel-paden (`_include`/`_revinclude`, contained, history, Subscription-delivery, exports) onafhankelijk autoriseren. |
| 16 | AuditEvents zijn binnen KT2 read-only voor clients (KT2-beleid). |

## Discussiepunten

De volgende punten staan nog open voor de architectuurbespreking:

1. **Domein-transparantie vs. footprint (privacy).** Gekozen: de opschoon-flow is **domein-breed leesbaar** (Tasks + delete-AuditEvents) — elke deelnemer ziet welke patiënten op verwijdering staan en de overgangen (pseudonieme UUID's, coded, geen demografie/vrije tekst, binnen één DPA-domein). AVG art. 19 wijst richting **footprint-based** versmalling als mogelijke v2. Bevestigen met privacy.
2. **Betrokkenheid = authenticatie (ná de transitie).** De Task-brug telt tot `C + 2 jaar` any-actor `Task.meta.lastUpdated` (incl. Practitioner → tijdelijk conservatief); dáárna geldt alleen `T_auth`. Gevolg: ná de transitie wordt een patiënt die enkel via Practitioner-activiteit "in zorg" is maar 2 jaar niet inlogde, opschoonbaar — het [verwijderpad](#verwijderpad-graceful-of-fast-track) bepaalt dan het vangnet (recente `Task` → graceful/noodrem; geen → fast-track). (`meta.lastUpdated` is bovendien optioneel.) Bevestigen.
3. **Subtype `110126`.** FHIR labelt dit "Node Authentication", niet user-login. Handhaven met eigen display, of passender subtype? Nog géén harde SHALL.
4. **`kt2-delete-flow`-marker formeel vastleggen.** De marker en haar interpretatie als **additieve grant** normatief opnemen in de autorisatiepagina's (zie [Topic 05](TOP-KT-005-toegangsbeheersing.md)). Te bevestigen: de exacte code/het CodeSystem; dat AuditEvent-read-only **KT2-beleid** is (geen FHIR-norm); en de borging (server-owned marker; DPA-domein uit de Device-registratie i.p.v. de gewiste Patient; onafhankelijke autorisatie van `_include`/contained/history/export). Verworpen als *méér*-standaard alternatief: een custom `CompartmentDefinition` (R4: compartimenten alleen door HL7 International te definiëren; het Device-compartment dekt Task/Subscription niet) en een `$`-operation (= het al afgewezen hide-fully-model). FHIR `Consent` kán exacte instances benoemen maar blijft policy-data die nog steeds een PDP vereist; server-validatie van de Task-overgangen is normatief.
5. **Deelname/opt-in & Subscription-provisioning.** Hoe wordt een app deelnemer — automatisch elke app in het domein, of een expliciete opt-in (bv. via domeinbeheer)? En provisioneert de Koppeltaalvoorziening de notificatie-`Subscription`(s) vóór, of maakt elke app 'm zelf (R4 staat client-Subscriptions toe)? Open; te beslissen met domeinbeheer/architectuur.

De volgende punten zijn inmiddels **besloten** en in de tekst verwerkt: de delete-AuditEvents leggen de **geaggregeerde** proces-status per patiënt vast, niet elke losse `Task.status`-write (grondslag: KT2-juridisch hoeft de verwijdering niet per client te worden onderbouwd); en de workflow-events worden gediscrimineerd via **standaard ISO 21089-lifecycle-codes op `AuditEvent.type`** in plaats van een custom CodeSystem of `entity.lifecycle` (géén zoekparameter).

## Referenties

- [FHIR R4 Task](https://hl7.org/fhir/R4/task.html) / [Subscription](https://hl7.org/fhir/R4/subscription.html) / [Patient Compartment](https://www.hl7.org/fhir/compartmentdefinition-patient.html)
- [ISO 21089 lifecycle](https://terminology.hl7.org/7.1.0/en/CodeSystem-iso-21089-lifecycle.html) / [Security Labels](https://hl7.org/fhir/R4/security-labels.html) / [FHIR R4 Security](https://hl7.org/fhir/R4/security.html) / [Consent](https://hl7.org/fhir/R4/consent.html) / [CompartmentDefinition](https://hl7.org/fhir/R4/compartmentdefinition.html)
- [SMART Backend Services](https://hl7.org/fhir/smart-app-launch/backend-services.html) / [SMART scopes](https://hl7.org/fhir/smart-app-launch/scopes-and-launch-context.html)
- [AVG](https://eur-lex.europa.eu/eli/reg/2016/679/oj) (art. 5, 15, 17, 19) / [WGBO](https://wetten.overheid.nl/BWBR0005290) / [NEN 7513](https://www.nen.nl/nen-7513-2018-nl-247904)
- IG-pagina "Opschoning Patient-data" (`input/pagecontent/opschoning-patient-data.md`) — bron van dit herontwerp
- [Topic 05 - Toegangsbeheersing](TOP-KT-005-toegangsbeheersing.md) / [Topic 06 - Abonneren op en signaleren van gebeurtenissen](TOP-KT-006-abonneren-op-en-signaleren-van-gebeurtenissen.md) / Topic 11 - Logging en tracing
