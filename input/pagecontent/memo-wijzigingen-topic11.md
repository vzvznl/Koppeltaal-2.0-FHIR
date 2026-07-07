### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.0.1 | 2026-04-01 | Initiële versie |
| 0.0.2 | 2026-06-10 | AuditEvents voor authenticatie (login: `/authorize`, IdP-call, IdP-besluit), HTI-introspectie en authenticatie aan applicatiezijde toegevoegd; AuditEvents voor de opschoning-lifecycle toegevoegd, inclusief veldmapping (`action`, `agent.who`, `entity.what`, `outcome`) per lifecycle-event |
| 0.0.3 | 2026-06-15 | §3.6 vereenvoudigd: alle authenticatie-events gebruiken `DCM#110114` / `DCM#110122` met de geauthenticeerde gebruiker op `entity.what` (`entity.role` 1/6/15) en de handelende systemen (applicatie, IdP) op `agent.who`; differentiatie via `outcome` en `agent.who(2)`; §3.7 bijgewerkt: `T_authorize` en `T_introspect_hti` zijn query-equivalent, samengevoegd als `T_auth`; §3.8 mapping verduidelijkt |
| 0.0.4 | 2026-06-17 | §3.6 herzien tot één **User Authentication**-sectie: vier varianten binnen subtype `DCM#110122`, onderscheiden via een prefix in `outcomeDesc` (`introspect`, `authorize`, `idp call`, `idp login`) die de AuditEvent Viewer als subtype toont; de voormalige aparte introspect-sectie is hierin opgegaan. Authenticatie aan applicatiezijde (nu §3.7) krijgt een eigen subtype `DCM#110126` "Node Authentication" (event *Application User Authentication*). Resterende secties hernummerd (§3.8→§3.7, §3.9→§3.8); §3 en §4 bijgewerkt |

---

### Memo: Wijzigingen TOPKT011 (Logging & Tracing)

**Datum:** 2 april 2026
**Voor:** Koppeltaal Technical Community
**Van:** Kees Graveland & Roland Groen
**Onderwerp:** Overzicht wijzigingen in TOPKT011 en impact voor gekwalificeerde applicaties

### 1. Aanleiding

In voorbereiding op release KTV 2.4.0 van de Koppeltaalvoorziening worden diverse wijzigingen uit de nieuwe versie van TOPKT011 – Logging & Tracing doorgevoerd. Dit memo geeft een overzicht van de relevante wijzigingen en de impact hiervan op applicaties die gebruikmaken van Koppeltaal.

De nieuwe versie van het topic is gepubliceerd op [Confluence](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27095009/TOP-KT-011+-+Logging+en+tracing).

### 2. Implementatieverwachting voor applicaties

De laatste definitieve versie van het topic die door leveranciers geïmplementeerd moet zijn, is **versie 1.3.4**.

De wijzigingen die nu worden doorgevoerd in KTV 2.4.0 zijn óók relevant voor applicaties, maar leiden **niet** tot een aparte kwalificatieronde voor Topic 11.

Leveranciers die zich opnieuw laten kwalificeren kunnen deze wijzigingen direct meenemen in de reguliere kwalificatieprocedure.

### 3. Overzicht van de wijzigingen

Bij het verwerken van de updates uit TOPKT011 ligt de nadruk op die elementen waar de applicatie zelf verantwoordelijk voor is. De aanpassingen worden hieronder per AuditEvent gespecificeerd.

AuditEvents worden in Koppeltaal door **twee producenten** aangemaakt:

1. de **Koppeltaalvoorziening** — het merendeel van de REST- en lifecycle-events, de authenticatie-events rond login en HTI-introspectie (§3.6) en de opschoning-lifecycle (§3.8). De FHIR resource service, de autorisatiefunctie en de opschoningsfunctie zijn onderdelen van de Koppeltaalvoorziening en worden in dit memo niet als afzonderlijke producenten onderscheiden;
2. de **applicatie van de leverancier** zelf — onder andere Launch, Launched en de authenticatie aan applicatiezijde (§3.7).

De events van producent 1 zijn voor leveranciers vooral informatief; zij zijn opgenomen omdat ze het bewijsanker vormen voor patiëntbetrokkenheid.

#### 3.1 Wijzigingen voor alle AuditEvents

Alle AuditEvents krijgen de volgende generieke aanpassingen:

- **Extension-velden** zijn aangepast (uniformering en verduidelijking)
- **`source.site`** wordt vastgelegd volgens de nieuwe specificatie
- **`outcomeDesc`** is aangescherpt en dient door de applicatie correct gevuld te worden

#### 3.2 AuditEvent: Launch

Geen aanvullende aanpassingen naast de wijzigingen die voor alle AuditEvents gelden.

#### 3.3 AuditEvent: Launched

Geen extra wijzigingen buiten de generieke aanpassingen.

#### 3.4 AuditEvent: Receive Notification

Naast de generieke wijzigingen:

- **`type`**: code gewijzigd naar `receive`, display naar "Receive/Retain Record Lifecycle Event"
- **`agent.who`**, **`agent.type`** en **`agent.requestor`** van de verzendende partij zijn **verwijderd**. Deze informatie wordt vanaf nu alleen voor de ontvangende partij vastgelegd.

#### 3.5 AuditEvent: Status Change

Geen verdere inhoudelijke wijzigingen naast de generieke aanpassingen.

#### 3.6 AuditEvent: User Authentication

De authenticatiegebeurtenissen binnen het Koppeltaal-domein worden vastgelegd als `User Authentication` AuditEvents van het type `DCM#110114` / subtype `DCM#110122` "Login". De Koppeltaalvoorziening genereert deze events; de applicatie hoeft ze **niet zelf aan te maken** — ze zijn voor leveranciers relevant als bewijsanker voor patiëntbetrokkenheid (zie §3.8 en [opschoning-patient-data.html](./opschoning-patient-data.html)).

De vier varianten delen dit ene subtype — er zijn dus **geen aparte subtypes** — en worden onderscheiden via een **prefix in `outcomeDesc`** (bijvoorbeeld `introspect: Introspect succesvol`), die de AuditEvent Viewer als subtype toont. Ze volgen de launch-flow in de tijd:

| Prefix | Wanneer |
| --- | --- |
| `introspect` | Launch via HTI: introspectie van het HTI launch token |
| `authorize` | Launch via SMART app launch: de `/authorize`-call |
| `idp call` | Optioneel vanuit `/authorize`: de gebruiker wordt naar de externe IdP gestuurd |
| `idp login` | De redirect terug: het IdP-besluit (`outcome` `0` geslaagd / `8` geweigerd) |

Bij elke variant staat de geauthenticeerde gebruiker (Patient / RelatedPerson / Practitioner) op `entity.what` en de uitvoerende applicatie als `agent.who(1)`. Bij de IdP-stappen (`idp call` / `idp login`) komt de IdP daar als tweede handelende partij bij op `agent.who(2)`. Een mislukte idp login (outcome 8) doet niets af aan de betrokkenheid die introspect of authorize al heeft vastgelegd.

Het `introspect`-event wordt **alleen** vastgelegd voor HTI launch tokens; introspectie van access- of id-tokens is een technische validatie en levert géén AuditEvent op. Omdat `introspect` en `authorize` dezelfde coding delen (met de gebruiker op `entity.what`), zijn ze query-equivalent en samengevoegd in `T_auth`, wat de bewaartermijn-berekening vereenvoudigt tot `max(T_auth, T_task_owner)` (zie [opschoning-patient-data.html](./opschoning-patient-data.html)).

#### 3.7 AuditEvent: Application User Authentication (authenticatie aan applicatiezijde)

Naast de authenticatie die de Koppeltaalvoorziening zelf vastlegt (§3.6), kan een applicatie de patiënt of naaste ook **buiten de Koppeltaal-authenticatieketen** authenticeren (bijvoorbeeld een eigen sessie-login). Voor een volledige toegangslog SHOULD de applicatie hiervoor zelf een AuditEvent aanmaken en vastleggen: een eigenstandig event (Application User Authentication) met een eigen subtype DCM#110126 "Node Authentication" onder type DCM#110114. Anders dan de in-keten events (subtype DCM#110122) markeert dit patiëntactiviteit búiten de keten.

- **Aanmaak**: door de applicatie zelf (dit is, anders dan §3.6, wél een verantwoordelijkheid van de leverancier).
- **`source.site`**: de domeinnaam van de applicatie; **`source.observer`**: de `Device`-referentie van de applicatie (`Device/<id|client_id>`).
- **`entity.what`**: de geauthenticeerde `Patient` / `RelatedPerson` / `Practitioner` (`entity.role` 1 / 6 / 15), conform de mapping van User Authentication; **`agent.who`**: de applicatie (`Device`/`client_id`, `requestor=true`).

Hiermee is ook patiëntbetrokkenheid die niet via `/authorize` of de HTI-introspectie loopt aantoonbaar. Samen met `DCM#110122` geeft `DCM#110126` een volledig beeld van de patiëntactiviteit; beide subtypes tellen mee in de bewaartermijn-afleiding (`last-patient-engagement`, zie [opschoning-patient-data.html](./opschoning-patient-data.html)).

#### 3.8 AuditEvents voor de opschoning-lifecycle

Voor het opschonen van patiëntdata (zie [opschoning-patient-data.html](./opschoning-patient-data.html)) wordt elke statusovergang van de aankondigings-Task (`KT2_DeletePendingTask`) vastgelegd in een immutable AuditEvent met **ISO 21089 lifecycle-codes** op `AuditEvent.type` (`http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle`). Deze events overleven de `$purge` en vormen de aantoonbare audit trail van het verwijderproces.

| Moment | `type` | `action` | `agent.who` | Doel |
| --- | --- | --- | --- | --- |
| Verwijdering aangekondigd (Task `requested`) | `archive` | `C` | Koppeltaalvoorziening | Aantoonbaar: verwijdering aangekondigd, grace period begint |
| Noodrem getrokken (Task `on-hold`) | `hold` | `U` | **Doelapplicatie** | Aantoonbaar: welke applicatie blokkeert en waarom (`statusReason`) |
| Noodrem opgeheven (Task `on-hold → accepted`) | `unhold` | `U` | **Doelapplicatie** | Aantoonbaar: de app laat haar blokkade los |
| Groen licht zonder eerdere hold (Task `requested → accepted`) | `verify` | `U` | **Doelapplicatie** | Aantoonbaar: de app keurt verwijdering goed (conform eigen beleid) |
| Holds gewist (grace-reset, Task → `requested`) | `archive` | `U` | Koppeltaalvoorziening | Aantoonbaar: grace period herstart, alle holds gewist |
| Afgebroken (Task `cancelled`) | `reactivate` | `U` | Koppeltaalvoorziening | Aantoonbaar: verwijdering afgebroken wegens hernieuwde betrokkenheid |
| `$purge` uitgevoerd (Task `completed`) | `destroy` | `D` | Koppeltaalvoorziening | Aantoonbaar: data definitief vernietigd; draagt tevens het **post-delete** signaal |

Deze delete-AuditEvents zijn **server-owned**: de Koppeltaalvoorziening maakt ze (ook die van een app-actie), met de handelende partij op `agent.who`. Enkele velden zijn voor álle events gelijk en staan daarom niet in de tabel: `agent.type` = `DCM#110153` "Source Role ID" (`requestor = true`), `outcome` = `0`, en `entity.what` = **altijd de `Patient`** (`entity=Patient/{id}`) — net als in [opschoning-patient-data](./opschoning-patient-data.html), nooit de Task. De reden van een overgang (bijv. `Task.statusReason` bij `hold`, of "hernieuwde betrokkenheid" bij `reactivate`) staat in `entity.detail`. Een eigen `subtype` is niet nodig — de ISO 21089-code op `type` is al onderscheidend. Ook de generieke velden gelden (`request-id`/`correlation-id`/`trace-id`, `source.site`, `source.observer`, `recorded`). Deze AuditEvents bevatten **geen PII** — uitsluitend technische referenties — zodat zij de `$purge` en de langere bewaartermijn overleven.

**Impact voor leveranciers.** Zet een doelapplicatie haar eigen Task op `on-hold` of `accepted`, dan legt de Koppeltaalvoorziening het bijbehorende `hold`-, `unhold`- of `verify`-event vast met de app als `agent.who` (`unhold` na een eerdere noodrem, `verify` bij groen licht zonder hold). Voor het moment van definitieve verwijdering subscriben doelapplicaties op het `destroy`-event (`type = …iso-21089-lifecycle|destroy`): omdat de Task in het Patient-compartiment mee verdwijnt in de `$purge`, is dit AuditEvent de enige bron voor het post-delete signaal.

### 4. Kwalificatie-impact

- Er is **geen aparte kwalificatie** nodig specifiek voor Topic 11.
- De wijzigingen worden onderdeel van de reguliere kwalificatie wanneer een leverancier zijn applicatie opnieuw laat kwalificeren.
- Voor reeds gekwalificeerde applicaties geldt: implementatie wordt verwacht bij doorontwikkeling, maar er is geen directe verplichting tot herkwalificatie.
- De nieuwe AuditEvents uit §3.6 t/m §3.8 hebben voorlopig geen kwalificatie-impact. De codings zijn vastgesteld: §3.6 gebruikt DCM#110114 / DCM#110122 (met variant-differentiatie via de outcomeDesc-prefix), §3.7 gebruikt DCM#110114 / DCM#110126; de tijdlijn voor opname in de reguliere kwalificatie wordt in een vervolgtraject bepaald.

### 5. Conclusie

De aanpassingen in TOPKT011 die in release KTV 2.4.0 worden meegenomen, zijn beperkt en richten zich vooral op uniformiteit en verduidelijking van de AuditEvents. De impact op leveranciers is overzichtelijk. Leveranciers hoeven geen aparte kwalificatie te doorlopen maar kunnen de wijzigingen meenemen bij een toekomstige reguliere kwalificatie.
