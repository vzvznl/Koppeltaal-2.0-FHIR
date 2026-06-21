### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.1.0 | 2026-06-08 | Initiële versie |
| 0.1.1 | 2026-06-10 | Veldmapping (`action`, `agent.who`, `entity.what`, `outcome`) per lifecycle-event toegevoegd onder "AuditEvents bij statusovergangen" |
| 0.1.2 | 2026-06-15 | `T_authorize` en `T_introspect_hti` samengevoegd tot `T_auth`; formule vereenvoudigd tot `max(T_auth, T_task_owner)`; activiteitscheck filtert op `entity` |
| 0.1.3 | 2026-06-15 | Status-lifecycle-diagram verwijderd; rationale toegevoegd waarom `KT2_DeletePendingTask` een apart profiel is |
| 0.1.4 | 2026-06-17 | `T_auth` verbreed naar `subtype=110122,110126` |
| 0.2.0 | 2026-06-18 | **Herontwerp (besluitvormingsdocument; nog niet released).** Betrokkenheidsmodel = `T_auth` + legacy-fallback; grace 30 dagen. **FHIR-native Task-workflow**: per-app delete-pending `Task` die apps met gewone interacties lezen en beantwoorden (`Task.status`-write); server bewaakt de transities. Eén server-owned **`meta.security`-marker** (`kt2-delete-flow`) leest de Koppeltaalvoorziening als **additieve grant** bovenop de TOP-KT-005-matrix (geen matrixwijziging, geen aparte operation): lezen domein-breed, schrijven owner-scoped op de Task. Notificatie + bevestiging via standaard `Subscription` (Task / `destroy`-AuditEvent) of `GET` → 404. Interne harde erase (404, geen tombstone). Domein-transparant; open keuzes onderaan. |

---

### Opschoning Patient-data

> **Status: besluitvormingsdocument.** Input voor de architectuurbespreking; openstaande keuzes staan onder [Discussiepunten](#discussiepunten). Profiel-/FSH-wijzigingen en interactiediagrammen volgen ná besluitvorming.

De Koppeltaalvoorziening slaat patiëntgerelateerde FHIR resources op die na verloop van tijd verwijderd moeten worden, conform wettelijke bewaartermijnen (AVG, WGBO, NEN 7510, NEN 7513).

### Uitgangspunten

**Verwijderen op patiëntniveau.** FHIR resources zijn referentieel verbonden; individueel verwijderen geeft integriteitsproblemen. Verwijdering vindt daarom op patiëntniveau plaats — alle aan de patiënt gerelateerde resources als geheel. RelatedPerson valt binnen de scope (altijd aan één patiënt gekoppeld); Practitioner niet (kan bij meerdere patiënten betrokken zijn).

**Logging en PII gescheiden.** Persoonsgegevens (PII): max. 2 jaar. AuditEvents (NEN 7513): min. 5 jaar. AuditEvents zijn immutable en bevatten geen demografie — alleen technische, **pseudonieme** referenties (zoals een `Patient`-UUID). Na verwijdering van de PII ontsluiten die binnen de voorziening geen herleidbare gegevens meer, maar ze gelden niet als volledig geanonimiseerd.

De Koppeltaalvoorziening initieert het proces zodra de 2-jaarstermijn (vanaf de laatste betrokkenheid) is verstreken. Het ECD heeft op grond van de [WGBO](https://wetten.overheid.nl/BWBR0005290) een eigen termijn (max. 20 jaar) en is zelf verantwoordelijk voor het tijdig veiligstellen van data.

#### Betrokkenheidsmodel: `last-patient-engagement`

Het startmoment voor de bewaartermijn is de **laatste betrokkenheid van de patiënt**. Een Patient is opschoonbaar wanneer `last-patient-engagement` > 2 jaar geleden is. De waarde wordt **niet als state opgeslagen** maar telkens **afgeleid uit bestaande events** (de queries staan onder [Activiteitscheck](#activiteitscheck-selectie-en-hercontrole)).

**Primair signaal — `T_auth`.** Sinds de **Topic 11-uitbreiding** legt Koppeltaal per launch/authenticatie een geattribueerd `User Authentication`-AuditEvent vast, mét de geauthenticeerde gebruiker op `entity.what` (zie [Wijzigingen TOPKT011](memo-wijzigingen-topic11.html)). `T_auth` = de meest recente **geslaagde** (`outcome = 0`) daarvan (`DCM#110114` / subtype `DCM#110122` of `DCM#110126`) met de Patient of een gekoppelde RelatedPerson op `entity.what`. Een mislukte login (`outcome = 8`) telt niet mee. Practitioner-logins vallen vanzelf buiten `T_auth` (ze staan niet als Patient/RelatedPerson op `entity.what`).

**Legacy-fallback.** Patiënten van vóór deze uitbreiding missen die attributie. Of een patiënt **legacy** is, bepalen we uit zijn **aanmaakdatum** (Patient-create-AuditEvent, `restful-interaction#create`) t.o.v. de uitrol-datum `C`:

| Geval | `last-patient-engagement` |
| --- | --- |
| **Nieuw** (ná `C`) | `T_auth`; geen auth = opschoonbaar (geen Task-check) |
| **Legacy** (vóór `C`) | `max(T_auth, T_legacy)` |
| **Create-AuditEvent ontbreekt** | conservatief als **legacy** behandelen |

`T_legacy` = meest recente `Task.meta.lastUpdated` van de patiënt (`GET /Task?patient=Patient/{id}`, dus `Task.for`), **met `code=delete-pending` uitgesloten** — anders reset een app-update van de aankondigings-Task de klok en veroudert de patiënt nooit. `T_legacy` telt any-actor mee (ook Practitioner) en is bewust conservatief (zie [Discussiepunten](#discussiepunten)). De aanmaakdatum is dus **alleen de schakelaar**, niet de waarde: geen state, geen backfill. Is `last-patient-engagement` leeg, dan start de reguliere procedure.

De evaluatie gaat **van licht naar zwaar**: eerst `T_auth` (één query, dekt de meeste actieve patiënten af). Alleen als die níét binnen 2 jaar valt én de patiënt legacy is, wordt `T_legacy` berekend.

```mermaid
flowchart TD
    P["Patient"] --> A{"T_auth binnen 2 jaar?<br/>(geslaagd auth-event;<br/>Patient of RelatedPerson)"}
    A -->|"ja"| KEEP["actief — niets doen"]
    A -->|"nee / geen"| LEG{"Legacy?<br/>aanmaakdatum van de Patient<br/>(uit de create-AuditEvent)<br/>vóór uitrol-datum C"}
    LEG -->|"Nee — nieuw"| MARK["markeer delete-pending"]
    LEG -->|"Ja — legacy"| TL{"T_legacy binnen 2 jaar?<br/>(meest recente Task.meta.lastUpdated;<br/>excl. code=delete-pending)"}
    TL -->|"ja"| KEEP
    TL -->|"nee / geen"| MARK

    classDef mark fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef keep fill:#e2f7e2,stroke:#27ae60,color:#000;
    class MARK mark;
    class KEEP keep;
```

#### Termijnen

Vaste termijnen voor een voorspelbaar kader; **alleen de grace period is per domein aanpasbaar** (omhoog of omlaag, begrensd en geaudit).

| Termijn | Waarde | Toelichting |
| --- | --- | --- |
| Grace period | **30 dagen** (default; per domein aanpasbaar) | Window tussen aankondiging (`requested`) en geplande verwijdering; vastgelegd in `restriction.period.end` (server-beheerd; schuift mee bij een grace-reset) |
| Bewaartermijn PII | 2 jaar | Vanaf `last-patient-engagement` (KT2-uitgangspunt) |
| Bewaartermijn AuditEvents | 5 jaar | Minimale logging-bewaartermijn (bevestigen tegen NEN 7513); geen demografie |
| Noodrem-time-out (`on-hold`) | oneindig | Op de grace-deadline worden alle holds gewist en herstart de grace period; om te blijven blokkeren trekt een app telkens opnieuw — met een reden — aan de handrem |

### Oplossingsrichting

De opschoon-flow is een **standaard FHIR Task-workflow**. De Koppeltaalvoorziening zet per deelnemende app een delete-pending `Task` klaar; apps **lezen** die met gewone FHIR-interacties en **reageren** met een `Task.status`-write; de server **bewaakt de transities** en voert de definitieve verwijdering intern uit. Eén mechanisme maakt dit mogelijk zónder de CRUD-matrix te wijzigen: één server-owned **`meta.security`-marker** (`kt2-delete-flow`) die de Koppeltaalvoorziening als **additieve grant** bovenop de matrix leest. Apps gebruiken dezelfde FHIR-interacties die ze al hebben — geen aparte operation: ze **lezen** de flow (Task én delete-AuditEvents) domein-breed en **schrijven** alleen de toegestane status-overgang op hun eigen Task.

| Concern | Mechanisme |
| --- | --- |
| Coördinatie per app | `KT2_DeletePendingTask` (server-owned, app-leesbaar) |
| Toegang buiten de matrix | `meta.security`-marker (`kt2-delete-flow`): **additieve grant** bovenop de matrix — lezen domein-breed, schrijven owner-scoped op de Task |
| App-besluit (noodrem / groen licht) | `Task.status`-write op de **eigen** Task, server-gevalideerd (owner + toegestane overgangen) |
| Notificatie + bevestiging | standaard `Subscription` (Task / delete-`AuditEvent`s); bevestiging via de `destroy`-AuditEvent of `GET` Task/Patient → 404 |
| Definitieve verwijdering | interne harde erase (server-agnostisch, 404, geen tombstone) |

Hieronder eerst de marker (de toegang), daarna de concrete Task-workflow en de verwijdering.

#### Toegang buiten de matrix (`meta.security`)

De opschoon-resources — de `KT2_DeletePendingTask` en de delete-`AuditEvent`s — zijn **server-owned** en vallen buiten het reguliere [TOP-KT-005](autorisaties.html)-CRUD-vlak. Eén **`meta.security`-marker** regelt de toegang: `https://koppeltaal.nl/fhir/CodeSystem/security-label#kt2-delete-flow`. De marker is **doel-specifiek** (géén "overschrijf de hele matrix"-label — dat zou te breed granten) en **server-owned**: alleen de Koppeltaalvoorziening zet 'm, door apps aangeleverde labels worden geweigerd. FHIR laat de betekenis van een security-label aan het lokale toegangsbeleid (i.t.t. `meta.tag`, dat voor workflow is); de Koppeltaalvoorziening interpreteert deze marker als een **additieve leesgrant** ([Security Labels](https://hl7.org/fhir/R4/security-labels.html); access-control is per [FHIR Security](https://hl7.org/fhir/R4/security.html) bewust extern beleid).

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

#### Coördinatie via Task (`KT2_DeletePendingTask`)

Het proces wordt aangekondigd via één FHIR `Task` per (Patient × deelnemende applicatie), met AuditEvents voor de aantoonbaarheid; de Patient zelf wordt niet aangeraakt. Een Task-per-applicatie geeft elke app een eigen, onafhankelijk statusobject met eigen audit-spoor (meerdere holds, eigen "groen licht", eigen verslaglegging). De Task is **server-owned maar door deelnemende apps leesbaar** (domein-breed, zie [Toegang buiten de matrix](#toegang-buiten-de-matrix-metasecurity)): apps lezen 'm met een gewone `GET` en de **eigen** app reageert met een `Task.status`-write (zie [Status-lifecycle](#status-lifecycle--server-validatie)).

**Per deelnemende applicatie een Task.** De Koppeltaalvoorziening maakt en bezit de aankondigings-Task(s) (`requester` = de Koppeltaalvoorziening). Onder de deelnemers krijgt vooralsnog elke app een Task per opschoning. **Hoe** een app deelnemer wordt (automatisch, of een expliciete opt-in) en het versmallen naar een footprint-doelgroep (AVG art. 19) zijn [discussiepunten](#discussiepunten).

**Notificatie via een gewone `Subscription`.** Een app maakt **zelf** een standaard FHIR `Subscription` op haar delete-pending Tasks — in R4 mag elke client dat. De **subscription-narrowing** van de server moet, net als de search-narrowing, de service-Tasks waar de app recht op heeft **meenemen** zodat de criteria matchen (de `owner`-filter stuurt enkel de routering, niet de toegang). Push is best-effort; mist een app een melding, dan vindt ze openstaande verwijderingen met een gewone Task-search — die **pull is de garantie**. *(Of de Koppeltaalvoorziening Subscriptions vóór-provisioneert in plaats van de app, is een [discussiepunt](#discussiepunten).)*

```json
{
  "resourceType": "Subscription",
  "status": "requested",
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
| `requester` | `Reference(KT2_Device)` — de Koppeltaalvoorziening | |
| `restriction.period.end` | grace-deadline (**1..1, afgedwongen**) | Geplande verwijdering; server-beheerd — bij een grace-reset zet de server een nieuwe deadline (apps muteren 'm nooit) |
| `statusReason` | reden bij `on-hold` (**coded, geen demografie**) | De noodrem-reden; gezet bij de status-write naar `on-hold` |
| `intent` | `order` | Een vaststaande verwijdering wordt aangekondigd |

**Apart profiel (`Parent: Task`), naast `KT2_Task`.** `KT2_Task` is onverenigbaar (bindt `owner` aan mens-actoren, verbiedt `restriction`/`statusReason`); de aankondigings-Task heeft die juist nodig. Een eigen profiel borgt de exacte vorm als validatiecontract, houdt `owner = Device` dragend (valt buiten de retentieklok), en blijft losgekoppeld van het [KoppelMij-openstellen](memo-koppelmij-scope.html) van `KT2_Task`. (Afleiden van een geopend `KT2_Task` kan heroverwogen worden zodra dat traject `KT2_Task` compatibel maakt.)

#### Status-lifecycle & server-validatie

De app reageert door **`Task.status` te schrijven** (`PUT` met `If-Match`) op haar eigen Task — geen custom operation; KT2 ondersteunt geen `PATCH`. De Koppeltaalvoorziening **valideert** elke overgang.

| `Task.status` | Hoe gezet | Betekenis |
| --- | --- | --- |
| `requested` | Koppeltaalvoorziening | Aangekondigd; grace period loopt |
| `on-hold` | app · status-write | Tijdelijke noodrem (coded `statusReason`); vervalt bij de grace-reset of zodra de app `accepted` zet |
| `accepted` | app · status-write | Groen licht: data veiliggesteld/akkoord; telt voor fast-track |
| `cancelled` | Koppeltaalvoorziening | Afgebroken wegens hernieuwde betrokkenheid; **Task blijft behouden** zodat een latere `GET` 'm onderscheidt van een uitgevoerde verwijdering |
| `completed` | Koppeltaalvoorziening | Verwijderd; de Task wordt **mét de Patiënt** opgeruimd |

**Server-validatie (normatief).** De Koppeltaalvoorziening **MOET** de overgangen valideren (optimistic concurrency via `If-Match`/ETag): een app mag op haar **eigen** Task (`owner` = haar Device) alleen `status` → `on-hold`/`accepted` zetten (+ `statusReason` bij `on-hold`), en **niet** `owner`/`for`/`requester`/`code`/`restriction.period.end` of de server-owned `kt2-delete-flow`-marker muteren — een `PUT` die de marker dropt wordt geweigerd. Bij het verlaten van `on-hold` (door de app naar `accepted`, of door de server bij de grace-reset) **wist de server `statusReason`**; de hold-reden blijft bewaard in het `hold`-AuditEvent en overleeft zo de erase van de Task. `cancelled`/`completed` zijn **server-only**.

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

De verwijdering mag pas wanneer **geen enkele** Task voor deze Patient op `on-hold` staat, **én** ofwel de grace-deadline is verstreken, **ofwel** álle relevante Tasks staan op `accepted` (fast-track). Staat er bij het verstrijken van de grace-deadline nog een hold, dan worden **alle holds gewist en herstart de grace period** — een app moet dan opnieuw (met reden) aan de handrem trekken (zie [Termijnen](#termijnen)).

#### AuditEvents bij statusovergangen

Elke overgang wordt vastgelegd in een immutable AuditEvent. De ISO 21089 lifecycle-code hoort in FHIR R4 op **`AuditEvent.entity.lifecycle`** (`http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle`) en is de **generieke record-actie** (`originate`/`amend`/`hold`/`unhold`/`destroy`); de **workflow-identiteit** (aankondiging/noodrem/accept/annulering/verwijdering) zit in `AuditEvent.type`/`subtype` — meerdere overgangen kunnen dus dezelfde lifecycle-code delen. Deze records worden bij de verwijdering expliciet behouden.

De eerste kolom noemt de **gebeurtenis** met de resulterende `Task.status`. App-acties zijn `Task.status`-writes; de overige zet de Koppeltaalvoorziening.

| Gebeurtenis | `entity.lifecycle` | `action` | `agent.who` | `entity.what` | `outcome` |
| --- | --- | --- | --- | --- | --- |
| Aankondiging — Task `requested` | `originate` | `C` | Koppeltaalvoorziening (`Device`) | de `KT2_DeletePendingTask` | `0` |
| Noodrem — Task → `on-hold` | `hold` | `U` | doelapplicatie (`Device`) | de eigen Task | `0` |
| Holds gewist (grace-reset) — Task → `requested` | `unhold` | `U` | Koppeltaalvoorziening (`Device`) | de Task(s) | `0` |
| Groen licht — Task → `accepted` | `amend` (zie [discussiepunt 4](#discussiepunten)) | `U` | doelapplicatie (`Device`) | de eigen Task | `0` |
| Annulering — Task `cancelled` | `amend` | `U` | Koppeltaalvoorziening (`Device`) | de Task(s) | `0` |
| Verwijdering — Task `completed` | `destroy` | `D` | Koppeltaalvoorziening (`Device`) | de opgeschoonde `Patient/{id}` | `0` |

`agent.type` = `DCM#110153` "Source Role ID" (`requestor = true`); de generieke velden (`request-id`/`correlation-id`/`trace-id`, `source.*`, `recorded`) gelden ook. Geen demografie. De reden van een overgang (coded `statusReason`, of "hernieuwde betrokkenheid") staat op de Task of in `entity.detail` — niet in `entity.what`, dat een `Reference` is.

De `destroy`-AuditEvent overleeft de verwijdering als centraal NEN 7513-record en draagt de `kt2-delete-flow`-marker — deelnemende apps mogen 'm (en de overige delete-`AuditEvent`s) **lezen/subscriben** voor de bevestiging en de flow. Omdat `entity.lifecycle` geen R4-zoekparameter heeft, krijgt het erase-event een **zoekbare `subtype`** (`https://koppeltaal.nl/fhir/CodeSystem/kt2-audit-event#patient-erased`); daarop abonneert een app:

```json
{
  "resourceType": "Subscription",
  "status": "requested",
  "reason": "Bevestiging definitieve verwijdering",
  "criteria": "AuditEvent?subtype=https://koppeltaal.nl/fhir/CodeSystem/kt2-audit-event|patient-erased&_security=https://koppeltaal.nl/fhir/CodeSystem/security-label|kt2-delete-flow",
  "channel": { "type": "rest-hook", "endpoint": "https://module.example.com/notifications/erased" }
}
```

De `destroy`-AuditEvent is daarmee de **gezaghebbende** bevestiging; een `GET` op de eigen Task (`→ 404`) is fallback, en `GET Patient/{id}` → 404 alleen bruikbaar als de app de Patient eerder mocht lezen.

#### Activiteitscheck (selectie en hercontrole)

De queries hieronder leveren de **initiële** `last-patient-engagement` (de selectie uit het Betrokkenheidsmodel hierboven). Vlak vóór de verwijdering draaien ze opnieuw, nu alleen om **hernieuwde betrokkenheid tijdens de grace period** te detecteren: zijn er nieuwe geslaagde auth-events, dan gaat de Task → `cancelled` (een `amend`-AuditEvent) en herstart de 2-jaarstermijn. De legacy-datum/Task-check wordt bij die hercontrole **niet** herhaald (bevroren bij aankondiging).

```mermaid
flowchart TD
    DP["Delete-pending Patient —<br/>grace period verlopen"] --> Q{"Geslaagd auth-event<br/>tijdens de grace period?"}
    Q -->|"Ja — hernieuwde betrokkenheid"| REACT["annuleer delete-pending<br/>(Task → cancelled)"]
    Q -->|"Nee"| DEL["definitieve verwijdering<br/>(interne erase)"]

    classDef del fill:#fde2e2,stroke:#c0392b,color:#000;
    classDef keep fill:#e2f7e2,stroke:#27ae60,color:#000;
    class DEL del;
    class REACT keep;
```

Conceptuele searches per kandidaat-Patient (chained naar `RelatedPerson.patient` neemt gekoppelde RelatedPersons mee; de aankondigings-Task telt niet mee):

```
# T_auth — meest recente geslaagde auth-event (outcome=0); subtype 110122,110126 = OR (codes = DICOM DCM; in productie fully-qualified system|code)
GET /AuditEvent?entity=Patient/{id}&type=110114&subtype=110122,110126&outcome=0&_sort=-date&_count=1
GET /AuditEvent?entity:RelatedPerson.patient=Patient/{id}&type=110114&subtype=110122,110126&outcome=0&_sort=-date&_count=1

# Legacy-schakelaar — aanmaakmoment (create-AuditEvent)
GET /AuditEvent?entity=Patient/{id}&subtype=create&action=C&_sort=date&_count=1

# T_legacy (alleen legacy; delete-pending uitgesloten via :not)
GET /Task?patient=Patient/{id}&code:not=delete-pending&_sort=-_lastUpdated&_count=1
```

#### Definitieve verwijdering

De definitieve verwijdering is een **interne server-stap** — alleen de Koppeltaalvoorziening voert 'm uit, na de [activiteitscheck](#activiteitscheck-selectie-en-hercontrole). De erase-semantiek is **server-agnostisch**; *hoe* een server het uitvoert (HAPI `$expunge`, IRIS-eigen mechanisme) is implementatie-detail (FHIR R4 kent geen Patient-`$purge`).

- **Echte erase, geen tombstone.** Dit is een *harde* verwijdering en **geen reguliere FHIR `DELETE`** (die behoudt de history; een latere `read` geeft dan `410 Gone`). De erase wist alle versies, waardoor de id daarna **onbekend** is: een latere `GET` geeft **404** en een `vread` is onmogelijk — anders zou je via de history alsnog PII teruglezen. Bevestiging verloopt via de **gezaghebbende** `destroy`-AuditEvent of een `GET` → 404, zoals beschreven onder [AuditEvents](#auditevents-bij-statusovergangen).
- **Precondities**: geen Task op `on-hold`; grace verstreken óf alle relevante Tasks `accepted`; geen hernieuwde betrokkenheid. Een **lock/freeze-window** tussen de check en de verwijdering voorkomt een race.
- **Scope**: het Patient Compartment, **met `AuditEvent` uitgesloten** — die overleeft als centraal record en mag de verwijderde `Patient/{id}` blijven refereren (referentiële integriteit op dat punt uitgezonderd). De Tasks van deze Patient (`Task` valt niet in het compartiment) worden **apart** mee-verwijderd: de `delete-pending`-Tasks én de historische `cancelled`-Tasks (die verwijzen nu naar een gewiste Patient). Tijdens een lopende cyclus blijft een `cancelled`-Task juist behouden (onderscheidt reactivering van een uitgevoerde verwijdering). Omvat o.a. Patient, RelatedPerson, CareTeam.
- **cascade** vastgezet door policy; de stap is **idempotent** — een herhaling ná een voltooide erase leunt op de overlevende `destroy`-AuditEvent (de instance bestaat dan niet meer), met gedefinieerd failure/retry-gedrag.

#### Rechten van betrokkenen & contractbeëindiging

Zolang data aanwezig is, faciliteert de Koppeltaalvoorziening inzage (AVG art. 15) zonder de termijn te herstarten (inzage is geen wijziging); in de praktijk via het EPD. Het **recht om vergeten te worden** (art. 17) is een aparte procedure met eigen toetsing en valt buiten deze pagina. Bij **contractbeëindiging** verwijdert of retourneert de Koppeltaalvoorziening de PII aan de verwerkingsverantwoordelijke en legt dat vast via AuditEvents — de interne erase kan hiervoor worden ingezet.

### Overwogen alternatieven

Afgewezen of als variant genoteerd: **operation-/webhook-model ("hide-fully")** — de Task verstoppen (search-narrowing) en app-interactie via custom operations + een custom notificatie-payload; afgewezen als te ver van FHIR voor wat het oplost, en het exposed-Task-model (deze pagina) houdt de CRUD-matrix intact en is FHIR-native. **`meta.tag`-lifecycle op de Patient** (geen per-app status; muteert de Patient; cross-tenant schrijven). **FHIR soft delete** (geen revert bij cascading delete, geen DELETE-notificaties in R4, onzekere server-ondersteuning). **Geen notificatie** (eenvoudigst, maar geen veiligstellen/bezwaar). **Two-phase commit** (maximale coördinatie, maar blokkerende apps). **`meta.extension last-patient-engagement`** als state (afgewezen t.g.v. de querybenadering — geen tweede bron van waarheid).

### Discussiepunten

1. **Domein-transparantie vs. footprint (privacy).** Gekozen: de opschoon-flow is **domein-breed leesbaar** (Tasks + delete-AuditEvents) — elke deelnemer ziet welke patiënten op verwijdering staan en de overgangen (pseudonieme UUID's, coded, geen demografie/vrije tekst, binnen één DPA-domein). AVG art. 19 wijst richting **footprint-based** versmalling als mogelijke v2. Bevestigen met privacy.
2. **`T_legacy` conservatief.** Telt any-actor `Task.meta.lastUpdated` (incl. Practitioner → over-retentie). Bewust; bevestigen. Ook: `meta.lastUpdated` is optioneel, en een legacy-patiënt die alleen via launches actief was kan onder-beschermd zijn (vangnet: noodrem).
3. **Subtype `110126`.** FHIR labelt dit "Node Authentication", niet user-login. Handhaven met eigen display, of passender subtype? Nog géén harde SHALL.
4. **Accept-lifecycle-code.** Besloten: "groen licht" = app zet `accepted` (FHIR: "afgesproken, niet gestart"), server zet daarna `completed` — geen of/of. Open: de `entity.lifecycle`-code voor de accept-overgang (`amend` als status-amendement, of `verify` als attestatie). Bevestigen.
5. **`kt2-delete-flow`-marker formeel vastleggen.** De marker en haar interpretatie als **additieve grant** (zie [Toegang buiten de matrix](#toegang-buiten-de-matrix-metasecurity)) normatief opnemen in de autorisatiepagina's: één server-owned `meta.security`-marker, lezen domein-breed, schrijven owner-scoped op de Task (status-overgang als aparte workflow-regel). Te bevestigen: de exacte code/het CodeSystem; dat AuditEvent-read-only **KT2-beleid** is (geen FHIR-norm); en de borging (server-owned marker; DPA-domein uit de Device-registratie i.p.v. de gewiste Patient; onafhankelijke autorisatie van `_include`/contained/history/export). Verworpen als *méér*-standaard alternatief: een custom `CompartmentDefinition` (R4: compartimenten alleen door HL7 International te definiëren; het Device-compartment dekt Task/Subscription niet) en een `$`-operation (= het al afgewezen hide-fully-model). FHIR `Consent` kán exacte instances benoemen maar blijft policy-data die nog steeds een PDP vereist; server-validatie van de Task-overgangen is normatief.
6. **Erase-event-subtype bevestigen.** Gekozen: een zoekbare `AuditEvent.subtype` (`kt2-audit-event#patient-erased`) als discriminator voor het erase-event (omdat `entity.lifecycle` geen R4-zoekparameter heeft). De exacte code/het CodeSystem bevestigen.
7. **Deelname/opt-in & Subscription-provisioning.** Hoe wordt een app deelnemer — automatisch elke app in het domein, of een expliciete opt-in (bv. via domeinbeheer)? En provisioneert de Koppeltaalvoorziening de notificatie-`Subscription`(s) vóór, of maakt elke app 'm zelf (R4 staat client-Subscriptions toe)? Open; te beslissen met domeinbeheer/architectuur.

### Referenties

- [FHIR R4 Task](https://hl7.org/fhir/R4/task.html) / [Subscription](https://hl7.org/fhir/R4/subscription.html) / [Patient Compartment](https://www.hl7.org/fhir/compartmentdefinition-patient.html)
- [ISO 21089 lifecycle](https://terminology.hl7.org/7.1.0/en/CodeSystem-iso-21089-lifecycle.html) / [Security Labels](https://hl7.org/fhir/R4/security-labels.html) / [FHIR R4 Security](https://hl7.org/fhir/R4/security.html) / [Consent](https://hl7.org/fhir/R4/consent.html) / [CompartmentDefinition](https://hl7.org/fhir/R4/compartmentdefinition.html)
- [SMART Backend Services](https://hl7.org/fhir/smart-app-launch/backend-services.html) / [SMART scopes](https://hl7.org/fhir/smart-app-launch/scopes-and-launch-context.html)
- [AVG](https://eur-lex.europa.eu/eli/reg/2016/679/oj) (art. 5, 15, 17, 19) / [WGBO](https://wetten.overheid.nl/BWBR0005290) / [NEN 7513](https://www.nen.nl/nen-7513-2018-nl-247904)
