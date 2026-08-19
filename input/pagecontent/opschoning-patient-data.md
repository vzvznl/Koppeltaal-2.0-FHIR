### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.1.0 | 2026-06-08 | Initiële versie |
| 0.1.1 | 2026-06-10 | Veldmapping (`action`, `agent.who`, `entity.what`, `outcome`) per lifecycle-event toegevoegd onder "AuditEvents bij statusovergangen" |
| 0.1.2 | 2026-06-15 | `T_authorize` en `T_introspect_hti` samengevoegd tot `T_auth`; formule vereenvoudigd tot `max(T_auth, T_task_owner)`; activiteitscheck filtert op `entity` |
| 0.1.3 | 2026-06-15 | Status-lifecycle-diagram verwijderd; rationale toegevoegd waarom `KT2_DeletePendingTask` een apart profiel is |
| 0.1.4 | 2026-06-17 | `T_auth` verbreed naar `subtype=110122,110126` |
| 0.2.0 | 2026-06-18 | **Herontwerp (besluitvormingsdocument; nog niet released).** Betrokkenheidsmodel = `T_auth` + legacy-fallback; grace 30 dagen. **FHIR-native Task-workflow**: per-app delete-pending `Task` die apps met gewone interacties lezen en beantwoorden (`Task.status`-write); server bewaakt de transities. Eén server-owned **`meta.security`-marker** (`kt2-delete-flow`) leest de Koppeltaalvoorziening als **additieve grant** bovenop de TOP-KT-005-matrix (geen matrixwijziging, geen aparte operation): lezen domein-breed, schrijven owner-scoped op de Task. Notificatie + bevestiging via standaard `Subscription` (Task / `destroy`-AuditEvent) of `GET` → 404. Interne harde erase (404, geen tombstone). Domein-transparant; open keuzes onderaan. |
| 0.2.1 | 2026-07-14 | **Herontwerp besproken.** Het 0.2.0-herontwerp is besproken in de architectuurbespreking; document omgewerkt van besluitvormingsdocument naar uitgewerkt ontwerp. Besluitvorming is nog niet afgerond; de openstaande uitwerkings- en beslispunten staan onder [Discussiepunten](#discussiepunten) |
| 0.2.2 | 2026-07-28 | `kt2-delete-flow`-marker geconcretiseerd: CodeSystem `koppeltaal-security-label` (`http://vzvz.nl/fhir/CodeSystem/koppeltaal-security-label`) opgenomen in de IG, evenals het `koppeltaal-delete-hold-reason`-CodeSystem voor de noodrem-reden (required binding, verplichte display); URL-verwijzingen op deze pagina bijgewerkt |
| 0.2.3 | 2026-07-30 | Verduidelijkingen n.a.v. vragen uit de Technical Community: nieuwe subsectie [Na de verwijdering](#na-de-verwijdering-her-onboarding-en-launch) over her-onboarding na verwijdering (nieuwe `Patient.id`; herkenning via de business-identifier `Patient.identifier`) en het verwachte launch-gedrag na verwijdering (launch-ingangen opruimen; fallback via de reguliere launch-foutafhandeling, TOP-KT-012c) |
| 0.2.4 | 2026-08-12 | Concept **contractbeëindiging** verwijderd (review-commentaar): beëindiging van de overeenkomst tussen zorgaanbieder en Koppeltaalvoorziening leidt tot een domein-brede verwijdering of teruglevering binnen de contractuele termijn — een contractuele afwikkeling van het hele domein, geen patiëntgewijze opschoning; buiten de scope van deze pagina geplaatst. Overzichtsdiagram aangepast; sectie "Rechten van betrokkenen & contractbeëindiging" hernoemd naar "Rechten van betrokkenen". Daarnaast discussiepunt 1 aangescherpt: de variant **owner-scoped lezen van de delete-pending Tasks** (alleen de eigen Task; de geaggregeerde AuditEvents blijven domein-breed) expliciet opgenomen als te bevestigen versmallingsoptie naast footprint-versmalling |
| 0.2.5 | 2026-08-17 | AVG-claim over AuditEvents **gecorrigeerd** (review-commentaar): search-events leggen per Topic 11 de query vast (`entity.query`) inclusief eventuele business-identifiers (bijv. `Patient?identifier=…`) plus referenties naar de gevonden resources — access-log-AuditEvents blijven daarmee ook ná de erase persoonsgegevens. Grondslag voor bewaring is de wettelijke logging-verplichting (NEN 7513; AVG art. 17 lid 3 sub b), niet pseudonimisering; de pseudonimiteits-claim geldt alleen nog voor de delete-flow-AuditEvents. Uitgangspunt "Logging en PII gescheiden" en Termijnen-tabel aangepast; nieuw discussiepunt 8 over mitigatie (hashen/redigeren van identificerende parameterwaarden) aan de Topic 11-kant |
| 0.2.6 | 2026-08-18 | Status gecorrigeerd: het herontwerp is **ter besluitvorming** — de eerdere vermelding (0.2.1) dat de architectuurbespreking het ontwerp had vastgesteld was voorbarig; changelog-rij 0.2.1 en de status-callout hierop aangepast |
| 0.2.7 | 2026-08-18 | Discussiepunten opgeschoond (review-commentaar): subtype `110126` editorieel afgedaan (kanttekening bij `T_auth`); de twee als "besloten" gemarkeerde punten (geaggregeerde AuditEvents; ISO 21089-discriminator) uit de genummerde lijst gehaald — de inhoud staat in de tekst en in een slotalinea; de formele marker-vastlegging als actiepunt belegd in de Topic 05-update-instructies (verworpen alternatieven verplaatst naar [Overwogen alternatieven](#overwogen-alternatieven)); de search-query-mitigatie overgedragen naar de Topic 11-update-instructies. Resterende beslispunten: domein-transparantie/footprint, betrokkenheidsdefinitie, deelname & Subscription-provisioning |
| 0.2.8 | 2026-08-19 | Veldtabel aangevuld met `authoredOn` (aankondigingsmoment) en `status` (de vijf statussen waaraan het profiel required bindt); `authoredOn` toegevoegd aan de server-owned velden die een app niet mag muteren; het `PUT`-voorbeeld van de noodrem compleet gemaakt — het heette "de volledige Task" maar miste de profielverplichte `authoredOn`, `requester` en `restriction.period.end`, plus `meta.profile` als expliciete profielclaim |

---

### Opschoning Patient-data

> **Status: ter besluitvorming.** Het herontwerp is besproken in de architectuurbespreking; besluitvorming is nog niet afgerond. Profiel-/FSH-wijzigingen en interactiediagrammen volgen; de openstaande uitwerkings- en beslispunten staan onder [Discussiepunten](#discussiepunten).

De Koppeltaalvoorziening slaat patiëntgerelateerde FHIR resources op die na verloop van tijd verwijderd moeten worden, conform wettelijke bewaartermijnen (AVG, WGBO, NEN 7510, NEN 7513).

<div style="clear: both; margin: 1em 0;">
{% include opschoning-patient-data-overzicht.svg %}
</div>

### Uitgangspunten

**Verwijderen op patiëntniveau.** FHIR resources zijn referentieel verbonden; individueel verwijderen geeft integriteitsproblemen. Verwijdering vindt daarom op patiëntniveau plaats — alle aan de patiënt gerelateerde resources als geheel. RelatedPerson valt binnen de scope (altijd aan één patiënt gekoppeld); Practitioner niet (kan bij meerdere patiënten betrokken zijn).

**Logging en PII gescheiden.** Persoonsgegevens (PII): max. 2 jaar. AuditEvents (NEN 7513): min. 5 jaar. AuditEvents zijn immutable en worden bij de verwijdering expliciet behouden, maar gelden **niet als pseudoniem of geanonimiseerd** (review-commentaar, aug 2026). De geaggregeerde **delete-flow-AuditEvents** (zie [AuditEvents](#auditevents-bij-statusovergangen)) bevatten uitsluitend coded data en technische referenties (zoals de `Patient`-UUID) — die zijn wél pseudoniem. Voor het reguliere access-log ligt dat anders: **search-events** leggen per Topic 11 (Logging en tracing) de query vast (`entity.query`, base64 — een omkeerbare encoding, geen pseudonimisering) én referenties naar de gevonden resources (`entity.what`). Een zoekopdracht als `Patient?identifier=<patiëntnummer>` zet daarmee een direct identificerende parameterwaarde in het log — en zulke queries zijn ingebakken in dit ontwerp: her-onboarding verloopt via de business-identifier (zie [Na de verwijdering](#na-de-verwijdering-her-onboarding-en-launch)). Ná de erase blijven die AuditEvents dus **persoonsgegevens**, binnen de voorziening herleidbaar zonder externe bron. De bewaring steunt daarom niet op anonimiteit maar op de **wettelijke logging-verplichting** (NEN 7513); het recht op wissing geldt niet voor zover de verwerking nodig is voor het nakomen van die plicht ([AVG art. 17 lid 3 sub b](https://eur-lex.europa.eu/eli/reg/2016/679/oj)), met strikte toegangsbeperking op het audit-log als waarborg.

De Koppeltaalvoorziening initieert het proces zodra de 2-jaarstermijn (vanaf de laatste betrokkenheid) is verstreken. Het ECD heeft op grond van de [WGBO](https://wetten.overheid.nl/BWBR0005290) een eigen termijn (max. 20 jaar) en is zelf verantwoordelijk voor het tijdig veiligstellen van data.

#### Betrokkenheidsmodel: `last-patient-engagement`

Het startmoment voor de bewaartermijn is de **laatste betrokkenheid van de patiënt**. Een Patient is opschoonbaar wanneer `last-patient-engagement` > 2 jaar geleden is. De waarde wordt **niet als state opgeslagen** maar telkens **afgeleid uit bestaande events** — geen state, geen backfill (zie ook [Activiteitscheck](#activiteitscheck-selectie-en-hercontrole)).

**Primair signaal — `T_auth`.** Sinds de **Topic 11-uitbreiding** legt Koppeltaal per launch/authenticatie een geattribueerd `User Authentication`-AuditEvent vast, mét de geauthenticeerde gebruiker op `entity.what` (zie [Wijzigingen TOPKT011](memo-wijzigingen-topic11.html)). `T_auth` = de meest recente **geslaagde** (`outcome = 0`) daarvan (`DCM#110114` / subtype `DCM#110122` of `DCM#110126`) met de Patient of een gekoppelde RelatedPerson op `entity.what`. Een niet-geslaagde login (`outcome != 0`) telt niet mee. De betrokkenheid hangt aan de **geverifieerd ondertekende** launch/authenticatie (`introspect` of `authorize`), niet aan de externe IdP-stap: een `authorize` met `outcome = 0` telt mee, **ook als de daaropvolgende `idp login` mislukt** (`outcome = 8`) — dat IdP-event valt zelf weg via de `outcome = 0`-filter, terwijl de `introspect`/`authorize` de activiteit alsnog markeert. Die `authorize` níet meetellen bij een mislukte IdP-login zou semantisch zuiverder zijn, maar vergt het correleren van events binnen één sessie; die complexiteit nemen we bewust niet. Alle `DCM#110122`/`110126` met `outcome = 0` mogen daarom meetellen, zonder de `idp`-varianten apart uit te sluiten. Practitioner-logins vallen vanzelf buiten `T_auth` (ze staan niet als Patient/RelatedPerson op `entity.what`). *Kanttekening subtype `110126`:* FHIR labelt dit subtype "Node Authentication", geen user-login; KT2 handhaaft het subtype met een eigen display — er is geen passender standaard-subtype en dit is geen harde SHALL.

**Selectiecriteria.** Een Patiënt is opschoonbaar (kandidaat voor delete-pending) wanneer aan **álle** voorwaarden is voldaan:

1. de Patiënt **bestaat minimaal 2 jaar** (aanmaakdatum ≥ 2 jaar geleden — de ondergrens: jonger kan nooit);
2. er is **geen geslaagd `T_auth`-event in de afgelopen 2 jaar** (Patiënt of een gekoppelde RelatedPerson op `entity.what`, `outcome = 0`);
3. **én — zolang de Topic 11-uitrol (`C`) nog geen 2 jaar live is** — geen `Task` met deze Patiënt als `Task.for` met een `meta.lastUpdated` in de afgelopen 2 jaar, **de delete-pending Task zelf uitgezonderd** (de tijdelijke `T_legacy`-brug).

De terugkerende selectie slaat daarnaast Patiënten over die **al een actieve delete-pending Task** hebben (idempotentie — anders wordt elke run opnieuw aangekondigd).

**Voorwaarde 3 is tijdelijk.** Patiënten van vóór de uitrol missen `T_auth`-attributie voor hun oude activiteit; de Task-check overbrugt dat domein-breed. Vanaf `C + 2 jaar` ligt het 2-jaarsvenster volledig ná de uitrol — wie nog actief was heeft per definitie een `T_auth`-event — en vervalt de brug; `T_auth` plus de leeftijdsondergrens volstaan dan. Het is dus een **tijdelijke switch**, geen per-patiënt-kenmerk: tot `C + 2 jaar` is elke kandidaat per definitie van vóór de uitrol.

> Dit definieert betrokkenheid als **authenticatie van de Patiënt/RelatedPerson**. Ná de overgang wordt een Patiënt die alléén via Practitioner-activiteit "in zorg" is maar 2 jaar niet inlogde, opschoonbaar — maar het [verwijderpad](#verwijderpad-graceful-of-fast-track) bepaalt het vangnet: met een recente `Task` loopt 'ie via de graceful flow (noodrem bereikbaar), zonder recente `Task` via fast-track.

#### Verwijderpad: graceful of fast-track

Vóór `C + 2 jaar` (het overgangsvenster) doorloopt **elke** kandidaat de graceful flow — een per-app delete-pending `Task`, de grace period en de noodrem (zie [Oplossingsrichting](#oplossingsrichting)). Tijdens de overgang is de `T_auth`-attributie nog onvolledig; dit is bewust conservatief — er wordt nooit direct verwijderd.

Vanaf `C + 2 jaar` is de selectie volledig op `T_auth` gebaseerd en bepaalt een **fallback op `Task.meta.lastUpdated`** (dezelfde Task-afleiding als voorwaarde 3, de delete-pending Task uitgezonderd) het pad:

| `Task.meta.lastUpdated` (Patiënt, non-delete-pending) | Pad |
| --- | --- |
| **≤ 2 jaar** | **Graceful** — delete-pending Task(s), grace period, noodrem mogelijk. Vangt een nog lopende behandeling die alleen via Practitioner-activiteit zichtbaar is. |
| **geen / > 2 jaar** | **Fast-track** — directe interne erase, géén aankondiging/grace/noodrem; alleen het `destroy`-AuditEvent als bewijs. |

De `Task` telt hier **niet** mee voor de selectie (een Patiënt zonder login blijft opschoonbaar), alléén voor de **routekeuze**. Beide paden eindigen in dezelfde [definitieve verwijdering](#definitieve-verwijdering), met vlak vóór de erase een laatste auth-hercontrole.

#### Termijnen

Vaste termijnen voor een voorspelbaar kader; **alleen de grace period is per domein aanpasbaar** (omhoog of omlaag, begrensd en geaudit).

| Termijn | Waarde | Toelichting |
| --- | --- | --- |
| Grace period | **30 dagen** (default; per domein aanpasbaar) | Window tussen aankondiging (`requested`) en geplande verwijdering; vastgelegd in `restriction.period.end` (server-beheerd; schuift mee bij een grace-reset) |
| Bewaartermijn PII | 2 jaar | Vanaf `last-patient-engagement` (KT2-uitgangspunt) |
| Bewaartermijn AuditEvents | 5 jaar | Minimale logging-bewaartermijn (bevestigen tegen NEN 7513); kunnen identificerende gegevens bevatten (search-queries) — bewaring o.g.v. de wettelijke logging-plicht, zie [Uitgangspunten](#uitgangspunten) |
| Noodrem-time-out (`on-hold`) | oneindig | Op de grace-deadline worden alle holds gewist en herstart de grace period; om te blijven blokkeren trekt een app telkens opnieuw — met een reden — aan de handrem |

De grace period geldt **niet** voor het [fast-track-pad](#verwijderpad-graceful-of-fast-track) — daar wordt direct verwijderd.

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

De opschoon-resources — de `KT2_DeletePendingTask` en de delete-`AuditEvent`s — zijn **server-owned** en vallen buiten het reguliere [TOP-KT-005](autorisaties.html)-CRUD-vlak. Eén **`meta.security`-marker** regelt de toegang: `http://vzvz.nl/fhir/CodeSystem/koppeltaal-security-label#kt2-delete-flow`. De marker is **doel-specifiek** (géén "overschrijf de hele matrix"-label — dat zou te breed granten) en **server-owned**: alleen de Koppeltaalvoorziening zet 'm, door apps aangeleverde labels worden geweigerd. FHIR laat de betekenis van een security-label aan het lokale toegangsbeleid (i.t.t. `meta.tag`, dat voor workflow is); de Koppeltaalvoorziening interpreteert deze marker als een **additieve leesgrant** ([Security Labels](https://hl7.org/fhir/R4/security-labels.html); access-control is per [FHIR Security](https://hl7.org/fhir/R4/security.html) bewust extern beleid). De formele vastlegging van de marker in [TOP-KT-005](autorisaties.html) is als actiepunt belegd in de update-instructies voor Topic 05 (`topics/updates/TOP-KT-005-update-instructies.md`).

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

Het proces wordt aangekondigd via één FHIR `Task` per (Patient × deelnemende applicatie); de Patient zelf wordt niet aangeraakt. Een Task-per-applicatie geeft elke app een eigen, onafhankelijk **workflow**-statusobject (haar eigen handrem en groen licht). De **AuditEvents** zijn daarentegen **geaggregeerd** op procesniveau — de Voorziening logt de geaggregeerde status (zie [AuditEvents](#auditevents-bij-statusovergangen)), niet elke losse Task-write. De Task is **server-owned maar door deelnemende apps leesbaar** (domein-breed, zie [Toegang buiten de matrix](#toegang-buiten-de-matrix-metasecurity)): apps lezen 'm met een gewone `GET` en de **eigen** app reageert met een `Task.status`-write (zie [Status-lifecycle](#status-lifecycle--server-validatie)).

<div style="clear: both; margin: 1em 0;">
{% include opschoning-patient-data-interactie.svg %}
</div>

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
| `authoredOn` | aankondigingsmoment (**1..1, afgedwongen**) | Server-gezet; hier start de grace period. De deadline ligt altijd later |
| `restriction.period.end` | grace-deadline (**1..1, afgedwongen**) | Geplande verwijdering; server-beheerd — bij een grace-reset zet de server een nieuwe deadline (apps muteren 'm nooit) |
| `statusReason` | reden bij `on-hold` (**coded, geen demografie**) | De noodrem-reden; gezet bij de status-write naar `on-hold`. Verplicht bij `on-hold`, verboden bij elke andere status |
| `status` | `requested`, `on-hold`, `accepted`, `cancelled`, `completed` | Required gebonden; de overige R4 task-statussen komen in deze flow niet voor |
| `intent` | `order` | Een vaststaande verwijdering wordt aangekondigd |

**Apart profiel (`Parent: Task`), naast `KT2_Task`.** `KT2_Task` is onverenigbaar (bindt `owner` aan mens-actoren, verbiedt `restriction`/`statusReason`); de aankondigings-Task heeft die juist nodig. Een eigen profiel borgt de vorm als validatiecontract — het zet dezelfde elementen dicht als `KT2_Task`, op `statusReason` en `restriction` na die deze Task juist nodig heeft, plus `description` — houdt `owner = Device` dragend (valt buiten de retentieklok), en blijft losgekoppeld van het [KoppelMij-openstellen](memo-koppelmij-scope.html) van `KT2_Task`. (Afleiden van een geopend `KT2_Task` kan heroverwogen worden zodra dat traject `KT2_Task` compatibel maakt.)

#### Status-lifecycle & server-validatie

De app reageert door **`Task.status` te schrijven** (`PUT` met `If-Match`) op haar eigen Task — geen custom operation; KT2 ondersteunt geen `PATCH`. De Koppeltaalvoorziening **valideert** elke overgang.

<div style="clear: both; margin: 1em 0;">
{% include opschoning-patient-data-statusflow.svg %}
</div>

| `Task.status` | Hoe gezet | Betekenis |
| --- | --- | --- |
| `requested` | Koppeltaalvoorziening | Aangekondigd; grace period loopt |
| `on-hold` | app · status-write | Tijdelijke noodrem (coded `statusReason`); vervalt bij de grace-reset of zodra de app `accepted` zet |
| `accepted` | app · status-write | Groen licht: data veiliggesteld/akkoord; telt voor vervroegde voltooiing |
| `cancelled` | Koppeltaalvoorziening | Afgebroken wegens hernieuwde betrokkenheid; **Task blijft behouden** zodat een latere `GET` 'm onderscheidt van een uitgevoerde verwijdering |
| `completed` | Koppeltaalvoorziening | Verwijderd; de Task wordt **mét de Patiënt** opgeruimd |

**Server-validatie (normatief).** De Koppeltaalvoorziening **MOET** de overgangen valideren (optimistic concurrency via `If-Match`/ETag): een app mag op haar **eigen** Task (`owner` = haar Device) alleen `status` → `on-hold`/`accepted` zetten (+ `statusReason` bij `on-hold`), en **niet** `owner`/`for`/`requester`/`code`/`authoredOn`/`restriction.period.end` of de server-owned `kt2-delete-flow`-marker muteren — een `PUT` die de marker dropt wordt geweigerd. Bij het verlaten van `on-hold` (door de app naar `accepted`, of door de server bij de grace-reset) **wist de server `statusReason`**. De hold-reden is per-applicatie en leeft **op de Task**: inzichtelijk zolang er nog geen verwijdering is; ná de `$purge` verdwijnt hij mee. De geaggregeerde `hold`-AuditEvent draagt geen per-app reden. `cancelled`/`completed` zijn **server-only**.

Noodrem trekken met een coded (non-PII) reden — `PUT Task/{id}` met `If-Match: W/"{etag}"`. De app stuurt de **volledige** Task terug met `status` → `on-hold` en een gezette `statusReason`; de server-owned velden (`code`/`for`/`owner`/`requester`/`authoredOn`/`restriction`/`meta.security`) gaan ongewijzigd mee — de server weigert wijziging daarvan. Alle profielverplichte velden staan hieronder — een `PUT` die er één weglaat wordt afgekeurd. `meta.profile` is niet verplicht maar wordt getoond als expliciete profielclaim, en `id` is vereist door de REST-update zelf:

```json
{
  "resourceType": "Task",
  "id": "{id}",
  "meta": {
    "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2DeletePendingTask"],
    "security": [{ "system": "http://vzvz.nl/fhir/CodeSystem/koppeltaal-security-label", "code": "kt2-delete-flow" }]
  },
  "status": "on-hold",
  "statusReason": {
    "coding": [{ "system": "http://vzvz.nl/fhir/CodeSystem/koppeltaal-delete-hold-reason", "code": "data-export-pending", "display": "Export naar bronsysteem loopt nog" }]
  },
  "intent": "order",
  "code": { "coding": [{ "system": "http://vzvz.nl/fhir/CodeSystem/koppeltaal-task-code", "code": "delete-pending" }] },
  "authoredOn": "2026-07-01T06:00:00+00:00",
  "for": { "reference": "Patient/{patientId}" },
  "requester": { "reference": "Device/{koppeltaalvoorzieningDevice}" },
  "owner": { "reference": "Device/{appDevice}" },
  "restriction": { "period": { "end": "2026-07-31T06:00:00+00:00" } }
}
```

De verwijdering mag pas wanneer **geen enkele** Task voor deze Patient op `on-hold` staat, **én** ofwel de grace-deadline is verstreken, **ofwel** álle relevante Tasks staan op `accepted` (vervroegde voltooiing). Staat er bij het verstrijken van de grace-deadline nog een hold, dan worden **alle holds gewist en herstart de grace period** — een app moet dan opnieuw (met reden) aan de handrem trekken (zie [Termijnen](#termijnen)).

#### AuditEvents bij statusovergangen

De AuditEvents leggen de **geaggregeerde status van het opschoon-proces per Patiënt** vast — niet de losse `Task.status`-write van een individuele applicatie. De **Koppeltaalvoorziening** maakt ze en logt **één event per aggregaat-overgang**. De codes zijn **standaard ISO 21089 record-lifecycle-codes** op `AuditEvent.type` (`http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle`) — een R4-zoekparameter (`AuditEvent?type=…`), dát is waarop apps de events vinden en subscriben; de flow als geheel is daarnaast vindbaar via het `kt2-delete-flow`-`_security`-label. Een **eigen subtype/CodeSystem is niet nodig**: de ISO 21089-code op `type` is al onderscheidend én doorzoekbaar. Deze records worden bij de verwijdering expliciet behouden.

Een event wordt **alleen** vastgelegd wanneer de **geaggregeerde** toestand wijzigt. Trekt een tweede applicatie ook de handrem, dan gebeurt er niets — de aggregaat-status stond al op `hold`. Laat één van meerdere applicaties los, dan blijft het `hold`; pas wanneer de **laatste** handrem eraf gaat — **én niet meteen álle Tasks op `accepted` staan** — volgt een `unhold`: de blokkade is opgeheven maar het proces loopt door naar de grace-deadline (een echte tussenstand). Betekent diezelfde laatste release dat álle Tasks nú `accepted` zijn, dan is de vervroegde voltooiing bereikt en volgt **direct `destroy`, géén `unhold`** — consistent met het feit dat een kale `accepted` ook geen eigen event krijgt. Een `accepted` zonder voorafgaande hold verschuift de aggregaat-status niet en levert dus **geen** event op. De losse `Task.status`-writes van applicaties worden via de reguliere create/update-AuditEvent gelogd, niet als lifecycle-event.

| Aggregaat-overgang (Patiënt) | ISO 21089 `type` | `action` |
| --- | --- | --- |
| Aangekondigd — Task(s) aangemaakt (`requested`) | `archive` | `C` |
| Geblokkeerd — eerste handrem (`on-hold`) | `hold` | `U` |
| Gedeblokkeerd — laatste handrem eraf (`accepted`) | `unhold` | `U` |
| Grace-reset — holds gewist, grace herstart (`→ requested`) | `archive` | `U` |
| Afgebroken — hernieuwde betrokkenheid (`cancelled`) | `reactivate` | `U` |
| Verwijderd — `$purge` (`completed`) | `destroy` | `D` |

Aankondiging en grace-reset delen `archive` — onderscheidbaar via `action` (`C` = eerste aankondiging, `U` = grace-reset). De **grace-reset** is server-gedreven (de Voorziening wist de holds en herstart de grace: `hold → requested`); de **`unhold`** is app-gedreven (de applicaties hebben hun handremmen losgelaten). Enkele velden zijn voor **álle** events gelijk en staan daarom niet in de tabel: `agent.who` = de **Koppeltaalvoorziening** (`Device`), `agent.type` = `DCM#110153` "Source Role ID" (`requestor = true`), `outcome` = `0`, en `entity.what` = **altijd de `Patient`** (`entity=Patient/{id}`, niet de Task). De generieke velden (`request-id`/`correlation-id`/`trace-id`, `source.*`, `recorded`) gelden ook; geen demografie. De reden van een hold (`Task.statusReason`) leeft **op de Task** — per applicatie, inzichtelijk zolang de Task bestaat — en staat niet in de geaggregeerde AuditEvent. Bij **fast-track** ([Verwijderpad](#verwijderpad-graceful-of-fast-track)) ontbreken de aankondigings- en tussenevents; alleen het `destroy`-event wordt vastgelegd.

De `destroy`-AuditEvent overleeft de verwijdering als centraal NEN 7513-record en draagt de `kt2-delete-flow`-marker — deelnemende apps mogen 'm (en de overige delete-`AuditEvent`s) **lezen/subscriben** voor de bevestiging en de flow. Het erase-event heeft `type` `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle#destroy`; daarop abonneert een app:

```json
{
  "resourceType": "Subscription",
  "status": "requested",
  "reason": "Bevestiging definitieve verwijdering",
  "criteria": "AuditEvent?type=http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|destroy&_security=http://vzvz.nl/fhir/CodeSystem/koppeltaal-security-label|kt2-delete-flow",
  "channel": { "type": "rest-hook", "endpoint": "https://module.example.com/notifications/erased" }
}
```

De `destroy`-AuditEvent is daarmee de **gezaghebbende** bevestiging; een `GET` op de eigen Task (`→ 404`) is fallback, en `GET Patient/{id}` → 404 alleen bruikbaar als de app de Patient eerder mocht lezen.

#### Activiteitscheck (selectie en hercontrole)

De **criteria** uit het Betrokkenheidsmodel bepalen de initiële selectie. Vlak vóór de verwijdering wordt **alleen de auth-check** opnieuw gedraaid om **hernieuwde betrokkenheid** te detecteren — bij het graceful pad tijdens de grace period, bij fast-track in de freeze-window vlak vóór de erase. Is er een nieuw geslaagd auth-event, dan stopt de verwijdering: bij graceful gaat de Task → `cancelled` (een `reactivate`-AuditEvent op `type`) en herstart de 2-jaarstermijn; bij fast-track wordt simpelweg niet verwijderd. De overige criteria (leeftijd, transitie-brug) liggen vast bij de selectie.

<div style="clear: both; margin: 1em 0;">
{% include opschoning-patient-data-activiteitscheck.svg %}
</div>

> *Niet-normatief — implementatie.* Hóé een voorziening deze criteria evalueert (bijvoorbeeld als één interne query met negatie, of als losse FHIR-searches per kandidaat — waarbij chaining naar `RelatedPerson.patient` de gekoppelde RelatedPersons meeneemt en de delete-pending Task zelf wordt uitgesloten) is vrij; alleen de criteria zijn normatief.

#### Definitieve verwijdering

De definitieve verwijdering is een **interne server-stap** — alleen de Koppeltaalvoorziening voert 'm uit, na de [activiteitscheck](#activiteitscheck-selectie-en-hercontrole). De erase-semantiek is **server-agnostisch**; *hoe* een server het uitvoert (HAPI `$expunge`, IRIS-eigen mechanisme) is implementatie-detail (FHIR R4 kent geen Patient-`$purge`).

- **Echte erase, geen tombstone.** Dit is een *harde* verwijdering en **geen reguliere FHIR `DELETE`** (die behoudt de history; een latere `read` geeft dan `410 Gone`). De erase wist alle versies, waardoor de id daarna **onbekend** is: een latere `GET` geeft **404** en een `vread` is onmogelijk — anders zou je via de history alsnog PII teruglezen. Bevestiging verloopt via de **gezaghebbende** `destroy`-AuditEvent of een `GET` → 404, zoals beschreven onder [AuditEvents](#auditevents-bij-statusovergangen).
- **Precondities** — *graceful pad*: geen Task op `on-hold`; grace verstreken óf alle relevante Tasks `accepted`; geen hernieuwde betrokkenheid. *Fast-track pad* (vanaf `C + 2 jaar`, geen recente `Task` — zie [Verwijderpad](#verwijderpad-graceful-of-fast-track)): geen aankondiging/grace, direct na een laatste auth-hercontrole. Beide paden: een **lock/freeze-window** tussen de check en de verwijdering voorkomt een race.
- **Scope**: het Patient Compartment, **met `AuditEvent` uitgesloten** — die overleeft als centraal record en mag de verwijderde `Patient/{id}` blijven refereren (referentiële integriteit op dat punt uitgezonderd). De Tasks van deze Patient (`Task` valt niet in het compartiment) worden **apart** mee-verwijderd: de `delete-pending`-Tasks én de historische `cancelled`-Tasks (die verwijzen nu naar een gewiste Patient). Tijdens een lopende cyclus blijft een `cancelled`-Task juist behouden (onderscheidt reactivering van een uitgevoerde verwijdering). Omvat o.a. Patient, RelatedPerson, CareTeam.
- **cascade** vastgezet door policy; de stap is **idempotent** — een herhaling ná een voltooide erase leunt op de overlevende `destroy`-AuditEvent (de instance bestaat dan niet meer), met gedefinieerd failure/retry-gedrag.

#### Na de verwijdering: her-onboarding en launch

**Her-onboarding — nieuwe resource, herkenning via de identifier.** Na de harde erase bestaat de technische `Patient.id` niet meer (`GET` → **404**, geen history). Komt de patiënt opnieuw in zorg, dan maakt het EPD een **nieuwe** Patient-resource aan, met een nieuwe `id`/URL — voor het domein is dat een reguliere, nieuwe onboarding. Applicaties mogen dan ook **geen aannames** doen over de stabiliteit van technische Patient-id's over een verwijdering heen. Herkenning van een terugkerende patiënt verloopt via de **business-identifier** (`Patient.identifier`, system + value — bijvoorbeeld het patiëntnummer uit het bronsysteem): een applicatie her-koppelt haar accountrelatie via die identifier aan de nieuwe resource. *Kanttekening:* de stabiliteit van die identifier is gedrag van het bronsysteem/EPD — Koppeltaal garandeert die niet. Keert de patiënt terug **tijdens** een lopend opschoonproces, dan vangt de [activiteitscheck](#activiteitscheck-selectie-en-hercontrole) dat af (Task → `cancelled`, `reactivate`-AuditEvent) en blijft de bestaande resource bestaan; her-onboarding speelt alleen ná een daadwerkelijk uitgevoerde verwijdering.

**Launch-gedrag — ingangen opruimen.** Het EPD/portaal is zelf deelnemer aan de opschoon-flow: het ontvangt een eigen delete-pending Task en kan op de `destroy`-AuditEvent subscriben (zie [AuditEvents](#auditevents-bij-statusovergangen)). De verwachting is dat de lancerende applicatie ná de verwijdering haar **launch-ingangen** voor deze patiënt verwijdert of deactiveert, zodat een launch naar verwijderde data zich in de regel niet voordoet. Gebeurt zo'n launch toch met een verwijderde referentie, dan faalt die via de **reguliere launch-foutafhandeling** (TOP-KT-012c); de presentatie aan de eindgebruiker is de verantwoordelijkheid van de lancerende applicatie.

#### Rechten van betrokkenen

Zolang data aanwezig is, faciliteert de Koppeltaalvoorziening inzage (AVG art. 15) zonder de termijn te herstarten (inzage is geen wijziging); in de praktijk via het EPD. Het **recht om vergeten te worden** (art. 17) is een aparte procedure met eigen toetsing en valt buiten deze pagina. Ook **contractbeëindiging** valt buiten deze pagina: bij beëindiging van de overeenkomst tussen de zorgaanbieder en de Koppeltaalvoorziening is de verwerker verplicht álle persoonsgegevens in het domein binnen de contractuele termijn te verwijderen of terug te leveren — een domein-brede, contractuele afwikkeling die losstaat van de patiëntgewijze opschoning.

### Overwogen alternatieven

Afgewezen of als variant genoteerd: **operation-/webhook-model ("hide-fully")** — de Task verstoppen (search-narrowing) en app-interactie via custom operations + een custom notificatie-payload; afgewezen als te ver van FHIR voor wat het oplost, en het exposed-Task-model (deze pagina) houdt de CRUD-matrix intact en is FHIR-native. **`meta.tag`-lifecycle op de Patient** (geen per-app status; muteert de Patient; cross-tenant schrijven). **FHIR soft delete** (geen revert bij cascading delete, geen DELETE-notificaties in R4, onzekere server-ondersteuning). **Geen notificatie** (eenvoudigst, maar geen veiligstellen/bezwaar). **Two-phase commit** (maximale coördinatie, maar blokkerende apps). **`meta.extension last-patient-engagement`** als state (afgewezen t.g.v. de querybenadering — geen tweede bron van waarheid). **Custom `CompartmentDefinition`, custom operation of FHIR `Consent` als toegangsmechanisme** voor de `kt2-delete-flow`-marker (R4 laat compartimenten alleen door HL7 International definiëren en het Device-compartment dekt Task/Subscription niet; een custom operation is het al afgewezen hide-fully-model; `Consent` kán exacte instances benoemen maar blijft policy-data die een PDP vereist — server-validatie van de Task-overgangen blijft normatief).

### Discussiepunten

De volgende punten staan nog open voor besluitvorming; per punt wordt daarbij vastgelegd welk gremium besluit en of het besluit randvoorwaardelijk is voor ingebruikname:

1. **Domein-transparantie vs. footprint (privacy).** Gekozen: de opschoon-flow is **domein-breed leesbaar** (Tasks + delete-AuditEvents) — elke deelnemer ziet welke patiënten op verwijdering staan en de overgangen (pseudonieme UUID's, coded, zonder demografie, binnen één DPA-domein). Te bevestigen met privacy, met twee versmallingsvarianten op tafel. **(a) Owner-scoped lezen van de Tasks** (review-commentaar, aug 2026): elke app leest alleen haar **eigen** delete-pending Task; de geaggregeerde delete-AuditEvents blijven het domein-brede signaal. Kanttekening: omdat elke deelnemende app al een eigen Task per opschoning krijgt én de delete-AuditEvents domein-breed leesbaar blijven, versmalt dit niet wélke patiënten in de flow zichtbaar zijn, maar alleen de status en de coded hold-reden van *andere* apps — daarmee vervalt wel het inzicht wélke app een verwijdering blokkeert en waarom de grace-deadline opschuift (de geaggregeerde AuditEvent draagt bewust geen per-app reden). **(b) Footprint-based versmalling** (AVG art. 19): de flow alleen zichtbaar voor applicaties die de patiënt daadwerkelijk kennen — als mogelijke v2.
2. **Betrokkenheid = authenticatie (ná de transitie).** De Task-brug telt tot `C + 2 jaar` any-actor `Task.meta.lastUpdated` (incl. Practitioner → tijdelijk conservatief); dáárna geldt alleen `T_auth`. Gevolg: ná de transitie wordt een patiënt die enkel via Practitioner-activiteit "in zorg" is maar 2 jaar niet inlogde, opschoonbaar — het [verwijderpad](#verwijderpad-graceful-of-fast-track) bepaalt dan het vangnet (recente `Task` → graceful/noodrem; geen → fast-track). (`meta.lastUpdated` is bovendien optioneel.) Bevestigen.
3. **Deelname/opt-in & Subscription-provisioning.** Hoe wordt een app deelnemer — automatisch elke app in het domein, of een expliciete opt-in (bv. via domeinbeheer)? En provisioneert de Koppeltaalvoorziening de notificatie-`Subscription`(s) vóór, of maakt elke app 'm zelf (R4 staat client-Subscriptions toe)? Open; te beslissen met domeinbeheer/architectuur.

De volgende punten zijn inmiddels **besloten** en in de tekst verwerkt: de delete-AuditEvents leggen de **geaggregeerde** proces-status per patiënt vast, niet elke losse `Task.status`-write (grondslag: KT2-juridisch hoeft de verwijdering niet per client te worden onderbouwd — zie [AuditEvents bij statusovergangen](#auditevents-bij-statusovergangen)); en de workflow-events worden gediscrimineerd via **standaard ISO 21089-lifecycle-codes op `AuditEvent.type`** in plaats van een custom CodeSystem of `entity.lifecycle` (géén zoekparameter) — de eerder afgesproken ISO 21089-mapping (memo §3.8) is weer leidend.

Drie eerdere discussiepunten zijn opgeschoond: het subtype **`110126`** is editorieel afgedaan — gehandhaafd met een eigen display (zie de kanttekening onder [Betrokkenheidsmodel](#betrokkenheidsmodel-last-patient-engagement)); de **formele vastlegging van de `kt2-delete-flow`-marker** in de autorisatiepagina's is een actiepunt dat is belegd in de update-instructies voor Topic 05 (`topics/updates/TOP-KT-005-update-instructies.md`; de canonieke CodeSystem-URI is al in de IG vastgelegd, de verworpen alternatieven staan onder [Overwogen alternatieven](#overwogen-alternatieven)); en de **mitigatie van identificerende search-queries** raakt Topic 11 en is overgedragen naar de update-instructies voor Topic 11 (`topics/updates/TOP-KT-011-update-instructies.md`).

### Referenties

- [FHIR R4 Task](https://hl7.org/fhir/R4/task.html) / [Subscription](https://hl7.org/fhir/R4/subscription.html) / [Patient Compartment](https://www.hl7.org/fhir/compartmentdefinition-patient.html)
- [ISO 21089 lifecycle](https://terminology.hl7.org/7.1.0/en/CodeSystem-iso-21089-lifecycle.html) / [Security Labels](https://hl7.org/fhir/R4/security-labels.html) / [FHIR R4 Security](https://hl7.org/fhir/R4/security.html) / [Consent](https://hl7.org/fhir/R4/consent.html) / [CompartmentDefinition](https://hl7.org/fhir/R4/compartmentdefinition.html)
- [SMART Backend Services](https://hl7.org/fhir/smart-app-launch/backend-services.html) / [SMART scopes](https://hl7.org/fhir/smart-app-launch/scopes-and-launch-context.html)
- [AVG](https://eur-lex.europa.eu/eli/reg/2016/679/oj) (art. 5, 15, 17, 19) / [WGBO](https://wetten.overheid.nl/BWBR0005290) / [NEN 7513](https://www.nen.nl/nen-7513-2018-nl-247904)
- TOP-KT-011 — Logging en tracing: [Wijzigingen TOPKT011](memo-wijzigingen-topic11.html) / [implementatie-feedback](change-management-topic-11-implementation-feedback.html)
