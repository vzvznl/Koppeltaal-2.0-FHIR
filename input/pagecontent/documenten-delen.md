### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.1.4 | 2026-07-20 | `content.attachment.hash` toegevoegd als optioneel veld (`0..1`): SHA-1-hash (base64) van de bestandsinhoud, waarmee de ontvanger de integriteit van het opgehaalde bestand kan controleren. |
| 0.1.3 | 2026-07-20 | Task-koppeling via `context.related` afgezwakt van verplicht (`1..*`) naar optioneel (`0..*`): koppeling aan ten minste één Task is wenselijk, maar niet op voorhand verplicht en wordt evenmin uitgesloten. |
| 0.1.2 | 2026-07-14 | De FHIR Binary-optie is volledig vervallen: `attachment.url` MAG NIET naar een FHIR Binary resource verwijzen; het document-endpoint is een regulier HTTPS-download-endpoint, geen FHIR-endpoint. Onderbouwing toegevoegd onder [Overwogen alternatieven](#overwogen-alternatieven). |
| 0.1.1 | 2026-07-09 | `attachment.url` verwijst naar het bestand zelf, niet per se naar een FHIR Binary resource; een Binary-endpoint is een toegestane implementatie, geen eis. Terminologie hierop aangepast (document-endpoint). |
| 0.1.0 | 2026-06-09 | Eerste samengevoegde versie van de pagina "Documenten delen". |

---

### Documenten delen

De inzet van eHealth en blended care is breed ingebed in de zorg. Digitale interventies leveren waardevolle documenten op — zoals rapportages, ongestructureerde vragenlijst-uitkomsten en voortgangsverslagen — die essentieel zijn voor goede behandelbeslissingen. In de praktijk zijn deze documenten echter vaak opgesloten binnen afzonderlijke applicaties, wat leidt tot informatieversnippering en extra administratieve lasten.

Door documenten delen expliciet te ondersteunen binnen Koppeltaal ontstaat een uniforme en gestandaardiseerde manier om documenten uit interventies veilig en geautoriseerd over te dragen van de bronapplicatie (module) naar de dossierhouder (EPD). Hierbij wordt aangesloten op bestaande MedMij- en Nictiz-standaarden. Koppeltaal fungeert als orkestratie-, transport- en autorisatielaag — niet als opslagsysteem.

### DocumentReference en documentinhoud

Documenten zoals PDF/A-rapporten, ongestructureerde vragenlijst-uitkomsten of samenvattingen worden uitgewisseld via het FHIR [DocumentReference](https://www.hl7.org/fhir/R4/documentreference.html) resource. Een DocumentReference bevat metadata over het document (type, datum, auteur, patiënt) en de inhoud zelf — via [`DocumentReference.content.attachment`](https://www.hl7.org/fhir/R4/datatypes.html#Attachment).

De inhoud wordt uitgewisseld via één variant: **externe referentie**. `attachment.url` ("Uri where the data can be found") verwijst rechtstreeks naar **het bestand zelf**, dat de bronapplicatie aanbiedt via een beveiligd HTTPS-endpoint (het *document-endpoint*). Een `GET` op die URL levert de ruwe bestandsinhoud, met een `Content-Type` die overeenkomt met `attachment.contentType`. Het document-endpoint is een **regulier HTTPS-download-endpoint, geen FHIR-endpoint**: `attachment.url` MAG NIET naar een FHIR [Binary](https://www.hl7.org/fhir/R4/binary.html) resource verwijzen (zie [Overwogen alternatieven](#overwogen-alternatieven) voor de onderbouwing); de bronapplicatie hoeft geen FHIR-server te zijn. De data blijft daarmee aan de bron; de Koppeltaal FHIR store bevat alleen de metadata in de DocumentReference. Inline base64 (`attachment.data`) wordt binnen Koppeltaal niet ondersteund: de data blijft aan de bron. Zie [Overwogen alternatieven](#overwogen-alternatieven) voor de afwegingen rond het plaatsen van binaire data.

De module genereert het document — typisch bij afronding van de interventie, maar desgewenst ook tussentijds.

#### Onveranderlijk en self-contained

Het bestand waarnaar een DocumentReference verwijst, moet **onveranderlijk** en **self-contained** zijn: de inhoud staat op zichzelf, zonder externe afhankelijkheden, en wijzigt na publicatie niet meer.

Er is **geen verplicht bestandsformaat**. Het kan een PDF/A-rapport zijn, maar net zo goed een geluidsopname, video of ander bestand — zolang het maar onveranderlijk en self-contained is. PDF/A is voor tekstdocumenten een goede keuze (fonts en resources zijn ingesloten en het is geschikt voor duurzame archivering in het EPD), maar het is geen eis.

Uit de onveranderlijkheid volgt een concrete regel: zodra een bestand is gepubliceerd, mag de inhoud op die `attachment.url` niet meer worden gewijzigd. Een eenmaal gepubliceerde versie is definitief. Een EPD dat het bestand heeft opgehaald en gearchiveerd, kan er zo op vertrouwen dat de inhoud achter die URL niet stilzwijgend verandert.

Ontstaat er tijdens de behandeling een **nieuwe versie**, dan:

- publiceert de module het nieuwe bestand op een **nieuwe URL** — het bestaande bestand blijft ongewijzigd;
- werkt de module de bestaande DocumentReference bij (`PUT` of `PATCH`) zodat `content.attachment.url` naar het nieuwe bestand verwijst — inclusief een bijgewerkte `attachment.hash`, indien die wordt meegegeven;
- detecteert het EPD de bijgewerkte DocumentReference (polling of Subscription) en haalt de nieuwe versie op.

Versiehistorie wordt **niet expliciet vastgelegd** via aparte resources: een update van de bestaande DocumentReference naar een nieuwe bestands-URL volstaat. De DocumentReference verwijst altijd naar de actuele versie; eerdere versies worden in Koppeltaal niet als aparte resources bijgehouden, maar blijven beschikbaar via de versiehistorie van de DocumentReference zelf (FHIR-resourceversionering, op te vragen via `_history`/`vread`).

#### Voorstel: aanpassingen aan het DocumentReference-profiel

Op dit moment kent Koppeltaal nog geen eigen DocumentReference-profiel. De volgende **aanpassingen worden voorgesteld** ten opzichte van het standaard FHIR R4 [DocumentReference](https://www.hl7.org/fhir/documentreference.html)-resource, zodat de in deze pagina beschreven uitwisseling betrouwbaar afdwingbaar wordt. De definitieve invulling — inclusief cardinaliteit, target-profielen en bindingen — wordt in een Koppeltaal-DocumentReference-profiel (FSH) vastgelegd na afstemming met leveranciers.

Voorgestelde profielregels ten opzichte van de FHIR-basis:

- **`subject`** — voorgesteld als verplicht (`1..1`), met als target-profiel het Koppeltaal Patient-profiel. Zonder `subject` is het document niet routeerbaar naar het juiste dossier.
- **`context.related`** — voorgesteld als optioneel (`0..*`), met een verwijzing naar de [Task](https://www.hl7.org/fhir/R4/task.html) die de interventie representeert waaruit het document is voortgekomen. Het is **wenselijk** de DocumentReference aan ten minste één Task te koppelen: daarmee blijft het document traceerbaar naar de specifieke behandelopdracht en kan het EPD het document in de juiste context plaatsen. De Task-koppeling is echter **niet op voorhand verplicht en wordt evenmin uitgesloten** — er kunnen ook documenten worden gedeeld zonder (directe) taakcontext. Te bepalen: of een slice op `context.related` nodig is om de Task-referentie expliciet aan te wijzen (versus andere related resources).
- **`date`** — voorgesteld als verplicht (`1..1`). Het tijdstip waarop de DocumentReference is aangemaakt door de module. Dit is het ankerpunt voor onder andere de [bewaartermijn](#bewaartermijn-documentreference) in de Koppeltaal-store en voor archiveringslogica in het EPD.
- **`type`** — voorgesteld als verplicht (`1..1`). Ontvangers (dossierhouders) moeten direct kunnen zien wat voor soort document binnenkomt — rapportage, ongestructureerde vragenlijst-uitkomst, voortgangsverslag, etc. — zonder het bestand te hoeven openen. De binding/ValueSet (LOINC via [valueset-c80-doc-typecodes](https://www.hl7.org/fhir/R4/valueset-c80-doc-typecodes.html) of een Koppeltaal-specifieke ValueSet) wordt nog uitgewerkt; zie [Open punten](#open-punten).
- **`category`** — voorgesteld als optioneel (`0..*`). Leveranciers MOGEN categorieën meegeven (bv. om type-codes op een hoger niveau te groeperen), maar het is geen eis.
- **`content.attachment.hash`** — voorgesteld als optioneel (`0..1`). De SHA-1-hash (base64) van de bestandsinhoud, conform de definitie van [`Attachment.hash`](https://www.hl7.org/fhir/R4/datatypes-definitions.html#Attachment.hash). Hiermee kan de ontvanger na het ophalen controleren of de opgehaalde inhoud overeenkomt met wat de DocumentReference aankondigt — een extra waarborg bovenop het [onveranderlijkheidsprincipe](#onveranderlijk-en-self-contained). Bij publicatie van een nieuwe versie (nieuwe `attachment.url`) werkt de module ook de hash bij.

Dit zijn voorstellen, geen vastgestelde profielregels. Na consensus volgt de uitwerking in een DocumentReference-profiel in `input/fsh`, met bijbehorende validatie via de IG-publisher. Pas vanaf dat moment kunnen niet-conformante resources op deze regels worden afgewezen.

### Uitwisselingspatronen

Voor het overdragen van documenten van de module naar het EPD geldt **direct ophalen via de Koppeltaal FHIR store** als aangewezen route. Twee andere patronen — Notified Pull en Binary als losse resource in de Koppeltaal-store — zijn overwogen, maar niet aangewezen als standaardroute; zie [Overwogen alternatieven](#overwogen-alternatieven).

#### Direct ophalen via de Koppeltaal FHIR store

In dit patroon publiceert de module een DocumentReference in de Koppeltaal FHIR store. Het EPD detecteert de nieuwe DocumentReference — via polling of een FHIR Subscription — en haalt vervolgens de inhoud op via de externe referentie (`attachment.url`): het EPD haalt eerst een `access_token` op bij de Koppeltaal authorization server en doet daarmee een `GET` naar de `attachment.url` bij de bronapplicatie (token als `Authorization: Bearer …`). De bronapplicatie valideert het token door het te introspecten bij dezelfde authorization server ([RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662) `/introspect`); pas na een geldige respons (`active: true` plus passende scopes) wordt het document geleverd. Autorisatie blijft daarmee centraal bij Koppeltaal — de bronapplicatie hoeft geen eigen vertrouwensmodel te onderhouden (zie ook [Open punten](#open-punten)).

<div style="clear: both; margin: 1em 0;">
{% include documenten-delen-direct-ophalen.svg %}
</div>

Dit patroon kent de minste orkestratie — er is geen aparte Notification Task — en houdt de **data aan de bron**: de fysieke controle over het bestand blijft bij de bronhouder, terwijl de DocumentReference — en daarmee alle metadata, autorisatie en signalering — in de Koppeltaal FHIR store blijft.

Het EPD detecteert nieuwe DocumentReferences via polling of een FHIR Subscription op de Koppeltaal-store.

### Workflow

Documenten delen sluit aan op de bestaande Koppeltaal Task lifecycle, maar begint al vóór de toewijzing — bij de publicatie van de `ActivityDefinition` en het herkennen van de feature flag door het initiërende platform:

1. De module-applicatie publiceert een `ActivityDefinition` met de documenten-delen-uitbreiding in `useContext` (de feature flag; zie [Aankondiging via de ActivityDefinition](#aankondiging-via-de-activitydefinition))
2. De toewijzende applicatie (ECD/EPD) leest de `ActivityDefinition`, herkent aan de `useContext` dat deze interventie een document oplevert, en stelt vast dat zij de te verwachten `DocumentReference` kan verwerken — kan zij dat niet, dan biedt zij de interventie niet aan
3. De behandelaar wijst de interventie toe aan de patiënt (Task wordt aangemaakt)
4. De patiënt voert de interventie uit via de module
5. De module genereert een document (bijvoorbeeld een PDF/A) — bij afronding van de interventie of tussentijds
6. De module publiceert een DocumentReference in de Koppeltaal FHIR store, gekoppeld aan de Patient en bij voorkeur aan de Task
7. Het EPD haalt het document op en archiveert het in het patiëntdossier

De DocumentReference wordt gekoppeld aan de Patient en bij voorkeur ook aan de Task, zodat het document traceerbaar is naar de specifieke interventie. De Task-koppeling is wenselijk, maar niet verplicht (zie [het profielvoorstel](#voorstel-aanpassingen-aan-het-documentreference-profiel)).

**Een afgeronde Task is geen voorwaarde.** Een document mag op elk moment in de Task-lifecycle worden gepubliceerd; de Task hoeft hiervoor **niet** de status `completed` te hebben. Zo kunnen ook tussentijdse rapportages worden gedeeld terwijl de interventie nog loopt.

### Aankondiging via de ActivityDefinition

Of een digitale interventie een document oplevert, is voor de applicatie die de interventie toewijst niet vanzelfsprekend. Documenten delen wordt daarom behandeld als een **optionele uitbreiding** van de Koppeltaal standaard (zie **TOP-KT-025 — Optionele uitbreiding van de Koppeltaal standaard**). Een module-applicatie kondigt vooraf — in de `ActivityDefinition` — aan dat de betreffende interventie een document oplevert.

Dit gebeurt via de `useContext` van de `ActivityDefinition`: de module neemt een uitbreidingscode op uit het `KoppeltaalExpansion`-codesysteem (hetzelfde patroon als de uitbreiding "Rol van de naaste"). Deze code is het signaal dat er op basis van de hieruit voortkomende `Task` een `DocumentReference` zal worden aangemaakt.

Het voorstel is om hiervoor een nieuwe code op te nemen in het `KoppeltaalExpansion`-codesysteem (`http://vzvz.nl/fhir/CodeSystem/koppeltaal-expansion`):

```text
029-DocumentenDelen — "Documenten Delen"
Met de "Documenten Delen" uitbreiding kunnen applicaties op basis van Taken
voor de patiënt een document door middel van een DocumentReference delen met
andere applicaties in het domein.
```

Een module die documenten oplevert, neemt deze code dan als volgt op in de `useContext` van haar `ActivityDefinition` (illustratief; de code is nog niet vastgelegd in `input/fsh`):

```json
"useContext": [
  {
    "code": {
      "system": "http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context-type",
      "code": "koppeltaal-expansion"
    },
    "valueCodeableConcept": {
      "coding": [
        {
          "system": "http://vzvz.nl/fhir/CodeSystem/koppeltaal-expansion",
          "code": "029-DocumentenDelen",
          "display": "Documenten Delen"
        }
      ]
    }
  }
]
```

> Dit voorbeeld dient ter illustratie van het patroon. De definitieve codewaarde en uitwerking worden vastgelegd in `input/fsh`; zie [Open punten](#open-punten).

De applicatie die de interventie toewijst (doorgaans het ECD/EPD) leest deze `useContext` bij het [inzien en selecteren](#workflow) van interventies. Daarmee weet de toewijzende applicatie **vooraf** dat:

- er op basis van de aangemaakte `Task` een `DocumentReference` in de Koppeltaal FHIR store gepubliceerd zal worden;
- zij in staat moet zijn dit document te verwerken: detecteren (polling of Subscription), ophalen via de externe referentie en archiveren in het dossier (zie [Workflow](#workflow)).

De toewijzende applicatie moet hier dus expliciet rekening mee houden. Een applicatie die documenten delen niet ondersteunt, kan op basis van de `useContext` besluiten de interventie niet aan te bieden of toe te wijzen — net als bij andere optionele uitbreidingen. Zo wordt voorkomen dat een interventie wordt toegewezen waarvan het opgeleverde document vervolgens niet verwerkt kan worden.

Conform het MVP-model van TOP-KT-025 zijn er geen technische controles in het Koppeltaal-stelsel die afdwingen dat de toewijzende applicatie documenten kan verwerken; dit wordt geborgd via acceptatie per uitbreiding en afspraken op zorgaanbieder-domeinniveau. De concrete uitbreidingscode voor documenten delen is nog uit te werken (zie [Open punten](#open-punten)).

### Autorisatie

> **Let op — huidig versus toekomstig model.** In het **huidige** Koppeltaal-autorisatiemodel worden **applicaties** geautoriseerd, niet individuele personen (zie [autorisaties.html](./autorisaties.html#huidig-autorisatiemodel-koppeltaal)). Toegang tot een DocumentReference loopt daarmee via de applicatie-autorisatiematrix en is op dit moment **niet** gebonden aan de behandelrelatie. De hieronder beschreven binding aan de behandelrelatie beschrijft het **toekomstige** model; die wordt pas werkelijkheid zodra de persoonsgebonden autorisatie is geïmplementeerd (zie [autorisaties.html](./autorisaties.html)).

In het toekomstige model is toegang tot documenten gebonden aan de behandelrelatie:

- **Zorgverleners**: alleen zorgverleners met een geldige behandelrelatie — vastgelegd in het CareTeam — krijgen toegang tot documenten
- **RelatedPerson**: personen betrokken bij de behandeling (ouders, mantelzorgers, wettelijk vertegenwoordigers) kunnen beperkte, doelgebonden en tijdgebonden inzage krijgen in documenten. Toegang vervalt automatisch bij het eindigen van de relatie, het intrekken van toestemming of het afsluiten van de behandeling
- **Logging**: alle inzage en overdracht van documenten wordt gelogd en is auditeerbaar

Het Koppeltaal-scope-model is gebaseerd op SMART on FHIR v2 scopes met query-parameters (zie [autorisaties.html](./autorisaties.html) en TOP-KT-016). Het patroon `system/Resource.[crud]?param=value` — al toegepast voor `resource-origin` — maakt het mogelijk om in een toekomstige iteratie filtering op bijvoorbeeld `DocumentReference.type` te ondersteunen. De concrete scope-syntax voor DocumentReference wordt vastgelegd in de Koppeltaal-autorisatiematrix; zie [Open punten](#open-punten).

### Bewaartermijn DocumentReference

De DocumentReference wordt in principe **beperkt bewaard** in de Koppeltaal FHIR store. De standaardtermijn is **30 dagen** vanaf publicatie.

**Wie voert de opschoning uit?** De **bronapplicatie (module)** die de DocumentReference heeft gepubliceerd is hiervoor verantwoordelijk: zij is onder het Koppeltaal `resource-origin`-model de eigenaar van de resource en heeft daarmee het recht en de plicht om de eigen DocumentReference na de bewaartermijn te verwijderen. Het reguliere opschoningsproces voor Patient-data van Koppeltaal (zie [opschoning-patient-data.html](./opschoning-patient-data.html)) — dat op patiëntniveau werkt en pas na de veel langere Patient-bewaartermijn ingrijpt — fungeert hierbij slechts als **vangnet**: wordt de hele patiënt verwijderd, dan verdwijnt de DocumentReference mee in de `$purge`-cascade.

Deze termijn weerspiegelt de rol van Koppeltaal als orkestratie- en transportlaag, niet als langetermijn-archief: zodra het document is opgehaald en gearchiveerd in het EPD-dossier, is de DocumentReference in de Koppeltaal-store overbodig. Een korte termijn beperkt het aanvalsoppervlak, voorkomt dat de Koppeltaal-store de facto een tweede dossierstore wordt, en sluit aan op het principe dat de bronhouder verantwoordelijk blijft voor de inhoud.

Consequenties:

- **Het EPD** moet de DocumentReference binnen de bewaartermijn detecteren (polling of Subscription) en de inhoud ophalen of archiveren. Documenten die na 30 dagen nog niet zijn opgehaald, worden niet langer aangeboden via de Koppeltaal-store.
- **De bronapplicatie** behoudt — bij de variant met externe URL — het brondocument in haar eigen omgeving, onafhankelijk van de Koppeltaal-bewaartermijn. De levenscyclus van het brondocument volgt het beleid van de bronhouder.
- **Afwijken van de standaard** (langer of korter dan 30 dagen) is in specifieke gebruiksscenario's mogelijk, maar moet expliciet worden vastgelegd in het leveranciersprofiel of een aanvullende afspraak. Of, en op welk niveau, individuele afwijkingen mogelijk worden gemaakt is nog uit te werken (zie [Open punten](#open-punten)).

### Beveiligingseisen voor het document-endpoint van de bron

Om fragmentatie en ongelijke beveiligingsniveaus te voorkomen publiceert Koppeltaal een set eisen voor het document-endpoint dat een bronapplicatie aanbiedt. De eisen worden gesplitst in **harde eisen** (verplicht; conformance-criterium) en **zachte aanbevelingen** (best practice; sterk aangeraden maar niet afdwingbaar).

De generieke Koppeltaal-beveiligingseisen uit TOP-KT-008 — Beveiliging aspecten (onder andere: HTTPS-only, JWT-handtekening met asymmetrische algoritmes, security headers zoals Cache-Control: no-store, Strict-Transport-Security, X-Content-Type-Options: nosniff en expliciete Content-Type, restrictieve CORS, input-validatie) gelden onverkort ook voor het document-endpoint. De eisen hieronder zijn **aanvullend** en specifiek voor het document-endpoint van de bronapplicatie.

**Hard — verplicht:**

- **TLS-only** (minimaal TLS 1.2, geen klare HTTP)
- **Verplichte token-validatie** (zie [Token-validatie en data-owner-verificatie](#token-validatie-en-data-owner-verificatie)), inclusief afwijzing van requests zonder geldig access_token

**Zacht — aanbevolen:**

- Niet-raadbare paden voor documenten (bijvoorbeeld UUID's of cryptografisch random identifiers; geen incrementele IDs)
- Rate-limiting en standaard hardening (security headers, beperkte error-detail bij 401/403)

Voor toekomstige fijngranulariteit (bijvoorbeeld filtering op `DocumentReference.type`) ligt de richting bij **SMART on FHIR v2 scopes-met-query** — het patroon dat Koppeltaal al toepast voor `resource-origin`. De concrete uitwerking volgt in de Koppeltaal-autorisatiematrix; zie [Concrete scope-syntax voor DocumentReference in de autorisatiematrix](#concrete-scope-syntax-voor-documentreference-in-de-autorisatiematrix) onder Open punten.

### Audit-logging bij de bron

Het ophalen van het bestand loopt niet via Koppeltaal; de **bronapplicatie is verantwoordelijk voor de audit-registratie** van wie/wanneer/welk document. Detail-eisen, AuditEvent-structuur en eventuele uitwisseling met een centrale Koppeltaal-AuditEvent-store worden behandeld in [change-management-topic-11-implementation-feedback.html](./change-management-topic-11-implementation-feedback.html).

### Overwogen alternatieven

Bij [Uitwisselingspatronen](#uitwisselingspatronen) is **direct ophalen via de Koppeltaal FHIR store** als aangewezen route beschreven. Tijdens de uitwerking zijn twee andere patronen overwogen — **Notified Pull** en **Binary als losse resource in de Koppeltaal-store** — en daarnaast een **FHIR Binary-endpoint bij de bron** als implementatie van het document-endpoint. Geen van deze is aangewezen als (onderdeel van de) standaardroute; ze worden hier kort gedocumenteerd zodat de afweging traceerbaar blijft en het onderwerp opnieuw opgepakt kan worden mocht de scope van Koppeltaal in de toekomst veranderen.

#### ~~Notified Pull~~

In dit patroon — gebaseerd op de [TA Notified Pull v1.0.1](https://www.nictiz.nl/) — neemt de module het initiatief door het EPD actief te notificeren via een Notification Task. De Notification Task bevat verwijzingen naar de op te halen FHIR resources; het EPD haalt op eigen initiatief en tempo de data op bij de bron.

<div style="clear: both; margin: 1em 0;">
{% include documenten-delen-notified-pull.svg %}
</div>

Notified Pull is aantrekkelijk door de aansluiting op de door Nictiz beheerde TA Notified Pull-standaard (publieke standaard, **netwerkzorg**) en omdat het EPD geen polling of eigen Subscription hoeft in te richten. In de huidige Koppeltaal-scope — interventies binnen een al bekend behandelnetwerk waarin het EPD al synchroniseert via de Koppeltaal-store — voegt de Notification Task echter een extra orkestratielaag toe terwijl detectie via Subscription/polling op de Koppeltaal-store volstaat. De keuze is daarom op direct ophalen gevallen.

Mocht netwerkzorg- of cross-organisatie-uitwisseling later expliciet in scope komen, dan kan Notified Pull alsnog als optionele aanvulling worden gespecificeerd. De twee patronen sluiten elkaar niet uit.

#### ~~Binary als losse resource in de Koppeltaal-store~~

In een eerder ontwerp is dit alternatief overwogen: het document niet als bestand bij de bronapplicatie laten staan, maar als Binary resource — naast de DocumentReference — in de Koppeltaal FHIR store plaatsen. Argument was onder meer centrale token-validatie, automatische AuditEvents en geen eigen resource-server bij de bronapplicatie.

Bij nadere beschouwing bleken een aantal van die voordelen niet onderscheidend ten opzichte van direct ophalen, en wegen er zwaarwegende bezwaren tegen op:

- **Dataminimalisatie en bronverantwoordelijkheid**: gevoelige gezondheidsdata buiten de bronhouder plaatsen vergroot het aanvalsoppervlak en ondermijnt het principe dat de bronhouder verantwoordelijk blijft voor zijn data tijdens de uitwisseling.
- **Verlies van het pull-signaal**: bij direct ophalen weet de bronhouder wanneer en door wie het document is opgehaald — een nuttig signaal voor archiveringsstatus, bewaartermijnen en eigen audit. Bij dit alternatief verdwijnt dat signaal.

Dit alternatief blijft denkbaar als uitwijkmogelijkheid voor specifieke gevallen (bijvoorbeeld een bron die geen stabiel publiek endpoint kan aanbieden), maar is geen standaardroute van de Koppeltaal-specificatie.

#### ~~FHIR Binary-endpoint bij de bron~~

In een eerdere versie van deze pagina was het toegestaan (geen eis) om het document-endpoint te implementeren als FHIR [Binary](https://www.hl7.org/fhir/R4/binary.html)-endpoint bij de bronapplicatie. Deze optie is **volledig vervallen**: `attachment.url` MAG NIET naar een FHIR Binary resource verwijzen. De overwegingen:

- **Dubbel content type.** Zowel `Binary.contentType` als `attachment.contentType` beschrijven het formaat van dezelfde inhoud. Dat is redundant en introduceert een conflictrisico: wat als de attachment een PDF aankondigt en de Binary een Word-document bevat? Zonder Binary is er één bron van waarheid — `attachment.contentType`, bevestigd door de `Content-Type`-header van het document-endpoint.
- **Een FHIR resource wekt de verwachting van een FHIR API.** Een Binary-URL suggereert dat de bron een FHIR-server is, met bijbehorende semantiek: versiegeschiedenis (`_history`/`vread`), zoekgedrag, een CapabilityStatement en FHIR-foutafhandeling (OperationOutcome). Van moduleleveranciers zou dan aanzienlijk meer verwacht worden dan het aanbieden van een enkele download-URL.
- **Contentonderhandeling via de `Accept`-header.** Een FHIR Binary-endpoint levert afhankelijk van de `Accept`-header óf de ruwe inhoud óf een FHIR-wrapper (JSON/XML met base64-inhoud); zie [Binary — REST behavior](https://hl7.org/fhir/R4/binary.html#rest). Dit gedrag moet door zowel bron als afnemer correct geïmplementeerd worden en is een bekende bron van interoperabiliteitsproblemen.

Samengenomen maakt dit de Binary-optie onnodig complex voor moduleleveranciers, terwijl een regulier HTTPS-download-endpoint volstaat.

### Open punten

De volgende punten zijn nog uit te werken in samenwerking met leveranciers:

#### Token-validatie en data-owner-verificatie

Wanneer het EPD een externe `attachment.url` aanroept, ontvangt de bronapplicatie een `GET`-request met een Koppeltaal-uitgegeven access_token. De bronapplicatie introspecteert het token bij de Koppeltaal authorization server ([RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662) `/introspect`; zie ook **TOP-KT-021 — Token introspection**) en krijgt een set scopes terug. **De regel is**: de scope die het EPD nodig heeft om de DocumentReference te lezen geldt ook als toestemming om het bijbehorende bestand op te halen. Dezelfde permissie dekt zowel metadata als inhoud.

**Data-owner verification** — een succesvolle introspect (`active: true` plus passende scopes) is een **noodzakelijke maar geen voldoende voorwaarde** voor levering. De bronapplicatie MAY na een geldige introspect alsnog toegang weigeren of intrekken op basis van eigen beleid (bijvoorbeeld ingetrokken patiënt-toestemming, bron-specifieke regels, vermoeden van misbruik). In dat geval reageert de bron met `403 Forbidden` en logt de afwijzing zelf (zie [Audit-logging bij de bron](#audit-logging-bij-de-bron)).

Twee alternatieven zijn overwogen en niet gekozen:

- **Een nieuwe, expliciete scope voor de documentinhoud** (bijvoorbeeld `documenten/content.read`): zou toegang tot de inhoud loskoppelen van DocumentReference-toegang. Verworpen omdat het een onduidelijke status institutionaliseert (wel toegang tot de reference, niet tot de data) zonder een gebruiksscenario dat dat onderscheid nodig maakt.
- **Uitbreiding van het introspect-endpoint met een scope-parameter** (de bron vraagt aan Koppeltaal "mag deze client dit bestand ophalen?"): valt af. [RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662) definieert `/introspect` strikt als token-introspectie en kent geen request-parameters voor een per-resource autorisatiebeslissing. Een policy-decision-point hoort, indien ooit nodig, in een aparte voorziening (UMA-/PDP-pattern), niet in `/introspect`.

#### ValueSet/binding voor `DocumentReference.type`

Welke codes mogen leveranciers gebruiken voor `type`? Opties: LOINC ([valueset-c80-doc-typecodes](https://www.hl7.org/fhir/R4/valueset-c80-doc-typecodes.html), de FHIR R4-default), een Koppeltaal-specifieke ValueSet voor ongestructureerde behandeluitkomsten, of een gelaagde aanpak (LOINC als basis met aanvullende Koppeltaal-codes). Te bepalen samen met leveranciers en op te nemen in het toekomstige `KT2_DocumentReference`-profiel.

#### Concrete scope-syntax voor DocumentReference in de autorisatiematrix

Het SMART v2 scopes-met-query-patroon (`system/DocumentReference.read?type=…`) moet worden uitgewerkt voor DocumentReference: welke parameters worden ondersteund, welke combinaties, en hoe verhouden filter-scopes zich tot de generieke `DocumentReference.read`. Op te nemen in [autorisaties.html](./autorisaties.html) (of een sibling-pagina) zodra de eerste consument hier behoefte aan heeft.

#### Uitbreidingscode voor documenten delen

De [aankondiging via de ActivityDefinition](#aankondiging-via-de-activitydefinition) vereist een concrete uitbreidingscode in het `KoppeltaalExpansion`-codesysteem (`input/fsh`), naar analogie van `026-RolvdNaaste`. Vast te leggen na afstemming met leveranciers: de codewaarde en het label, en of documenten delen één enkele uitbreiding vormt of verder verfijnd wordt (bijvoorbeeld onderscheid tussen verplicht en optioneel opleveren van een document). Pas zodra de code in `input/fsh` is opgenomen, kan de `useContext` op deze waarde worden gevalideerd.

### Status

Aanvullende inhoudelijke uitwerking volgt uit een door de Technical Community aangeleverde Confluence-documentatie (TC, juni 2026); deze pagina wordt aangevuld zodra die input beschikbaar is.

Deze pagina beschrijft de oplossingsrichting op hoog niveau. De exacte invulling van profielen, uitwisselingspatronen en autorisatieregels wordt in samenwerking met leveranciers bepaald.
