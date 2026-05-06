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

---

### Documenten delen

De inzet van eHealth en blended care is breed ingebed in de zorg. Digitale interventies leveren waardevolle documenten op — zoals rapportages, ongestructureerde vragenlijst-uitkomsten en voortgangsverslagen — die essentieel zijn voor goede behandelbeslissingen. In de praktijk zijn deze documenten echter vaak opgesloten binnen afzonderlijke applicaties, wat leidt tot informatieversnippering en extra administratieve lasten.

Door documenten delen expliciet te ondersteunen binnen Koppeltaal ontstaat een uniforme en gestandaardiseerde manier om documenten uit interventies veilig en geautoriseerd over te dragen van de bronapplicatie (module) naar de dossierhouder (EPD). Hierbij wordt aangesloten op bestaande MedMij- en Nictiz-standaarden. Koppeltaal fungeert als orkestratie-, transport- en autorisatielaag — niet als opslagsysteem.

### DocumentReference en Binary

Documenten zoals PDF/A-rapporten, ongestructureerde vragenlijst-uitkomsten of samenvattingen worden uitgewisseld via het FHIR [DocumentReference](https://www.hl7.org/fhir/documentreference.html) resource. Een DocumentReference bevat metadata over het document (type, datum, auteur, patiënt) en de inhoud zelf — via [`DocumentReference.content.attachment`](https://www.hl7.org/fhir/datatypes.html#Attachment).

Voor de inhoud zijn twee varianten toegestaan:

- **Externe referentie**: `attachment.url` verwijst naar een [Binary](https://www.hl7.org/fhir/binary.html) resource bij de bronapplicatie. Geschikt voor grotere bestanden en voor leveranciers die controle over het bestand willen behouden (data aan de bron). De bronapplicatie biedt hiervoor een beveiligd HTTP-endpoint aan.
- **Inline base64**: `attachment.data` bevat het document zelf, base64-gecodeerd, in de DocumentReference. Geschikt voor kleinere documenten met een beperkt gevoeligheidsniveau, waarbij de leverancier geen eigen endpoint wil onderhouden. Het document wordt dan automatisch meegeleverd via de Koppeltaal FHIR store, zonder aanvullende infrastructuur aan de bron.

De keuze tussen externe referentie en inline base64 is een afweging van de leverancier tussen complexiteit (eigen Binary-endpoint), bestandsgrootte en gevoeligheidsniveau. Beide varianten gebruiken hetzelfde uitwisselingspatroon (zie [Uitwisselingspatronen](#uitwisselingspatronen)) en hetzelfde Koppeltaal autorisatiemodel.

De module genereert automatisch een PDF/A bij afronding van de interventie. PDF/A is het vereiste formaat voor duurzame archivering in het EPD.

### Uitwisselingspatronen

Voor het overdragen van documenten van de module naar het EPD geldt **direct ophalen via de Koppeltaal FHIR store** als aangewezen route. Twee andere patronen — Notified Pull en Binary als losse resource in de Koppeltaal-store — zijn overwogen, maar niet aangewezen als standaardroute; zie [Overwogen alternatieven](#overwogen-alternatieven).

#### Direct ophalen via de Koppeltaal FHIR store

In dit patroon publiceert de module een DocumentReference in de Koppeltaal FHIR store. Het EPD detecteert de nieuwe DocumentReference — via polling of een FHIR Subscription — en haalt vervolgens de inhoud op:

- bij een **externe referentie** (`attachment.url`): het EPD haalt eerst een `access_token` op bij de Koppeltaal authorization server en doet daarmee een `GET` naar de Binary-URL bij de bronapplicatie (token als `Authorization: Bearer …`). De bronapplicatie valideert het token door het te introspecten bij dezelfde authorization server ([RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662) `/introspect`); pas na een geldige respons (`active: true` plus passende scopes) wordt het document geleverd. Autorisatie blijft daarmee centraal bij Koppeltaal — de bronapplicatie hoeft geen eigen vertrouwensmodel te onderhouden (zie ook [Open punten](#open-punten)).
- bij **inline base64** (`attachment.data`): het document is al meegekomen met de DocumentReference uit de Koppeltaal-store; er is geen tweede pull nodig.

<div style="clear: both; margin: 1em 0;">
{% include documenten-delen-direct-ophalen.svg %}
</div>

Dit patroon kent de minste orkestratie — er is geen aparte Notification Task — en biedt de leverancier de keuze tussen *data aan de bron* (externe URL, geschikt voor grote of zeer gevoelige bestanden) of *minimale infrastructuur* (inline base64, geschikt voor kleinere documenten waar het opzetten van een eigen Binary-endpoint niet loont). In beide gevallen blijft de DocumentReference — en daarmee alle metadata, autorisatie en signalering — in de Koppeltaal FHIR store.

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
- **De inline base64-variant lost het FHIR-endpoint-bezwaar al op**: leveranciers die geen eigen Binary-endpoint willen onderhouden kunnen via `attachment.data` (inline) volstaan, zonder dat de bron de fysieke controle over het bestand verliest aan een tussenpartij.

Dit alternatief blijft denkbaar als uitwijkmogelijkheid voor specifieke gevallen (bijvoorbeeld een bron die geen stabiel publiek endpoint kan aanbieden én waar inline base64 niet volstaat), maar is geen standaardroute van de Koppeltaal-specificatie.

### Workflow

Documenten delen is het sluitstuk van de bestaande Koppeltaal Task lifecycle:

1. De behandelaar wijst een interventie toe aan de patiënt (Task wordt aangemaakt)
2. De patiënt voert de interventie uit via de module
3. De interventie wordt afgerond (Task.status → `completed`)
4. De module genereert het document (PDF/A)
5. De module publiceert een DocumentReference in de Koppeltaal FHIR store (met externe URL of inline base64)
6. Het EPD haalt het document op en archiveert het in het patiëntdossier

De DocumentReference wordt gekoppeld aan zowel de Patient als de Task, zodat het document traceerbaar is naar de specifieke interventie.

### Autorisatie

Toegang tot documenten is gebonden aan de behandelrelatie:

- **Zorgverleners**: alleen zorgverleners met een geldige behandelrelatie — vastgelegd in het CareTeam — krijgen toegang tot documenten
- **RelatedPerson**: personen betrokken bij de behandeling (ouders, mantelzorgers, wettelijk vertegenwoordigers) kunnen beperkte, doelgebonden en tijdgebonden inzage krijgen in documenten. Toegang vervalt automatisch bij het eindigen van de relatie, het intrekken van toestemming of het afsluiten van de behandeling
- **Logging**: alle inzage en overdracht van documenten wordt gelogd en is auditeerbaar

### Open punten

Met de keuze voor direct ophalen via de Koppeltaal-store (externe URL of inline base64) als aangewezen route zijn de volgende punten nog uit te werken in samenwerking met leveranciers:

#### Token-validatie aan de bronapplicatie (variant met externe URL)

Wanneer de leverancier kiest voor een externe Binary-URL, ontvangt de bronapplicatie een `GET`-request met een Koppeltaal-uitgegeven access_token. Het token is gevalideerd (handtekening, expiry) en levert een set scopes op. **Open is wat de bron precies controleert** voordat zij de Binary uitlevert. Drie richtingen worden overwogen:

1. **Hergebruik van de DocumentReference-scope**: de scope die nodig is om de DocumentReference te lezen geldt ook als toestemming om de bijbehorende Binary op te halen. Pragmatisch en goed uitlegbaar — dezelfde permissie geeft toegang tot zowel metadata als inhoud — maar fijngranulariteit ontbreekt (alles-of-niets per type document).
2. **Een nieuwe, expliciete Binary-scope**: een aparte scope (bijvoorbeeld `documenten/Binary.read`) die specifiek voor het ophalen van documenten dient. Maakt het mogelijk om Binary-toegang los te koppelen van DocumentReference-toegang, ten koste van extra scope-management.
3. **Uitbreiding van het introspect-endpoint met een scope-parameter**: de bron stuurt het token plus een gewenste actie/scope ("mag deze client deze Binary ophalen?") naar het Koppeltaal-`/introspect`-endpoint, en krijgt een eenduidig ja/nee terug. Houdt de autorisatielogica centraal bij Koppeltaal in plaats van bij elke leverancier — kan ook gecombineerd worden met optie 1 of 2.

De keuze raakt zowel de Koppeltaal-specificatie (welke scopes worden uitgegeven, hoe gedraagt `/introspect` zich) als de leverancier-implementaties.

#### Beveiligingseisen voor het Binary-endpoint van de bron

Om fragmentatie en ongelijke beveiligingsniveaus te voorkomen wordt voorgesteld dat Koppeltaal een **handvest / set minimumeisen** publiceert voor het Binary-endpoint dat een bronapplicatie aanbiedt. Te denken valt aan:

- TLS-only (minimaal TLS 1.2, geen klare HTTP)
- Niet-raadbare paden voor Binary-resources (bijvoorbeeld UUID's of cryptografisch random identifiers; geen incrementele IDs)
- Verplichte token-validatie (zie hierboven), inclusief afwijzing van requests zonder geldig access_token
- Rate-limiting en standaard hardening (security headers, beperkte error-detail bij 401/403)
- Een gedefinieerde maximale levensduur van geldige URLs (om "lekken" van URL's te beperken)

Dit handvest is een **specificatie-eis aan leveranciers** die voor de externe URL-variant kiezen; voor de inline base64-variant zijn deze eisen niet van toepassing omdat het document via de Koppeltaal-store geleverd wordt.

#### Audit-logging bij de bron

Bij het alternatief "Binary als losse resource in de Koppeltaal-store" zou de Koppeltaal-store automatisch AuditEvents genereren bij elke read. In het gekozen patroon loopt de Binary-read niet via Koppeltaal en kent Koppeltaal die actie dus niet. **De audit-verantwoordelijkheid voor de Binary-read ligt daarmee bij de bronapplicatie**: zij logt zelf wie, wanneer, welk document heeft opgehaald. Optioneel kan dit als AuditEvent worden teruggeschreven naar een centrale Koppeltaal-AuditEvent-store, maar dat is een implementatie- en governance-keuze, geen architectuurbeslissing.

Voor de inline base64-variant en voor DocumentReference-reads zelf blijft het bestaande Koppeltaal-mechanisme (automatische AuditEvent bij search/read op de Koppeltaal-store) leidend.

#### Voorwaarden voor inline base64

De keuze om de inhoud inline mee te leveren (`attachment.data`) is in principe vrij aan de leverancier, maar mogelijk willen we dit specificatie-zijdig **inkaderen** — bijvoorbeeld:

- Een maximale bestandsgrootte (om de Koppeltaal-store niet als algemeen blob-store te gebruiken)
- Beperkingen op categorieën documenten (bijvoorbeeld: zeer gevoelige documenten verplicht via externe URL met inzage-signaal aan de bron)
- Verplichte expliciete keuze in een leveranciersprofiel (zodat dossierhouders weten wat ze kunnen verwachten)

Of we deze voorwaarden willen vastleggen — en zo ja, op welk niveau (specificatie, conformance-statement, of vrij aan partijen) — is nog open.

### Status

Deze pagina beschrijft de oplossingsrichting op hoog niveau. De exacte invulling van profielen, uitwisselingspatronen en autorisatieregels wordt in samenwerking met leveranciers bepaald.
