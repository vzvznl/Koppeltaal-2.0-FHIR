### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.0.1 | 2026-04-13 | Initiële versie |
| 0.0.2 | 2026-04-24 | Optie toegevoegd om de Binary als losse resource in de Koppeltaal-store te plaatsen, met autorisatie via de bestaande matrix |
| 0.0.3 | 2026-05-05 | Pagina hernoemd naar "Documenten delen"; sectie "Gestructureerde resultaten (Observation)" verwijderd; pagina-scope beperkt tot ongestructureerde documenten (gestructureerde data verhuist naar de KoppelMij-context) |
| 0.0.6 | 2026-05-05 | Historische labels "Pad A", "Pad B" en "Pad C" verwijderd uit de pagina-tekst; alternatieven worden voortaan bij hun beschrijvende naam genoemd |
| 0.0.7 | 2026-05-05 | PlantUML-diagrambestanden hernoemd: `resultaten-delen-pad-a` → `documenten-delen-direct-ophalen` en `resultaten-delen-pad-b` → `documenten-delen-notified-pull`; markdown-verwijzingen bijgewerkt |
| 0.0.4 | 2026-05-05 | Direct ophalen via de Koppeltaal FHIR store bevestigd als voorkeursroute na kritische review; inline base64-attachment toegevoegd als variant zodat leveranciers met simpele documenten geen eigen Binary-endpoint hoeven aan te bieden; het alternatief "Binary als losse resource in de Koppeltaal-store" teruggeschaald tot overwogen optie; sectie "Open punten" toegevoegd |
| 0.0.5 | 2026-05-05 | Notified Pull eveneens teruggeschaald tot overwogen alternatief; beide alternatieven samengevoegd onder één kopje "Overwogen alternatieven"; direct ophalen via de Koppeltaal-store is daarmee de enige aangewezen route |
| 0.0.8 | 2026-05-06 | "vragenlijst-uitkomsten" expliciet aangeduid als "ongestructureerde vragenlijst-uitkomsten" om discussie over structured/unstructured scope op deze pagina te voorkomen |
| 0.0.9 | 2026-05-06 | Token-flow bij externe referentie expliciet beschreven (tekst + sequence-diagram): EPD haalt access_token op bij de Koppeltaal authorization server; bronapplicatie valideert het token via `/introspect` (RFC 7662) bij dezelfde authorization server |
| 0.0.10 | 2026-05-18 | Open punten aangescherpt: keuze voor hergebruik van de DocumentReference-scope vastgelegd als token-validatieregel aan de bron (overwogen alternatieven — aparte Binary-scope, scope-parameter op `/introspect` — verworpen); beveiligingseisen voor het Binary-endpoint opgesplitst in **harde eisen** (TLS, token-validatie) en **zachte aanbevelingen** (niet-raadbare paden, rate-limiting/hardening); eis voor maximale URL-levensduur geschrapt |
| 0.0.11 | 2026-05-18 | Sectie "Bewaartermijn DocumentReference" toegevoegd: DocumentReference wordt in principe beperkt bewaard in de Koppeltaal-store, standaard 30 dagen; rationale en consequenties voor EPD en bronapplicatie beschreven |
| 0.0.12 | 2026-05-18 | Sectie "Verplichte velden" toegevoegd onder DocumentReference en Binary: `subject` (Patient), `context.related` (Task) en `date` zijn verplicht binnen Koppeltaal |
| 0.0.13 | 2026-05-18 | Sectie "Verplichte velden" geherformuleerd als **voorstel** tot aanpassing aan het (nog te creëren) Koppeltaal DocumentReference-profiel; geëxpliciteerd dat de regels pas afdwingbaar worden zodra het profiel in `input/fsh` is uitgewerkt |
| 0.0.14 | 2026-05-18 | Afwijzing van het alternatief "Uitbreiding van `/introspect` met een scope-parameter" aangescherpt: de optie valt af omdat RFC 7662 `/introspect` strikt definieert als token-introspectie zonder request-parameters voor per-resource autorisatiebeslissingen; een policy-decision-point hoort, indien nodig, in een aparte voorziening (UMA/PDP), niet in `/introspect` |
| 0.0.15 | 2026-05-19 | Verwijzing naar **TOP-KT-008 — Beveiliging aspecten** toegevoegd onder "Beveiligingseisen voor het Binary-endpoint van de bron": de generieke Koppeltaal-beveiligingseisen (HTTPS-only, JWT-algoritmes, security headers, CORS, input-validatie) gelden onverkort voor het Binary-endpoint; de eisen op deze pagina zijn aanvullend en specifiek voor de externe URL-variant |
| 0.0.16 | 2026-06-01 | Inline base64-variant (`attachment.data`) verwijderd — alleen externe URL met Binary-endpoint bij de bron blijft over. DocumentReference-profielvoorstel uitgebreid met verplicht `type` (1..1) en optioneel `category` (0..*). Autorisatie-sectie verwijst naar SMART v2 scopes-met-query (toekomstige filtering op `type`). Nieuw expliciet principe: bronapplicatie MAY na introspect alsnog toegang weigeren (data-owner verification). Audit-logging-sectie ingekort en doorverwezen naar TOP-KT-011. Beveiligingseisen-sectie gepromoveerd van "open punt" naar reguliere sectie. 30-dagen-bewaartermijnzin verplaatst naar de juiste sectie. Confluence-input-placeholder toegevoegd in Status. |

---

### Documenten delen

De inzet van eHealth en blended care is breed ingebed in de zorg. Digitale interventies leveren waardevolle documenten op — zoals rapportages, ongestructureerde vragenlijst-uitkomsten en voortgangsverslagen — die essentieel zijn voor goede behandelbeslissingen. In de praktijk zijn deze documenten echter vaak opgesloten binnen afzonderlijke applicaties, wat leidt tot informatieversnippering en extra administratieve lasten.

Door documenten delen expliciet te ondersteunen binnen Koppeltaal ontstaat een uniforme en gestandaardiseerde manier om documenten uit interventies veilig en geautoriseerd over te dragen van de bronapplicatie (module) naar de dossierhouder (EPD). Hierbij wordt aangesloten op bestaande MedMij- en Nictiz-standaarden. Koppeltaal fungeert als orkestratie-, transport- en autorisatielaag — niet als opslagsysteem.

### DocumentReference en Binary

Documenten zoals PDF/A-rapporten, ongestructureerde vragenlijst-uitkomsten of samenvattingen worden uitgewisseld via het FHIR [DocumentReference](https://www.hl7.org/fhir/documentreference.html) resource. Een DocumentReference bevat metadata over het document (type, datum, auteur, patiënt) en de inhoud zelf — via [`DocumentReference.content.attachment`](https://www.hl7.org/fhir/datatypes.html#Attachment).

De inhoud wordt uitgewisseld via één variant: **externe referentie**. `attachment.url` verwijst naar een [Binary](https://www.hl7.org/fhir/binary.html) resource bij de bronapplicatie, die hiervoor een beveiligd HTTP-endpoint aanbiedt. De data blijft daarmee aan de bron; de Koppeltaal FHIR store bevat alleen de metadata in de DocumentReference. Inline base64 (`attachment.data`) wordt binnen Koppeltaal niet ondersteund — zie [Changelog](#changelog) `0.0.16` voor de afweging.

De module genereert automatisch een PDF/A bij afronding van de interventie. PDF/A is het vereiste formaat voor duurzame archivering in het EPD.

#### Voorstel: aanpassingen aan het DocumentReference-profiel

Op dit moment kent Koppeltaal nog geen eigen DocumentReference-profiel. De volgende **aanpassingen worden voorgesteld** ten opzichte van het standaard FHIR R4 [DocumentReference](https://www.hl7.org/fhir/documentreference.html)-resource, zodat de in deze pagina beschreven uitwisseling betrouwbaar afdwingbaar wordt. De definitieve invulling — inclusief cardinaliteit, target-profielen en bindingen — wordt in een Koppeltaal-DocumentReference-profiel (FSH) vastgelegd na afstemming met leveranciers.

Voorgestelde aanvullende verplichtingen ten opzichte van de FHIR-basis:

- **`subject`** — voorgesteld als verplicht (`1..1`), met als target-profiel het Koppeltaal Patient-profiel. Zonder `subject` is het document niet routeerbaar naar het juiste dossier.
- **`context.related`** — voorgesteld als verplicht (minimaal `1..*`), met een verwijzing naar de [Task](https://www.hl7.org/fhir/task.html) die de interventie representeert waaruit het document is voortgekomen. Hiermee blijft het document traceerbaar naar de specifieke behandelopdracht en kan het EPD het document in de juiste context plaatsen. Te bepalen: of een slice op `context.related` nodig is om de Task-referentie expliciet aan te wijzen (versus andere related resources).
- **`date`** — voorgesteld als verplicht (`1..1`). Het tijdstip waarop de DocumentReference is aangemaakt door de module. Dit is het ankerpunt voor onder andere de [bewaartermijn](#bewaartermijn-documentreference) in de Koppeltaal-store en voor archiveringslogica in het EPD.
- **`type`** — voorgesteld als verplicht (`1..1`). Ontvangers (dossierhouders) moeten direct kunnen zien wat voor soort document binnenkomt — rapportage, ongestructureerde vragenlijst-uitkomst, voortgangsverslag, etc. — zonder de Binary te hoeven openen. De binding/ValueSet (LOINC via [valueset-c80-doc-typecodes](https://www.hl7.org/fhir/valueset-c80-doc-typecodes.html) of een Koppeltaal-specifieke ValueSet) wordt nog uitgewerkt; zie [Open punten](#open-punten).
- **`category`** — voorgesteld als optioneel (`0..*`). Leveranciers MOGEN categorieën meegeven (bv. om type-codes op een hoger niveau te groeperen), maar het is geen eis.

Dit zijn voorstellen, geen vastgestelde profielregels. Na consensus volgt de uitwerking in een DocumentReference-profiel in `input/fsh`, met bijbehorende validatie via de IG-publisher. Pas vanaf dat moment kunnen niet-conformante resources op deze regels worden afgewezen.

### Uitwisselingspatronen

Voor het overdragen van documenten van de module naar het EPD geldt **direct ophalen via de Koppeltaal FHIR store** als aangewezen route. Twee andere patronen — Notified Pull en Binary als losse resource in de Koppeltaal-store — zijn overwogen, maar niet aangewezen als standaardroute; zie [Overwogen alternatieven](#overwogen-alternatieven).

#### Direct ophalen via de Koppeltaal FHIR store

In dit patroon publiceert de module een DocumentReference in de Koppeltaal FHIR store. Het EPD detecteert de nieuwe DocumentReference — via polling of een FHIR Subscription — en haalt vervolgens de inhoud op via de externe referentie (`attachment.url`): het EPD haalt eerst een `access_token` op bij de Koppeltaal authorization server en doet daarmee een `GET` naar de Binary-URL bij de bronapplicatie (token als `Authorization: Bearer …`). De bronapplicatie valideert het token door het te introspecten bij dezelfde authorization server ([RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662) `/introspect`); pas na een geldige respons (`active: true` plus passende scopes) wordt het document geleverd. Autorisatie blijft daarmee centraal bij Koppeltaal — de bronapplicatie hoeft geen eigen vertrouwensmodel te onderhouden (zie ook [Open punten](#open-punten)).

<div style="clear: both; margin: 1em 0;">
{% include documenten-delen-direct-ophalen.svg %}
</div>

Dit patroon kent de minste orkestratie — er is geen aparte Notification Task — en houdt de **data aan de bron**: de fysieke controle over het bestand blijft bij de bronhouder, terwijl de DocumentReference — en daarmee alle metadata, autorisatie en signalering — in de Koppeltaal FHIR store blijft.

Het EPD detecteert nieuwe DocumentReferences via polling of een FHIR Subscription op de Koppeltaal-store.

#### Overwogen alternatieven

Tijdens de uitwerking zijn twee andere patronen overwogen — **Notified Pull** en **Binary als losse resource in de Koppeltaal-store**. Beide zijn niet als standaardroute aangewezen; ze worden hier kort gedocumenteerd zodat de afweging traceerbaar blijft en het onderwerp opnieuw opgepakt kan worden mocht de scope van Koppeltaal in de toekomst veranderen.

##### Notified Pull

In dit patroon — gebaseerd op de [TA Notified Pull v1.0.1](https://www.nictiz.nl/) — neemt de module het initiatief door het EPD actief te notificeren via een Notification Task. De Notification Task bevat verwijzingen naar de op te halen FHIR resources; het EPD haalt op eigen initiatief en tempo de data op bij de bron.

<div style="clear: both; margin: 1em 0;">
{% include documenten-delen-notified-pull.svg %}
</div>

Notified Pull is aantrekkelijk door de aansluiting op de door Nictiz beheerde TA Notified Pull-standaard (publieke standaard, **netwerkzorg**) en omdat het EPD geen polling of eigen Subscription hoeft in te richten. In de huidige Koppeltaal-scope — interventies binnen een al bekend behandelnetwerk waarin het EPD al synchroniseert via de Koppeltaal-store — voegt de Notification Task echter een extra orkestratielaag toe terwijl detectie via Subscription/polling op de Koppeltaal-store volstaat. De keuze is daarom op direct ophalen gevallen.

Mocht netwerkzorg- of cross-organisatie-uitwisseling later expliciet in scope komen, dan kan Notified Pull alsnog als optionele aanvulling worden gespecificeerd. De twee patronen sluiten elkaar niet uit.

##### Binary als losse resource in de Koppeltaal-store

In een eerder ontwerp is dit alternatief overwogen: de Binary niet bij de bronapplicatie laten staan, maar als losse resource — naast de DocumentReference — in de Koppeltaal FHIR store plaatsen. Argument was onder meer centrale token-validatie, automatische AuditEvents en geen eigen resource-server bij de bronapplicatie.

Bij nadere beschouwing bleken een aantal van die voordelen niet onderscheidend ten opzichte van direct ophalen, en wegen er zwaarwegende bezwaren tegen op:

- **Dataminimalisatie en bronverantwoordelijkheid**: gevoelige gezondheidsdata buiten de bronhouder plaatsen vergroot het aanvalsoppervlak en ondermijnt het principe dat de bronhouder verantwoordelijk blijft voor zijn data tijdens de uitwisseling.
- **Verlies van het pull-signaal**: bij direct ophalen weet de bronhouder wanneer en door wie het document is opgehaald — een nuttig signaal voor archiveringsstatus, bewaartermijnen en eigen audit. Bij dit alternatief verdwijnt dat signaal.

Dit alternatief blijft denkbaar als uitwijkmogelijkheid voor specifieke gevallen (bijvoorbeeld een bron die geen stabiel publiek endpoint kan aanbieden), maar is geen standaardroute van de Koppeltaal-specificatie.

### Workflow

Documenten delen is het sluitstuk van de bestaande Koppeltaal Task lifecycle:

1. De behandelaar wijst een interventie toe aan de patiënt (Task wordt aangemaakt)
2. De patiënt voert de interventie uit via de module
3. De interventie wordt afgerond (Task.status → `completed`)
4. De module genereert het document (PDF/A)
5. De module publiceert een DocumentReference in de Koppeltaal FHIR store
6. Het EPD haalt het document op en archiveert het in het patiëntdossier

De DocumentReference wordt gekoppeld aan zowel de Patient als de Task, zodat het document traceerbaar is naar de specifieke interventie.

### Autorisatie

Toegang tot documenten is gebonden aan de behandelrelatie:

- **Zorgverleners**: alleen zorgverleners met een geldige behandelrelatie — vastgelegd in het CareTeam — krijgen toegang tot documenten
- **RelatedPerson**: personen betrokken bij de behandeling (ouders, mantelzorgers, wettelijk vertegenwoordigers) kunnen beperkte, doelgebonden en tijdgebonden inzage krijgen in documenten. Toegang vervalt automatisch bij het eindigen van de relatie, het intrekken van toestemming of het afsluiten van de behandeling
- **Logging**: alle inzage en overdracht van documenten wordt gelogd en is auditeerbaar

Het Koppeltaal-scope-model is gebaseerd op SMART on FHIR v2 scopes met query-parameters (zie [autorisaties.html](./autorisaties.html) en TOP-KT-016). Het patroon `system/Resource.[crud]?param=value` — al toegepast voor `resource-origin` — maakt het mogelijk om in een toekomstige iteratie filtering op bijvoorbeeld `DocumentReference.type` te ondersteunen. De concrete scope-syntax voor DocumentReference wordt vastgelegd in de Koppeltaal-autorisatiematrix; zie [Open punten](#open-punten).

### Bewaartermijn DocumentReference

De DocumentReference wordt in principe **beperkt bewaard** in de Koppeltaal FHIR store. De standaardtermijn is **30 dagen** vanaf publicatie; daarna wordt de resource opgeruimd via het reguliere [opschoningsproces voor Patient-data](./opschoning-patient-data.html) van Koppeltaal.

Deze termijn weerspiegelt de rol van Koppeltaal als orkestratie- en transportlaag, niet als langetermijn-archief: zodra het document is opgehaald en gearchiveerd in het EPD-dossier, is de DocumentReference in de Koppeltaal-store overbodig. Een korte termijn beperkt het aanvalsoppervlak, voorkomt dat de Koppeltaal-store de facto een tweede dossierstore wordt, en sluit aan op het principe dat de bronhouder verantwoordelijk blijft voor de inhoud.

Consequenties:

- **Het EPD** moet de DocumentReference binnen de bewaartermijn detecteren (polling of Subscription) en de inhoud ophalen of archiveren. Documenten die na 30 dagen nog niet zijn opgehaald, worden niet langer aangeboden via de Koppeltaal-store.
- **De bronapplicatie** behoudt — bij de variant met externe URL — de Binary in haar eigen omgeving, onafhankelijk van de Koppeltaal-bewaartermijn. De levenscyclus van het brondocument volgt het beleid van de bronhouder.
- **Afwijken van de standaard** (langer of korter dan 30 dagen) is in specifieke gebruiksscenario's mogelijk, maar moet expliciet worden vastgelegd in het leveranciersprofiel of een aanvullende afspraak. Of, en op welk niveau, individuele afwijkingen mogelijk worden gemaakt is nog uit te werken (zie [Open punten](#open-punten)).

### Beveiligingseisen voor het Binary-endpoint van de bron

Om fragmentatie en ongelijke beveiligingsniveaus te voorkomen publiceert Koppeltaal een set eisen voor het Binary-endpoint dat een bronapplicatie aanbiedt. De eisen worden gesplitst in **harde eisen** (verplicht; conformance-criterium) en **zachte aanbevelingen** (best practice; sterk aangeraden maar niet afdwingbaar).

De generieke Koppeltaal-beveiligingseisen uit TOP-KT-008 — Beveiliging aspecten (onder andere: HTTPS-only, JWT-handtekening met asymmetrische algoritmes, security headers zoals Cache-Control: no-store, Strict-Transport-Security, X-Content-Type-Options: nosniff en expliciete Content-Type, restrictieve CORS, input-validatie) gelden onverkort ook voor het Binary-endpoint. De eisen hieronder zijn **aanvullend** en specifiek voor het Binary-endpoint van de bronapplicatie.

**Hard — verplicht:**

- **TLS-only** (minimaal TLS 1.2, geen klare HTTP)
- **Verplichte token-validatie** (zie [Token-validatie en data-owner-verificatie](#token-validatie-en-data-owner-verificatie)), inclusief afwijzing van requests zonder geldig access_token

**Zacht — aanbevolen:**

- Niet-raadbare paden voor Binary-resources (bijvoorbeeld UUID's of cryptografisch random identifiers; geen incrementele IDs)
- Rate-limiting en standaard hardening (security headers, beperkte error-detail bij 401/403)

Voor toekomstige fijngranulariteit (bijvoorbeeld filtering op `DocumentReference.type`) ligt de richting bij **SMART on FHIR v2 scopes-met-query** — het patroon dat Koppeltaal al toepast voor `resource-origin`. De concrete uitwerking volgt in de Koppeltaal-autorisatiematrix; zie [Concrete scope-syntax voor DocumentReference in de autorisatiematrix](#concrete-scope-syntax-voor-documentreference-in-de-autorisatiematrix) onder Open punten.

### Audit-logging bij de bron

De Binary-read loopt niet via Koppeltaal; de **bronapplicatie is verantwoordelijk voor de audit-registratie** van wie/wanneer/welk document. Detail-eisen, AuditEvent-structuur en eventuele uitwisseling met een centrale Koppeltaal-AuditEvent-store worden behandeld in [change-management-topic-11-implementation-feedback.html](./change-management-topic-11-implementation-feedback.html).

### Open punten

De volgende punten zijn nog uit te werken in samenwerking met leveranciers:

#### Token-validatie en data-owner-verificatie

Wanneer het EPD een externe Binary-URL aanroept, ontvangt de bronapplicatie een `GET`-request met een Koppeltaal-uitgegeven access_token. De bronapplicatie introspecteert het token bij de Koppeltaal authorization server ([RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662) `/introspect`; zie ook **TOP-KT-021 — Token introspection**) en krijgt een set scopes terug. **De regel is**: de scope die het EPD nodig heeft om de DocumentReference te lezen geldt ook als toestemming om de bijbehorende Binary op te halen. Dezelfde permissie dekt zowel metadata als inhoud.

**Data-owner verification** — een succesvolle introspect (`active: true` plus passende scopes) is een **noodzakelijke maar geen voldoende voorwaarde** voor levering. De bronapplicatie MAY na een geldige introspect alsnog toegang weigeren of intrekken op basis van eigen beleid (bijvoorbeeld ingetrokken patiënt-toestemming, bron-specifieke regels, vermoeden van misbruik). In dat geval reageert de bron met `403 Forbidden` en logt de afwijzing zelf (zie [Audit-logging bij de bron](#audit-logging-bij-de-bron)).

Twee alternatieven zijn overwogen en niet gekozen:

- **Een nieuwe, expliciete Binary-scope** (bijvoorbeeld `documenten/Binary.read`): zou Binary-toegang loskoppelen van DocumentReference-toegang. Verworpen omdat het een onduidelijke status institutionaliseert (wel toegang tot de reference, niet tot de data) zonder een gebruiksscenario dat dat onderscheid nodig maakt.
- **Uitbreiding van het introspect-endpoint met een scope-parameter** (de bron vraagt aan Koppeltaal "mag deze client deze Binary ophalen?"): valt af. [RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662) definieert `/introspect` strikt als token-introspectie en kent geen request-parameters voor een per-resource autorisatiebeslissing. Een policy-decision-point hoort, indien ooit nodig, in een aparte voorziening (UMA-/PDP-pattern), niet in `/introspect`.

#### ValueSet/binding voor `DocumentReference.type`

Welke codes mogen leveranciers gebruiken voor `type`? Opties: LOINC ([valueset-c80-doc-typecodes](https://www.hl7.org/fhir/valueset-c80-doc-typecodes.html), de FHIR R4-default), een Koppeltaal-specifieke ValueSet voor ongestructureerde behandeluitkomsten, of een gelaagde aanpak (LOINC als basis met aanvullende Koppeltaal-codes). Te bepalen samen met leveranciers en op te nemen in het toekomstige `KT2_DocumentReference`-profiel.

#### Concrete scope-syntax voor DocumentReference in de autorisatiematrix

Het SMART v2 scopes-met-query-patroon (`system/DocumentReference.read?type=…`) moet worden uitgewerkt voor DocumentReference: welke parameters worden ondersteund, welke combinaties, en hoe verhouden filter-scopes zich tot de generieke `DocumentReference.read`. Op te nemen in [autorisaties.html](./autorisaties.html) (of een sibling-pagina) zodra de eerste consument hier behoefte aan heeft.

### Status

Aanvullende inhoudelijke uitwerking volgt uit een door de Technical Community aangeleverde Confluence-documentatie (TC, juni 2026); deze pagina wordt aangevuld zodra die input beschikbaar is.

Deze pagina beschrijft de oplossingsrichting op hoog niveau. De exacte invulling van profielen, uitwisselingspatronen en autorisatieregels wordt in samenwerking met leveranciers bepaald.
