### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.0.1 | 2026-04-01 | Initiële versie |
| 0.0.2 | 2026-06-10 | AuditEvents voor authenticatie (login: `/authorize`, IdP-call, IdP-besluit), HTI-introspectie en authenticatie aan applicatiezijde toegevoegd; AuditEvents voor de opschoning-lifecycle toegevoegd, inclusief veldmapping (`action`, `agent.who`, `entity.what`, `outcome`) per lifecycle-event |
| 0.0.3 | 2026-06-15 | §3.6 vereenvoudigd: alle authenticatie-events gebruiken `DCM#110114` / `DCM#110122` met de geauthenticeerde gebruiker op `entity.what` (`entity.role` 1/6/15) en de handelende systemen (applicatie, IdP) op `agent.who`; differentiatie via `outcome` en `agent.who(2)`; §3.7 bijgewerkt: `T_authorize` en `T_introspect_hti` zijn query-equivalent, samengevoegd als `T_auth`; §3.8 mapping verduidelijkt |

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

1. de **Koppeltaalvoorziening** — het merendeel van de REST- en lifecycle-events, de authenticatie-events rond login en HTI-introspectie (§3.6 en §3.7) en de opschoning-lifecycle (§3.9). De FHIR resource service, de autorisatiefunctie en de opschoningsfunctie zijn onderdelen van de Koppeltaalvoorziening en worden in dit memo niet als afzonderlijke producenten onderscheiden;
2. de **applicatie van de leverancier** zelf — onder andere Launch, Launched en de authenticatie aan applicatiezijde (§3.8).

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

#### 3.6 AuditEvent: User Authentication — HTI-introspectie en IdP-besluit

De authenticatiegebeurtenissen bij een Koppeltaal-launch worden vastgelegd als `User Authentication` AuditEvents van het type `DCM#110114` / subtype `DCM#110122` "Login". De Koppeltaalvoorziening genereert deze events op het moment van de **impliciete HTI-tokenintrospectie**; de applicatie hoeft ze **niet zelf aan te maken** — ze zijn voor leveranciers relevant als bewijsanker voor patiëntbetrokkenheid (zie §3.9 en [opschoning-patient-data.html](./opschoning-patient-data.html)).

Alle events delen hetzelfde type/subtype (`DCM#110114` / `DCM#110122`). De **geauthenticeerde gebruiker** (Patient / RelatedPerson / Practitioner) staat altijd op `entity.what` (met `entity.role` 1 / 6 / 15); de **handelende systemen** (applicatie en — bij IdP-login — de IdP) staan op `agent.who`. De onderlinge differentiatie zit in `outcome` en in de aanwezigheid van `agent.who(2)`:

| Moment | `agent.who` (handelende systemen) | `entity.what` (geauthenticeerde gebruiker) | `outcome` |
| --- | --- | --- | --- |
| HTI launch token geïntrospecteerd | `agent.who(1)` = aanvragende applicatie (`Device`/`client_id`), `agent.type` = `DCM#110153` Source Role ID, `requestor=true` | de `Patient` / `RelatedPerson` / `Practitioner` (`entity.role` 1 / 6 / 15) | `0` bij succes |
| IdP-besluit (uitsluitend bij IdP-authenticatie) | `agent.who(2)` = de IdP (`identifier.system =` http://koppeltaal.nl/oidc/issuer`)`,` agent.type`` = `DCM#110152` Destination Role ID, `requestor=false` | dezelfde geauthenticeerde persoon | `0` (geslaagd) of `8` (geweigerd) |

> **Let op.** Een mislukte IdP-login (`outcome = 8` op het IdP-besluit-event) doet **niet** af aan de patiëntbetrokkenheid die reeds is vastgelegd via het HTI-introspectie-event (`outcome = 0`). Beide events worden onafhankelijk vastgelegd.

#### 3.7 AuditEvent: Token Introspection (HTI launch token)

Het HTI-introspectie-event is de eerste rij in de tabel van §3.6: type `DCM#110114` / subtype `DCM#110122` "Login", gegenereerd door de Koppeltaalvoorziening op het introspect-endpoint. Het event wordt uitsluitend vastgelegd **wanneer het geïntrospecteerde token een HTI launch token is**; introspectie van access- of id-tokens is een technische validatie en levert géén AuditEvent op.

- **`type` / `subtype`**: `DCM#110114` / `DCM#110122` — dezelfde coding als de overige User Authentication-events; geen afzonderlijk subtype nodig.
- **Actor-mapping**: de bij de launch betrokken `Patient` / `RelatedPerson` wordt op `entity.what` gezet (`entity.role` 1 / 6), zodat het event als patiëntbetrokkenheid telt; `agent.who(1)` is de aanroepende applicatie (`Device`).
- **Aanmaak**: de Koppeltaalvoorziening legt dit event vast. **De HTI-introspectie wordt aangeroepen door de doelapplicatie; het AuditEvent zelf is daarmee voor leveranciers informatief.**

Omdat de event-coding gelijk is aan die van `/authorize`-events (`DCM#110114` / `DCM#110122` met de Patient op `entity.what`), zijn beide signalen **query-equivalent**. Ze zijn daarvoor samengevoegd in `T_auth` en de bewaartermijn-berekening vereenvoudigt tot `max(T_auth, T_task_owner)` (zie [opschoning-patient-data.html](./opschoning-patient-data.html)).

#### 3.8 AuditEvent: Authenticatie aan applicatiezijde

Naast de authenticatie die de Koppeltaalvoorziening zelf vastlegt (§3.6 en §3.7), kan een applicatie de patiënt of naaste ook buiten de Koppeltaalvoorziening authenticeren (bijvoorbeeld in een eigen sessie). Voor een volledige toegangslog SHOULD de applicatie ook voor dit moment een User Authentication-AuditEvent (`DCM#110114` / `DCM#110122`) aanmaken en in de Koppeltaalvoorziening vastleggen. Dit sluit aan op de codering die de Koppeltaalvoorziening zelf hanteert (§3.6).

- **Aanmaak**: door de applicatie zelf (dit is, anders dan §3.6/§3.7, wél een verantwoordelijkheid van de leverancier).
- **`source.site`**: de domeinnaam van de applicatie; **`source.observer`**: de `Device`-referentie van de applicatie (`Device/<id|client_id>`).
- **`entity.what`**: de geauthenticeerde `Patient` / `RelatedPerson` / `Practitioner` (`entity.role` 1 / 6 / 15), conform de mapping van User Authentication; **`agent.who`**: de applicatie (`Device`/`client_id`, `requestor=true`).

Hiermee is ook patiëntbetrokkenheid die niet via `/authorize` of de HTI-introspectie loopt aantoonbaar en telt zij mee in de bewaartermijn-afleiding (`last-patient-engagement`, zie [opschoning-patient-data.html](./opschoning-patient-data.html)).

#### 3.9 AuditEvents voor de opschoning-lifecycle

Voor het opschonen van patiëntdata (zie [opschoning-patient-data.html](./opschoning-patient-data.html)) wordt elke statusovergang van de aankondigings-Task (`KT2_DeletePendingTask`) vastgelegd in een immutable AuditEvent met **ISO 21089 lifecycle-codes** op `AuditEvent.type` (`http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle`). Deze events overleven de `$purge` en vormen de aantoonbare audit trail van het verwijderproces.

| Moment | ISO 21089 `type` | Aangemaakt door | Doel |
| --- | --- | --- | --- |
| Verwijdering aangekondigd (Task `requested`) | `archive` | Koppeltaalvoorziening | Aantoonbaar: verwijdering aangekondigd, grace period begint |
| Noodrem getrokken (Task `on-hold`) | `hold` | **Doelapplicatie** | Aantoonbaar: welke applicatie blokkeert en waarom (`statusReason`) |
| Blokkade opgeheven (Task `accepted`) | `unhold` | **Doelapplicatie** | Aantoonbaar: blokkade is opgeheven |
| Afgebroken (Task `cancelled`) | `reactivate` | Koppeltaalvoorziening | Aantoonbaar: verwijdering afgebroken wegens hernieuwde betrokkenheid |
| `$purge` uitgevoerd (Task `completed`) | `destroy` | Koppeltaalvoorziening | Aantoonbaar: data definitief vernietigd; draagt tevens het **post-delete** signaal |

De overige AuditEvent-velden per statusovergang. `agent.type` is in alle gevallen `DCM#110153` "Source Role ID" met `requestor = true`; `entity.type` volgt de gerefereerde resource (`…resource-types#Task`, of `#Patient` bij `destroy`). Een eigen `subtype` is niet nodig — de ISO 21089-code op `type` is al onderscheidend.

| ISO 21089 `type` | `action` | `agent.who` | `entity.what` | `outcome` |
| --- | --- | --- | --- | --- |
| `archive` | `C` | Koppeltaalvoorziening (`Device`) | de aangemaakte `KT2_DeletePendingTask` | `0` |
| `hold` | `U` | doelapplicatie (`Device`/`client_id`) | de eigen `KT2_DeletePendingTask`; reden uit `Task.statusReason` | `0` |
| `unhold` | `U` | doelapplicatie (`Device`/`client_id`) | de eigen `KT2_DeletePendingTask` | `0` |
| `reactivate` | `U` | Koppeltaalvoorziening (`Device`) | de `KT2_DeletePendingTask`(s); reden "hernieuwde betrokkenheid" | `0` |
| `destroy` | `D` | Koppeltaalvoorziening (`Device`) | de opgeschoonde `Patient/{id}` (technische referentie) | `0` |

De generieke velden gelden ook hier (extensions `request-id` / `correlation-id` / `trace-id`, `source.site`, `source.observer`, `recorded`). Deze AuditEvents bevatten **geen PII** — uitsluitend technische referenties — zodat zij de `$purge` en de langere bewaartermijn overleven.

**Impact voor leveranciers.** Een opt-in doelapplicatie legt zelf de `hold`- en `unhold`-events vast wanneer zij haar eigen Task op `on-hold` respectievelijk `accepted` zet. Voor het moment van definitieve verwijdering subscriben doelapplicaties op het `destroy`-event (`type = …iso-21089-lifecycle|destroy`): omdat de Task in het Patient-compartiment mee verdwijnt in de `$purge`, is dit AuditEvent de enige bron voor het post-delete signaal.

### 4. Kwalificatie-impact

- Er is **geen aparte kwalificatie** nodig specifiek voor Topic 11.
- De wijzigingen worden onderdeel van de reguliere kwalificatie wanneer een leverancier zijn applicatie opnieuw laat kwalificeren.
- Voor reeds gekwalificeerde applicaties geldt: implementatie wordt verwacht bij doorontwikkeling, maar er is geen directe verplichting tot herkwalificatie.
- De nieuwe AuditEvents uit §3.6 t/m §3.9 hebben voorlopig geen kwalificatie-impact. De codings voor §3.6 t/m §3.8 zijn vastgesteld (DCM#110114 / DCM#110122); de tijdlijn voor opname in de reguliere kwalificatie wordt in een vervolgtraject bepaald.

### 5. Conclusie

De aanpassingen in TOPKT011 die in release KTV 2.4.0 worden meegenomen, zijn beperkt en richten zich vooral op uniformiteit en verduidelijking van de AuditEvents. De impact op leveranciers is overzichtelijk. Leveranciers hoeven geen aparte kwalificatie te doorlopen maar kunnen de wijzigingen meenemen bij een toekomstige reguliere kwalificatie.
