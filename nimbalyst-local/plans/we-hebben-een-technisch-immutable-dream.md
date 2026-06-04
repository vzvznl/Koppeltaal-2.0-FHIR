# Documenten delen — verwerking technisch overleg

## Context

Naar aanleiding van een technisch overleg over `input/pagecontent/documenten-delen.md` zijn de volgende beslissingen genomen die de huidige pagina (v0.0.15) op meerdere punten herziet:

1. **Geen "binary blob" meer**: inline base64 (`attachment.data`) vervalt als variant. Alleen de externe URL met een Binary-endpoint bij de bronapplicatie blijft over. Strikte "data aan de bron".
2. **DocumentReference-profielvoorstel uitbreiden**: `type` (1..1) verplicht (TC-wens om te weten waar het document over gaat), `category` (0..*) optioneel. `subject`, `context.related`, `date` blijven verplicht.
3. **SMART on FHIR scopes met query**: het scope-model verschuift naar SMART v2 scopes-met-query (Koppeltaal gebruikt dit al voor `resource-origin`). Daardoor wordt filteren op `type` in de toekomst mogelijk. Concrete scope-syntax voor `DocumentReference` komt later — verwijzing naar `autorisaties.md` / TOP-KT-016.
4. **Data-owner verification**: introspect-OK is een *noodzakelijke* maar geen *voldoende* voorwaarde. De bronapplicatie MAY na een succesvolle introspect alsnog toegang weigeren of intrekken op basis van eigen beleid (bv. ingetrokken toestemming, bron-specifieke regels).
5. **Logging & tracing is een apart onderwerp**: detail-eisen en AuditEvent-uitwisseling verhuizen naar TOP-KT-011. Op deze pagina blijft één korte alinea over wie verantwoordelijk is voor audit aan de bron.
6. **Confluence-documentatie**: TC heeft Confluence-input die nog komt — placeholder in de Status-sectie zodat de pagina later met die input kan worden gevuld.

Daarnaast zit er een **tekst-corruptie** in de huidige pagina: de definitiezin van de 30-dagen-bewaartermijn (regel 148) staat in de verkeerde sectie (binnen Token-validatie i.p.v. onder *Bewaartermijn DocumentReference*). Dit wordt meegenomen.

## Scope

- **Wel** in scope: documentwijzigingen aan `input/pagecontent/documenten-delen.md` + bijwerken van het PlantUML-diagram `input/images-source/documenten-delen-direct-ophalen.plantuml`.
- **Niet** in scope: FSH-profielwijzigingen (een KT2_DocumentReference-profiel komt pas na consensus met leveranciers — blijft "voorstel"-status op de pagina). Geen wijzigingen aan `sushi-config.yaml`, `package.json`, `CHANGELOG.md` of `input/pagecontent/changes.md` (die zijn voor FSH-wijzigingen). Alleen de page-level changelog binnen het bestand wordt bijgewerkt.

## Bestanden

| Pad | Wijziging |
| --- | --- |
| `input/pagecontent/documenten-delen.md` | Inhoudelijke herziening + nieuwe changelog-regel `0.0.16` (datum 2026-06-01). |
| `input/images-source/documenten-delen-direct-ophalen.plantuml` | `alt/else`-blok verwijderen; alleen externe-URL-flow behouden; data-owner-policy-check als extra stap zichtbaar maken. PNG wordt automatisch door de Makefile gegenereerd — niet handmatig. |

## Wijzigingsdetail per sectie (`documenten-delen.md`)

### 1. Intro "DocumentReference en Binary" (≈ regel 29-40)
- Alinea "Voor de inhoud zijn twee varianten toegestaan" herschrijven naar één variant: externe referentie via `attachment.url` naar een Binary-resource bij de bron.
- Alinea "De keuze tussen externe referentie en inline base64..." verwijderen.
- PDF/A-zin (regel 40) behouden.

### 2. Voorstel: aanpassingen aan het DocumentReference-profiel (≈ regel 42-52)
Voeg twee bullets toe aan de bestaande lijst (subject, context.related, date blijven):
- **`type`** — voorgesteld als verplicht (`1..1`). TC-wens: ontvangers moeten direct kunnen zien wat voor soort document binnenkomt (rapportage, ongestructureerde vragenlijst-uitkomst, voortgangsverslag, etc.). De binding/ValueSet — LOINC ([valueset-c80-doc-typecodes](https://www.hl7.org/fhir/valueset-c80-doc-typecodes.html)) of een Koppeltaal-specifieke ValueSet — moet nog worden uitgewerkt; zie [Open punten](#open-punten).
- **`category`** — voorgesteld als optioneel (`0..*`). Leveranciers MOGEN categorieën meegeven (bv. om type-codes op een hoger niveau te groeperen), maar het is geen eis.

### 3. Uitwisselingspatronen (≈ regel 54-99)

#### 3a. "Direct ophalen via de Koppeltaal FHIR store"
- Tweede bullet (inline base64) verwijderen.
- Eerste bullet (externe referentie) houden en de zinsnede "biedt de leverancier de keuze tussen *data aan de bron* of *minimale infrastructuur*" herschrijven naar één route ("data aan de bron").

#### 3b. "Overwogen alternatieven"
- **Notified Pull** blijft (rationale netwerkzorg ongewijzigd).
- **Binary als losse resource in de Koppeltaal-store** blijft als afgewezen alternatief, maar de bullet "De inline base64-variant lost het FHIR-endpoint-bezwaar al op" verwijderen (geldt niet meer als argument).

### 4. Workflow (≈ regel 101-112)
Stap 5: "(met externe URL of inline base64)" verwijderen — alleen externe URL.

### 5. Autorisatie (≈ regel 114-120)
Sectie behouden, maar onder de bestaande bullets een nieuwe alinea toevoegen:

> Het Koppeltaal-scope-model is gebaseerd op SMART on FHIR v2 scopes met query-parameters (zie [autorisaties.html](./autorisaties.html) en TOP-KT-016). Het patroon `system/Resource.[crud]?param=value` — al toegepast voor `resource-origin` — maakt het mogelijk om in een toekomstige iteratie filtering op bijvoorbeeld `DocumentReference.type` te ondersteunen. De concrete scope-syntax voor DocumentReference wordt vastgelegd in de Koppeltaal-autorisatiematrix; zie [Open punten](#open-punten).

### 6. Bewaartermijn DocumentReference (regel 122-131 — corruptie fixen)
- De zin "De DocumentReference wordt in principe **beperkt bewaard** in de Koppeltaal FHIR store. De standaardtermijn is **30 dagen** vanaf publicatie; daarna wordt de resource opgeruimd via het reguliere [opschoning-patient-data.html](./opschoning-patient-data.html) van Koppeltaal." verplaatsen van regel 148 naar **bovenaan** deze sectie (vóór "Deze termijn weerspiegelt…").
- Bullet "respectievelijk dat de dossierhouder verantwoordelijk wordt na archivering (bij inline base64)" verwijderen.

### 7. Open punten — herstructureren (≈ regel 133-181)

**Verwijderen:**
- "Voorwaarden voor inline base64" — vervalt volledig (inline-variant bestaat niet meer).

**Inkrimpen / verplaatsen:**
- "Beveiligingseisen voor het Binary-endpoint van de bron" — promoveren van "open punt" naar reguliere sectie (de eisen zijn vastgesteld; niet langer open). Slotzin "voor de inline base64-variant zijn deze eisen niet van toepassing" verwijderen.
- "Audit-logging bij de bron" — inkorten tot één alinea: "Bij de externe URL-variant loopt de Binary-read niet via Koppeltaal; de **bronapplicatie is verantwoordelijk voor de audit-registratie** van wie/wanneer/welk document. Detail-eisen, AuditEvent-structuur en eventuele uitwisseling met een centrale Koppeltaal-AuditEvent-store worden behandeld in [change-management-topic-11-implementation-feedback.html](./change-management-topic-11-implementation-feedback.html)." (Inline base64 / "voor de inline base64-variant en voor DocumentReference-reads blijft het bestaande Koppeltaal-mechanisme" zin verwijderen.)

**Aanpassen:**
- "Token-validatie aan de bronapplicatie (variant met externe URL)" — kop hernoemen naar "Token-validatie en data-owner-verificatie" (suffix "(variant met externe URL)" vervalt — er is geen andere variant meer). Anchor-link in [Beveiligingseisen] sectie ook bijwerken. Inhoud:
  - Eerste alinea (introspect, scope geldt voor DocumentReference + bijhorende Binary) behouden.
  - **Nieuwe alinea toevoegen — data-owner verification**: de bronapplicatie MAY na een succesvolle introspect alsnog toegang weigeren of intrekken op basis van eigen beleid (bv. ingetrokken patiënt-toestemming, bron-specifieke regels, vermoeden van misbruik). Een succesvolle `/introspect` (`active: true` + passende scopes) is daarmee een **noodzakelijke maar geen voldoende voorwaarde** voor levering. In dat geval reageert de bron met `403 Forbidden` en logt de afwijzing zelf (zie audit-logging-alinea hierboven).
  - Alternatievenparagraaf (aparte Binary-scope, scope-parameter op /introspect) ingekort behouden — beide afgewezen blijven afgewezen. Toevoegen: naar SMART v2 scopes-met-query als de richting voor toekomstige fijngranulariteit (bv. filtering op `type`).

**Toevoegen — nieuw open punt:**
- "ValueSet/binding voor `DocumentReference.type`": welke codes mogen leveranciers gebruiken? LOINC (FHIR R4 default), een Koppeltaal-specifieke ValueSet voor ongestructureerde behandeluitkomsten, of een gelaagde aanpak? Te bepalen samen met leveranciers; volgt in het toekomstige `KT2_DocumentReference`-profiel.
- "Concrete scope-syntax voor DocumentReference in de autorisatiematrix": uitwerken in `autorisaties.md` (of een sibling-pagina) wanneer SMART v2 scopes-met-query op deze resource wordt ingevuld.

### 8. Status (laatste sectie)
Voeg één regel toe vóór de bestaande tekst:

> Aanvullende inhoudelijke uitwerking volgt uit een door de Technical Community aangeleverde Confluence-documentatie (TC, juni 2026); deze pagina wordt aangevuld zodra die input beschikbaar is.

### 9. Changelog
Nieuwe regel onderaan de tabel:

| 0.0.16 | 2026-06-01 | Inline base64-variant (`attachment.data`) verwijderd — alleen externe URL met Binary-endpoint bij de bron blijft over. DocumentReference-profielvoorstel uitgebreid met verplicht `type` (1..1) en optioneel `category` (0..*). Autorisatie-sectie verwijst naar SMART v2 scopes-met-query (toekomstige filtering op `type`). Nieuw expliciet principe: bronapplicatie MAY na introspect alsnog toegang weigeren (data-owner verification). Audit-logging-sectie ingekort en doorverwezen naar TOP-KT-011. Beveiligingseisen-sectie gepromoveerd van "open punt" naar reguliere sectie. 30-dagen-bewaartermijnzin verplaatst naar de juiste sectie. Confluence-input-placeholder toegevoegd in Status. |

## Wijzigingsdetail PlantUML (`documenten-delen-direct-ophalen.plantuml`)

Huidige diagram (regels 14-24) bevat een `alt/else` tussen *Externe referentie* en *Binary in de Koppeltaal-store*. Aanpassing:

- `alt … else Binary in de Koppeltaal-store … end` verwijderen; alleen de externe-URL-flow behouden (de inhoud van het huidige `alt`-tak: `EPD → Module GET Binary`, `Module → AS POST /introspect`, `AS → Module active+scopes`, `Module → EPD Binary response`).
- Tussen `AS → Module: active: true, scopes` en `Module → EPD: Binary response` een nieuwe self-note of stap zichtbaar maken: `note over Module: Data-owner policy check\n(MAY deny op eigen gronden)`.

PNG wordt automatisch door de Makefile gegenereerd; niet handmatig genereren.

## Hergebruik bestaande artefacten

- **`autorisaties.md`** — als referentie voor SMART v2 scopes-met-query patroon. Geen wijziging in deze plan, alleen vanuit `documenten-delen.md` naar verwijzen.
- **TOP-KT-011 (Logging en tracing)** — referentie via bestaande pagina `change-management-topic-11-implementation-feedback.md`; geen edit nodig.
- **TOP-KT-008 (Beveiliging aspecten)** — al gerefereerd in v0.0.15; blijft staan.
- **TOP-KT-021 (Token introspection)** — bestaat als topic; toevoegen als referentie in de Token-validatie-sectie (kort).
- **`opschoning-patient-data.html`** — al gerefereerd in v0.0.15 (bewaartermijn-context); blijft staan.

## Verificatie

1. **Build sanity-check via Docker** (volgens README "Run the builds"-sectie — nooit `sushi` of `publisher.jar` lokaal): IG publisher moet zonder fouten over `documenten-delen.md` heen lopen, en de PNG voor `documenten-delen-direct-ophalen.plantuml` moet opnieuw worden gegenereerd door de Makefile.
2. **Visuele review**: open de gegenereerde HTML-pagina en bevestig:
  - Geen verwijzingen meer naar "inline base64", "attachment.data", of "blob in de Koppeltaal-store" (m.u.v. de afgewezen-alternatief-sectie waar de history bewaard blijft).
  - DocumentReference profiel-voorstel bevat 5 bullets (subject, context.related, date, type, category).
  - Autorisatie-sectie verwijst naar SMART v2 scopes-met-query en `autorisaties.html`.
  - Token-validatie-sectie bevat een eigenstandige alinea over data-owner verification (MAY deny).
  - Audit-logging is teruggebracht tot één alinea met link naar TOP-KT-011.
  - Bewaartermijn-sectie heeft eerst de definitie (30 dagen), dan de rationale-alinea.
  - Changelog bevat 0.0.16-regel.
3. **Interne anchor-check**: controleer dat alle links naar `#token-validatie-aan-de-bronapplicatie...` zijn bijgewerkt naar de nieuwe anchor en geen 404 binnen de pagina opleveren.
4. **PlantUML SVG**: in de gerenderde pagina toont het sequence-diagram alleen de externe-URL-flow + de policy-check-note bij de bron. Geen `alt/else`-takken meer.

## Vervolgstappen (buiten deze plan)

- Na ontvangst van de Confluence-input van TC: separate iteratie om die inhoud te verwerken (verwacht: extra eisen op `type`-codering, evt. category-scope, etc.).
- Wanneer leveranciers het eens zijn over `type`-binding en scope-syntax: FSH-profiel `KT2_DocumentReference` opzetten in `input/fsh/profiles/`, op een **feature branch**, met passende micro-versiebump (conform CLAUDE.md). Pas dan worden de "voorstel"-regels op deze pagina afdwingbare profielregels.
- TOP-KT-011 zelfstandig aanvullen met de gedetailleerde AuditEvent-eisen voor documenten-delen (buiten deze plan).
