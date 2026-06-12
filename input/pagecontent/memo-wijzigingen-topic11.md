### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.0.1 | 2026-04-01 | Initiële versie |
| 0.0.2 | 2026-06-10 | AuditEvents voor authenticatie (login: `/authorize`, IdP-call, IdP-besluit), HTI-introspectie en authenticatie aan applicatiezijde toegevoegd; AuditEvents voor de opschoning-lifecycle toegevoegd, inclusief veldmapping (`action`, `agent.who`, `entity.what`, `outcome`) per lifecycle-event |

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

#### 3.6 AuditEvent: User Authentication — login (`/authorize`, IdP-call, IdP-besluit)

Voor een sluitende, NEN 7513-conforme vastlegging van het authenticatieproces (zie *User Authentication* in TOPKT011) wordt het login-moment niet langer als één gebeurtenis vastgelegd, maar als **drie afzonderlijke AuditEvents** rond de Koppeltaal-launch. Alle drie zijn van het type `User Authentication` (`DCM#110114`) en worden gegenereerd door de **Koppeltaalvoorziening** (autorisatiefunctie); ze verschillen in het `subtype` en in de actor-mapping. De applicatie hoeft deze events **niet zelf aan te maken** — ze zijn voor leveranciers vooral relevant omdat ze het bewijsanker vormen voor patiëntbetrokkenheid (zie §3.9 en de pagina [opschoning-patient-data.html](./opschoning-patient-data.html)).

| Moment | `subtype` | Actor-mapping | Doel |
| --- | --- | --- | --- |
| Aanroep `/authorize` | `DCM#110122` "Login" | `agent.who(1)` = aanvragende applicatie (`Device`/`client_id`), `agent.type` = `DCM#110153` Source Role ID, `requestor=true` | De applicatie start de OIDC/SMART-flow met de autorisatiestap |
| Aanroep van de IdP | `DCM#110144` "Authentication Delegated to IdP" | `agent.who(2)` = de IdP (`identifier` met `iss` op `http://koppeltaal.nl/oidc/issuer`, of `display` met logische naam), `agent.type` = `DCM#110152` Destination Role ID, `requestor=false` | De Koppeltaalvoorziening stuurt de authenticatie door naar de IdP |
| IdP-besluit | `DCM#110145` "IdP Authentication Decision" | `entity.what` = de geauthenticeerde persoon (`Patient` / `RelatedPerson` / `Practitioner`, met `entity.role` 1 / 6 / 15); `outcome` draagt het resultaat van het besluit | De Koppeltaalvoorziening verwerkt de authenticatie-uitslag van de IdP |

> **Voorlopige codings (reference-impl first).** De aanroep van `/authorize` blijft `DCM#110122` "Login" (conform het bestaande `auditevent-launch-example`). De codes `DCM#110144` en `DCM#110145` zijn **Koppeltaal-voorstellen** binnen het `DCM`-systeem; DICOM kent nog geen aparte codes voor "delegatie naar IdP" en "IdP-besluit". Ze zijn bewust concreet gekozen zodat de referentie-implementatie ermee kan worden gebouwd, en zijn eenvoudig aan te passen wanneer de definitieve codings worden vastgesteld in een vervolgtraject (relateert aan [TOP-KT-021 – Token Introspection](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27125106)). Mocht ratificatie binnen het DICOM-systeem niet haalbaar zijn, dan wijken deze twee subtypes uit naar een Koppeltaal-eigen CodeSystem.

#### 3.7 AuditEvent: Token Introspection (HTI launch token)

Bij de `/introspect`-call wordt een nieuw `User Authentication`-AuditEvent (`DCM#110114`) vastgelegd, **uitsluitend wanneer het geïntrospecteerde token een HTI launch token is**. Introspectie van access- of id-tokens is een technische tokenvalidatie, bewijst geen patiëntinteractie en levert dus géén authenticatie-AuditEvent op.

- **`subtype`**: `DCM#110143` "Token Introspection (HTI launch)" — een Koppeltaal-voorstel binnen het `DCM`-systeem, voorlopig vastgesteld voor de referentie-implementatie en aan te passen bij definitieve codering (zie TOP-KT-021). Sluit aan op het voorstel op de pagina [opschoning-patient-data.html](./opschoning-patient-data.html).
- **Actor-mapping**: de bij de launch betrokken `Patient` / `RelatedPerson` wordt op `agent.who` gezet, zodat het event als betrokkenheid van die patiënt telt.
- **Aanmaak**: de Koppeltaalvoorziening legt dit event vast op het introspect-endpoint. **De HTI-introspectie wordt aangeroepen door de ontvangende (doel)applicatie; het AuditEvent zelf is daarmee voor leveranciers informatief, niet iets dat zij zelf indienen.**

Dit event hergebruikt het bestaande User Authentication-event en vereist dus géén nieuw AuditEvent-type. Met de voorlopige coding `DCM#110143` kan het pad in de referentie-implementatie alvast worden gebouwd; de pagina [opschoning-patient-data.html](./opschoning-patient-data.html) houdt het `T_introspect_hti`-signaal als bewaartermijn-bron pas actief zodra de coding definitief is vastgesteld.

#### 3.8 AuditEvent: Authenticatie aan applicatiezijde

Naast de authenticatie die de Koppeltaalvoorziening zelf vastlegt (§3.6 en §3.7), kan een applicatie de patiënt of naaste ook **buiten de Koppeltaalvoorziening** authenticeren (bijvoorbeeld in een eigen sessie). Voor een volledige toegangslog SHOULD de applicatie ook voor dit moment een User Authentication-AuditEvent (DCM#110114) aanmaken en in de Koppeltaalvoorziening vastleggen.

- **Aanmaak**: door de applicatie zelf (dit is, anders dan §3.6/§3.7, wél een verantwoordelijkheid van de leverancier).
- **`source.site`**: de domeinnaam van de applicatie; **`source.observer`**: de `Device`-referentie van de applicatie (`Device/<id|client_id>`).
- **`agent` / `entity.what`**: de geauthenticeerde `Patient` / `RelatedPerson` / `Practitioner`, conform de mapping van User Authentication.

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
- De nieuwe AuditEvents uit §3.6 t/m §3.9 hebben **voorlopig geen kwalificatie-impact**. De codings zijn nog voorlopig (reference-impl first) en worden in een vervolgtraject vastgesteld; pas daarna wordt bepaald of en hoe zij in de reguliere kwalificatie landen.

### 5. Conclusie

De aanpassingen in TOPKT011 die in release KTV 2.4.0 worden meegenomen, zijn beperkt en richten zich vooral op uniformiteit en verduidelijking van de AuditEvents. De impact op leveranciers is overzichtelijk. Leveranciers hoeven geen aparte kwalificatie te doorlopen maar kunnen de wijzigingen meenemen bij een toekomstige reguliere kwalificatie.
