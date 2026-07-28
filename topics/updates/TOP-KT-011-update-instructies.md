# TOP-KT-011 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-011 — Logging en tracing |
| Bron-PDF | topics/KTSA-TOP-KT-011 - Logging en tracing-140726-142515.pdf (Confluence-versie 1.3.5, 4 juni 2026, status Draft) |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

TOP-KT-028 (Opschoning patiëntgegevens) leunt op twee manieren op dit topic. Ten eerste wordt het betrokkenheidsmodel (`T_auth`, het startmoment van de bewaartermijn) afgeleid uit de User-Authentication-AuditEvents; daarvoor moeten die events de geauthenticeerde gebruiker attribueren op `entity.what` en moet ook de introspectie van een HTI launch token een event opleveren. Ten tweede produceert het opschoonproces zelf nieuwe, geaggregeerde lifecycle-AuditEvents (ISO 21089) die de verwijdering overleven. Beide uitbreidingen zijn gespecificeerd in het memo "Wijzigingen TOPKT011" (`input/pagecontent/memo-wijzigingen-topic11.md`, §3.6 t/m §3.8) en moeten nu in het topic zelf landen. De huidige Confluence-versie (1.3.5) bevat één User Authentication-sectie (alleen de `/authorize`-variant met optionele IdP op `agent.who(2)`), nog geen introspect-variant, geen authenticatie aan applicatiezijde en geen opschoning-lifecycle-events.

## Wijzigingen

### W1 — Overwegingen › "FHIR AuditEvent en de FHIR resource service"
- **Actie**: wijzigen (opsomming van uitzonderingen aanvullen en producenten verduidelijken)
- **Voorstel**: de bestaande opsomming van events die *niet* door de FHIR resource service worden aangemaakt ("Het starten van een launch / Het ontvangen van een launch / Het melden van een verwerkingsprobleem van een specifieke resource") aanvullen met:

  > - Het authenticeren van een gebruiker buiten de Koppeltaal-authenticatieketen (Application User Authentication, zie de gelijknamige paragraaf — een SHOULD voor de applicatie).

  En direct na die opsomming de volgende alinea toevoegen:

  > Naast de FHIR resource service en de applicaties legt de Koppeltaalvoorziening zelf twee groepen events vast: de User-Authentication-events rond de launch (introspectie van het HTI launch token, de `/authorize`-call en de IdP-stappen — zie de paragraaf User Authentication) en de AuditEvents van de opschoning-lifecycle (zie de paragraaf AuditEvents voor de opschoning-lifecycle en [TOP-KT-028 - Opschoning patiëntgegevens]). Deze events zijn voor leveranciers vooral informatief; zij vormen het bewijsanker voor patiëntbetrokkenheid en daarmee voor de bewaartermijn.
- **Motivatie**: het memo (§3) onderscheidt twee producenten (Koppeltaalvoorziening en applicatie) en legt de applicatiezijde-authenticatie als enige nieuwe leveranciersverantwoordelijkheid vast; de huidige opsomming in het topic is daarop niet meer compleet.

### W2 — "Toepassing, restricties en eisen" › tabel "Vastgelegde events"
- **Actie**: wijzigen (drie rijen toevoegen aan de tabel)
- **Voorstel**: onderstaande rijen toevoegen (kolommen: Gebeurtenis / Verantwoordelijke / Beschreven in):

  | Gebeurtenis | Verantwoordelijke | Beschreven in |
  | --- | --- | --- |
  | Authenticatie van een gebruiker in de keten (introspectie HTI launch token, `/authorize`, IdP-call en IdP-besluit) | Autorisatieservice (Koppeltaalvoorziening) | User Authentication |
  | Authenticatie van een gebruiker aan applicatiezijde, buiten de keten (SHOULD) | Applicatie | Application User Authentication |
  | Statusovergangen van het opschoonproces (aankondiging, hold, unhold, grace-reset, afbreken, definitieve verwijdering) | Koppeltaalvoorziening | AuditEvents voor de opschoning-lifecycle |
- **Motivatie**: de tabel is de ingang van het topic ("welke events, wie is verantwoordelijk"); de drie nieuwe eventgroepen ontbreken er nu volledig in.

### W3 — "Het AuditEvent" › sectie "User Authentication"
- **Actie**: wijzigen (inleidende tekst vóór de veldtabel toevoegen; twee veldbeschrijvingen aanscherpen)
- **Voorstel**: de sectie openen met de volgende tekst (vóór de bestaande veldtabel):

  > De authenticatiegebeurtenissen binnen het Koppeltaal-domein worden vastgelegd als User Authentication AuditEvents van het type `DCM#110114` met subtype `DCM#110122` "Login". De autorisatieservice (onderdeel van de Koppeltaalvoorziening) genereert deze events; applicaties hoeven ze **niet zelf aan te maken**.
  >
  > Er zijn vier varianten. Zij delen dit ene subtype — er zijn dus géén aparte subtypes — en worden onderscheiden via een **prefix in `outcomeDesc`** (bijvoorbeeld `introspect: Introspect succesvol`), die de AuditEvent Viewer als subtype toont. De varianten volgen de launch-flow in de tijd:
  >
  > | Prefix | Wanneer |
  > | --- | --- |
  > | `introspect` | Launch via HTI: introspectie van het HTI launch token |
  > | `authorize` | Launch via SMART app launch: de `/authorize`-call |
  > | `idp call` | Optioneel vanuit `/authorize`: de gebruiker wordt naar de externe IdP gestuurd |
  > | `idp login` | De redirect terug: het IdP-besluit (`outcome` `0` geslaagd / `8` geweigerd) |
  >
  > Bij elke variant staat de geauthenticeerde gebruiker (`Patient` / `RelatedPerson` / `Practitioner`) op `entity.what` (`entity.role` `1` / `6` / `15`) en de uitvoerende applicatie als `agent.who(1)`. Bij de IdP-stappen (`idp call` / `idp login`) komt de IdP daar als tweede handelende partij bij op `agent.who(2)`; bij `introspect` en `authorize` blijft `agent.who(2)` leeg. Een mislukte `idp login` (`outcome` `8`) doet niets af aan de betrokkenheid die `introspect` of `authorize` al heeft vastgelegd.
  >
  > Het `introspect`-event wordt **alleen** vastgelegd bij de introspectie van een HTI launch token; introspectie van access- of id-tokens is een technische validatie en levert géén AuditEvent op (zie [TOP-KT-021 - Token Introspection]).
  >
  > Deze events vormen het **bewijsanker voor patiëntbetrokkenheid**: [TOP-KT-028 - Opschoning patiëntgegevens] leidt de bewaartermijn van patiëntgegevens af uit het meest recente geslaagde (`outcome` = `0`) User-Authentication-event met de Patient of een gekoppelde RelatedPerson op `entity.what` (`T_auth`).

  Daarnaast in de bestaande veldtabel:
  - bij **`subtype`** de toelichting "// of andere code / of andere display waarde" vervangen door: *altijd `DCM#110122` "Login"; de variant wordt uitgedrukt via de prefix in `outcomeDesc`, niet via het subtype*;
  - bij **`outcomeDesc`** toevoegen: *begint met de variant-prefix (`introspect`, `authorize`, `idp call`, `idp login`) gevolgd door een dubbele punt en de resultaatbeschrijving*;
  - bij **`agent.who(2)`** toevoegen: *alleen gevuld bij de varianten `idp call` en `idp login`*.
- **Motivatie**: memo §3.6. De huidige sectie beschrijft impliciet alleen de `/authorize`-variant; zonder de prefix-systematiek en de introspect-variant is `T_auth` (TOP-KT-028) niet uit dit topic af te leiden.

### W4 — "Het AuditEvent" › nieuwe sectie "Application User Authentication" (direct na "User Authentication")
- **Actie**: toevoegen
- **Voorstel**:

  > #### Application User Authentication
  >
  > Naast de authenticatie die de Koppeltaalvoorziening zelf vastlegt (zie User Authentication), kan een applicatie de patiënt of naaste ook **buiten de Koppeltaal-authenticatieketen** authenticeren (bijvoorbeeld een eigen sessie-login). Voor een volledige toegangslog SHOULD de applicatie hiervoor zelf een AuditEvent aanmaken en vastleggen: een eigenstandig event met een eigen subtype `DCM#110126` "Node Authentication" onder type `DCM#110114`. Anders dan de in-keten events (subtype `DCM#110122`) markeert dit patiëntactiviteit búiten de keten. Dit is — anders dan bij User Authentication — wél een verantwoordelijkheid van de leverancier.
  >
  > | Veld | Waarde |
  > | --- | --- |
  > | Extension velden | `request-id`, `correlation-id`, `trace-id`, `resource-origin` — conform de generieke beschrijving |
  > | type | `DCM#110114` "User Authentication" |
  > | subtype | `DCM#110126` "Node Authentication" |
  > | action | `E` |
  > | outcome | `0` succes, anders conform AuditEventOutcome |
  > | agent.who | de applicatie zelf: `Device/<id\|client_id>` |
  > | agent.type | `DCM#110153` "Source Role ID" |
  > | agent.requestor | `true` |
  > | entity.what | de geauthenticeerde `Patient` / `RelatedPerson` / `Practitioner` |
  > | entity.role | `1` / `6` / `15`, conform de mapping van User Authentication |
  > | source.site | de domeinnaam van de applicatie |
  > | source.observer | de `Device`-referentie van de applicatie (`Device/<id\|client_id>`) |
  > | recorded | timestamp van vastlegging |
  >
  > Hiermee is ook patiëntbetrokkenheid die niet via `/authorize` of de HTI-introspectie loopt aantoonbaar. Samen met subtype `DCM#110122` geeft `DCM#110126` een volledig beeld van de patiëntactiviteit; beide subtypes tellen mee in de bewaartermijn-afleiding (`T_auth`, zie [TOP-KT-028 - Opschoning patiëntgegevens]).
- **Motivatie**: memo §3.7. Zonder dit event is activiteit van gebruikers die de applicatie zelf authenticeert onzichtbaar voor het betrokkenheidsmodel en zou een actieve patiënt onterecht opschoonbaar kunnen worden.

### W5 — "Het AuditEvent" › nieuwe sectie "AuditEvents voor de opschoning-lifecycle" (na "Application User Authentication")
- **Actie**: toevoegen
- **Voorstel**:

  > #### AuditEvents voor de opschoning-lifecycle
  >
  > Voor het opschonen van patiëntgegevens (zie [TOP-KT-028 - Opschoning patiëntgegevens]) legt de Koppeltaalvoorziening elke **aggregaat-overgang** van het opschoonproces vast in een immutable AuditEvent met **standaard ISO 21089 record-lifecycle-codes** op `AuditEvent.type` (`http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle`). `type` is een R4-zoekparameter (`AuditEvent?type=…`); dáárop vinden applicaties de events en subscriben zij erop. Een eigen subtype of CodeSystem is niet nodig: de ISO 21089-code op `type` is al onderscheidend.
  >
  > | Aggregaat-overgang (Patiënt) | `type` (iso-21089-lifecycle) | `action` | Doel |
  > | --- | --- | --- | --- |
  > | Aangekondigd — Task(s) aangemaakt (`requested`) | `archive` | `C` | Aantoonbaar: verwijdering aangekondigd, grace period begint |
  > | Geblokkeerd — eerste handrem (`on-hold`) | `hold` | `U` | Aantoonbaar: het proces is geblokkeerd |
  > | Gedeblokkeerd — laatste handrem eraf | `unhold` | `U` | Aantoonbaar: de laatste blokkade is losgelaten |
  > | Grace-reset — holds gewist, grace herstart | `archive` | `U` | Aantoonbaar: grace period herstart, alle holds gewist |
  > | Afgebroken — hernieuwde betrokkenheid (`cancelled`) | `reactivate` | `U` | Aantoonbaar: verwijdering afgebroken |
  > | Definitieve verwijdering uitgevoerd (`completed`) | `destroy` | `D` | Aantoonbaar: data definitief vernietigd; draagt tevens het **post-delete-signaal** |
  >
  > Aankondiging en grace-reset delen `archive` en zijn onderscheidbaar via `action` (`C` = eerste aankondiging, `U` = grace-reset).
  >
  > Enkele velden zijn voor álle events gelijk: `agent.who` = de **Koppeltaalvoorziening** (`Device`), `agent.type` = `DCM#110153` "Source Role ID" (`agent.requestor` = `true`), `outcome` = `0`, en `entity.what` = **altijd de `Patient`** (`Patient/{id}`), nooit de Task. Ook de generieke velden gelden (`request-id`/`correlation-id`/`trace-id`, `source.site`, `source.observer`, `recorded`). Deze AuditEvents bevatten **geen PII en geen vrije tekst** — uitsluitend pseudonieme technische referenties — zodat zij de verwijdering en de langere bewaartermijn (minimaal 5 jaar, NEN 7513, tegenover maximaal 2 jaar voor PII) overleven.
  >
  > De events zijn **server-owned en geaggregeerd**: de Koppeltaalvoorziening logt de geaggregeerde processtatus per patiënt (één event per overgang over de per-app Tasks heen), niet elke losse `Task.status`-write. Een tweede hold of een gedeeltelijke release levert dus geen event op; `unhold` volgt pas wanneer de láátste handrem eraf gaat én het proces daarna doorloopt naar de grace-deadline. Zet diezelfde laatste release álle Tasks op `accepted`, dan volgt direct `destroy` in plaats van `unhold`. De losse `Task.status`-writes van applicaties worden via de reguliere create/update-AuditEvents gelogd. De reden van een hold (`Task.statusReason`) leeft per applicatie op de Task en staat niet in het geaggregeerde event. Bij het **fast-track-pad** (geen recente activiteit) ontbreken de aankondigings- en tussenevents; alleen het `destroy`-event wordt vastgelegd.
  >
  > **Impact voor leveranciers.** Applicaties reageren via hun eigen `Task.status` (`on-hold`/`accepted`); een enkele app-actie leidt niet één-op-één tot een lifecycle-AuditEvent. Voor het moment van definitieve verwijdering subscriben doelapplicaties op het `destroy`-event: omdat de Task in de verwijdering mee verdwijnt, is dit AuditEvent de enige bron voor het post-delete-signaal. Voorbeeld-criteria:
  >
  > ```
  > AuditEvent?type=http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|destroy&_security=https://koppeltaal.nl/fhir/CodeSystem/security-label|kt2-delete-flow
  > ```
- **Motivatie**: memo §3.8 en TOP-KT-028 ("AuditEvents bij statusovergangen"). De lifecycle-events zijn de aantoonbare audit trail van het verwijderproces én het enige bevestigingskanaal ná de erase; ze horen thuis in het topic dat alle AuditEvents specificeert.

### W6 — Versiegeschiedenis
- **Actie**: toevoegen (nieuwe rij bovenaan)
- **Voorstel**: versie 1.4.0, status concept, wijzigingstekst:

  > User Authentication uitgebreid tot vier varianten binnen subtype `DCM#110122`, onderscheiden via een prefix in `outcomeDesc` (`introspect`, `authorize`, `idp call`, `idp login`); het `introspect`-event geldt alleen voor HTI launch tokens. Nieuwe paragrafen: Application User Authentication (subtype `DCM#110126`, SHOULD, authenticatie aan applicatiezijde) en AuditEvents voor de opschoning-lifecycle (ISO 21089-codes `archive`/`hold`/`unhold`/`reactivate`/`destroy`, inclusief veldmapping) t.b.v. TOP-KT-028 - Opschoning patiëntgegevens. Tabel "Vastgelegde events" en de producenten-beschrijving hierop aangevuld.
- **Motivatie**: consistente versiegeschiedenis; de wijziging is functioneel (minor bump t.o.v. 1.3.5).

## Verwijzingen

- `input/pagecontent/memo-wijzigingen-topic11.md` — §3.6 (User Authentication, vier varianten), §3.7 (Application User Authentication), §3.8 (opschoning-lifecycle). *Let op: in memoversies t/m 0.0.3 waren dit §3.6–§3.9; het huidige §3.8 (opschoning) heette daar §3.9.*
- `topics/TOP-KT-028-opschoning-patientgegevens.md` — m.n. "Betrokkenheidsmodel: last-patient-engagement" en "AuditEvents bij statusovergangen"
- `input/pagecontent/opschoning-patient-data.md` — IG-pagina met dezelfde specificatie
- ISO 21089-lifecycle-CodeSystem: `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle`
- Er is geen actuele markdown-versie van dit topic in `topics/`; de oude `TOP-KT-011`-.doc is genegeerd. De bron is uitsluitend de Confluence-PDF (1.3.5).

## Open punten

1. **Subtype `DCM#110126` (W4)** — afhankelijk van besluit TOP-KT-028 discussiepunt 3: FHIR labelt `110126` als "Node Authentication" (geen user-login); handhaven met eigen display of een passender subtype kiezen is nog open, er is nog geen harde SHALL.
2. **Marker-code in het subscription-voorbeeld (W5)** — afhankelijk van besluit TOP-KT-028 discussiepunt 4: de exacte code en het CodeSystem van de `kt2-delete-flow`-marker zijn nog te bevestigen; het `_security`-deel van de voorbeeld-criteria kan dan wijzigen (het `type`-deel staat vast).
3. **Bewaartermijn AuditEvents** — de "minimaal 5 jaar" in W5 is per TOP-KT-028 nog te bevestigen tegen NEN 7513.
4. **Versie-check** — de bron-PDF is versie 1.3.5 met status Draft (4 juni 2026); controleer bij verwerking in Confluence of er inmiddels een nieuwere versie is en verwerk deze instructies daarin.
