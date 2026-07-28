# TOP-KT-029 - Documenten delen

| Versie | Datum | Status | Wijzigingen |
| --- | --- | --- | --- |
| 0.2.1 | 21 Jul 2026 | Concept | Voorbeeldtabel bij Versionering en versiestreams uitgebreid met de `status`-kolom (`superseded`/`current`), als situatie ná de laatste herziening door dezelfde module. |
| 0.2.0 | 21 Jul 2026 | Concept | **Levenscyclus- en versioneringsmodel.** De 30 dagen is voortaan een *beschikbaarheidstermijn van de inhoud*, geen bewaartermijn van de resource: na afloop verwijdert de bron alleen `attachment.url` (leegmaak-update); de DocumentReference blijft als metadata-anker bestaan en volgt de reguliere patiënt-levenscyclus. Versiestreams zijn herkenbaar via een reeks-identifier (`identifier`) en een sterk aanbevolen versie-identifier (`masterIdentifier`); herzieningen ná de termijn verwijzen via `relatesTo` naar hun voorganger (`replaces`/`appends`/`transforms` met workflow-functie; `signs` toegestaan zonder logische functie). De logische bestandsnaam reist mee via de `Content-Disposition`-header van het document-endpoint. |
| 0.1.3 | 20 Jul 2026 | Concept | `content.attachment.hash` toegevoegd als optioneel veld (`0..1`): SHA-1-hash (base64) van de bestandsinhoud, waarmee de dossierhouder de integriteit van het opgehaalde bestand kan controleren. |
| 0.1.2 | 20 Jul 2026 | Concept | Task-koppeling via `context.related` afgezwakt van verplicht (`1..*`) naar optioneel (`0..*`): koppeling aan ten minste één Task is wenselijk, maar niet op voorhand verplicht en wordt evenmin uitgesloten. |
| 0.1.1 | 14 Jul 2026 | Concept | FHIR Binary-optie volledig vervallen: `attachment.url` MAG NIET naar een FHIR Binary resource verwijzen; het document-endpoint is een regulier HTTPS-download-endpoint. Onderbouwing opgenomen onder Overwogen alternatieven. |
| 0.1.0 | 9 Jul 2026 | Concept | Eerste concept, gebaseerd op de IG-pagina "Documenten delen" (versie 0.1.0). |

> **Let op:** Documenten delen is een optionele uitbreiding van de Koppeltaal standaard. Het gebruik ervan is niet verplicht. Zie [Topic 25](TOP-KT-025-optionele-uitbreiding-van-de-koppeltaal-standaard.md) voor meer informatie over het gebruik van optionele uitbreidingen.

## Beschrijving

De inzet van eHealth en blended care is breed ingebed in de zorg. Digitale interventies leveren waardevolle documenten op — zoals rapportages, ongestructureerde vragenlijst-uitkomsten en voortgangsverslagen — die essentieel zijn voor goede behandelbeslissingen. In de praktijk zijn deze documenten echter vaak opgesloten binnen afzonderlijke applicaties, wat leidt tot informatieversnippering en extra administratieve lasten.

Door documenten delen expliciet te ondersteunen binnen Koppeltaal ontstaat een uniforme en gestandaardiseerde manier om documenten uit interventies veilig en geautoriseerd over te dragen van de bronapplicatie (module) naar de dossierhouder (EPD). Hierbij wordt aangesloten op bestaande MedMij- en Nictiz-standaarden. Koppeltaal fungeert als orkestratie-, transport- en autorisatielaag — **niet** als opslagsysteem.

## User stories

Met deze uitbreiding worden de volgende user stories mogelijk gemaakt:

- Als module-applicatie kan ik een document (bijvoorbeeld een rapportage of voortgangsverslag) dat voortkomt uit een digitale interventie beschikbaar stellen aan de dossierhouder.
- Als zorgverlener kan ik in de toewijzende applicatie (ECD/EPD) vooraf zien dat een digitale interventie een document oplevert, zodat ik weet dat mijn applicatie dit moet kunnen verwerken.
- Als dossierhouder (EPD) kan ik nieuwe documenten detecteren, veilig en geautoriseerd ophalen bij de bron, en archiveren in het patiëntdossier.
- Als bronhouder behoud ik de fysieke controle over het document en kan ik zien wanneer en door wie het is opgehaald.

## FHIR Resources

Deze uitbreiding wordt gerealiseerd door toepassing van het `DocumentReference` resource; de documentinhoud zelf wordt als bestand door de bronapplicatie aangeboden. Het `DocumentReference` resource wordt aanvullend ingezet op de in de basis gedefinieerde resources (zie [Topic 09](TOP-KT-009-overzicht-gebruikte-fhir-resources.md)).

| Profiel / Resource | Omschrijving | Vindplaats |
| --- | --- | --- |
| DocumentReference | Metadata over het document (type, datum, auteur, patiënt) en een verwijzing naar de inhoud via `content.attachment.url`. Wordt gepubliceerd in de Koppeltaal FHIR store, conform het Koppeltaal-profiel `KT2_DocumentReference` (zie [Aanpassingen aan het DocumentReference-profiel](#aanpassingen-aan-het-documentreference-profiel)). | [FHIR R4 DocumentReference](https://www.hl7.org/fhir/R4/documentreference.html) |
| Documentinhoud (bestand) | De feitelijke inhoud van het document. Wordt **niet** in de Koppeltaal FHIR store geplaatst, maar door de bronapplicatie aangeboden via een beveiligd HTTPS-endpoint (het *document-endpoint*), op de URL in `content.attachment.url`. | [FHIR R4 Attachment](https://www.hl7.org/fhir/R4/datatypes.html#Attachment) |

De inhoud wordt uitgewisseld via één variant: **externe referentie**. `attachment.url` ("Uri where the data can be found") verwijst rechtstreeks naar **het bestand zelf** bij de bronapplicatie; een `GET` op die URL levert de ruwe bestandsinhoud, met een `Content-Type` die overeenkomt met `attachment.contentType`. Het document-endpoint is een **regulier HTTPS-download-endpoint, geen FHIR-endpoint**: `attachment.url` MAG NIET naar een FHIR [Binary](https://www.hl7.org/fhir/R4/binary.html) resource verwijzen (zie [Overwogen alternatieven](#overwogen-alternatieven) voor de onderbouwing); de bronapplicatie hoeft geen FHIR-server te zijn. De data blijft daarmee aan de bron; de Koppeltaal FHIR store bevat alleen de metadata in de DocumentReference. Inline base64 (`attachment.data`) wordt binnen Koppeltaal **niet** ondersteund.

De module genereert het document — typisch bij afronding van de interventie, maar desgewenst ook tussentijds.

## Overwegingen

### Uitwisselingspatroon: direct ophalen via de Koppeltaal FHIR store

Voor het overdragen van documenten van de module naar het EPD geldt **direct ophalen via de Koppeltaal FHIR store** als aangewezen route:

1. De module publiceert een DocumentReference in de Koppeltaal FHIR store.
2. Het EPD detecteert de nieuwe DocumentReference — via polling of een FHIR Subscription (zie [Topic 06](TOP-KT-006-abonneren-op-en-signaleren-van-gebeurtenissen.md)).
3. Het EPD haalt een `access_token` op bij de Koppeltaal authorization server en doet daarmee een `GET` naar de `attachment.url` bij de bronapplicatie (token als `Authorization: Bearer …`).
4. De bronapplicatie valideert het token via token introspection bij dezelfde authorization server ([RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662) `/introspect`; zie [Topic 21](TOP-KT-021-token-introspection.md)). Pas na een geldige respons (`active: true` plus passende scopes) wordt het document geleverd.

Autorisatie blijft daarmee centraal bij Koppeltaal — de bronapplicatie hoeft geen eigen vertrouwensmodel te onderhouden. Dit patroon kent de minste orkestratie — er is geen aparte Notification Task — en houdt de **data aan de bron**: de fysieke controle over het bestand blijft bij de bronhouder, terwijl de DocumentReference — en daarmee alle metadata, autorisatie en signalering — in de Koppeltaal FHIR store blijft.

> De PlantUML-bron van het sequencediagram is beschikbaar in `input/images-source/documenten-delen-direct-ophalen.plantuml`.

### Overwogen alternatieven

Twee andere patronen zijn overwogen, maar niet aangewezen als standaardroute; daarnaast is een FHIR Binary-endpoint bij de bron als implementatie van het document-endpoint overwogen en vervallen. Ze worden hier gedocumenteerd zodat de afweging traceerbaar blijft en het onderwerp opnieuw opgepakt kan worden mocht de scope van Koppeltaal veranderen.

#### Notified Pull (niet gekozen)

In dit patroon — gebaseerd op de TA Notified Pull v1.0.1 van Nictiz — neemt de module het initiatief door het EPD actief te notificeren via een Notification Task. De Notification Task bevat verwijzingen naar de op te halen FHIR resources; het EPD haalt op eigen initiatief en tempo de data op bij de bron.

Notified Pull is aantrekkelijk door de aansluiting op de door Nictiz beheerde publieke standaard (netwerkzorg) en omdat het EPD geen polling of eigen Subscription hoeft in te richten. In de huidige Koppeltaal-scope — interventies binnen een al bekend behandelnetwerk waarin het EPD al synchroniseert via de Koppeltaal-store — voegt de Notification Task echter een extra orkestratielaag toe, terwijl detectie via Subscription/polling op de Koppeltaal-store volstaat. Mocht netwerkzorg- of cross-organisatie-uitwisseling later expliciet in scope komen, dan kan Notified Pull alsnog als optionele aanvulling worden gespecificeerd; de twee patronen sluiten elkaar niet uit.

> De PlantUML-bron van het sequencediagram is beschikbaar in `input/images-source/documenten-delen-notified-pull.plantuml`.

#### Binary als losse resource in de Koppeltaal-store (niet gekozen)

In een eerder ontwerp is overwogen om het document niet als bestand bij de bronapplicatie te laten staan, maar als Binary resource — naast de DocumentReference — in de Koppeltaal FHIR store te plaatsen. Argumenten waren onder meer centrale token-validatie, automatische AuditEvents en geen eigen resource-server bij de bronapplicatie. Bij nadere beschouwing wegen zwaarwegende bezwaren hier tegenop:

- **Dataminimalisatie en bronverantwoordelijkheid:** gevoelige gezondheidsdata buiten de bronhouder plaatsen vergroot het aanvalsoppervlak en ondermijnt het principe dat de bronhouder verantwoordelijk blijft voor zijn data tijdens de uitwisseling.
- **Verlies van het pull-signaal:** bij direct ophalen weet de bronhouder wanneer en door wie het document is opgehaald — een nuttig signaal voor archiveringsstatus, bewaartermijnen en eigen audit. Bij dit alternatief verdwijnt dat signaal.

Dit alternatief blijft denkbaar als uitwijkmogelijkheid voor specifieke gevallen (bijvoorbeeld een bron die geen stabiel publiek endpoint kan aanbieden), maar is geen standaardroute van de Koppeltaal-specificatie.

#### FHIR Binary-endpoint bij de bron (vervallen)

In een eerdere versie was het toegestaan (geen eis) om het document-endpoint te implementeren als FHIR [Binary](https://www.hl7.org/fhir/R4/binary.html)-endpoint bij de bronapplicatie. Deze optie is **volledig vervallen**: `attachment.url` MAG NIET naar een FHIR Binary resource verwijzen. De overwegingen:

- **Dubbel content type.** Zowel `Binary.contentType` als `attachment.contentType` beschrijven het formaat van dezelfde inhoud. Dat is redundant en introduceert een conflictrisico: wat als de attachment een PDF aankondigt en de Binary een Word-document bevat? Zonder Binary is er één bron van waarheid — `attachment.contentType`, bevestigd door de `Content-Type`-header van het document-endpoint.
- **Een FHIR resource wekt de verwachting van een FHIR API.** Een Binary-URL suggereert dat de bron een FHIR-server is, met bijbehorende semantiek: versiegeschiedenis (`_history`/`vread`), zoekgedrag, een CapabilityStatement en FHIR-foutafhandeling (OperationOutcome). Van moduleleveranciers zou dan aanzienlijk meer verwacht worden dan het aanbieden van een enkele download-URL.
- **Contentonderhandeling via de `Accept`-header.** Een FHIR Binary-endpoint levert afhankelijk van de `Accept`-header óf de ruwe inhoud óf een FHIR-wrapper (JSON/XML met base64-inhoud); zie [Binary — REST behavior](https://hl7.org/fhir/R4/binary.html#rest). Dit gedrag moet door zowel bron als afnemer correct geïmplementeerd worden en is een bekende bron van interoperabiliteitsproblemen.

Samengenomen maakt dit de Binary-optie onnodig complex voor moduleleveranciers, terwijl een regulier HTTPS-download-endpoint volstaat.

### Onveranderlijk en self-contained

Het bestand waarnaar een DocumentReference verwijst, moet **onveranderlijk** en **self-contained** zijn: de inhoud staat op zichzelf, zonder externe afhankelijkheden, en wijzigt na publicatie niet meer.

Er is **geen verplicht bestandsformaat**. Het kan een PDF/A-rapport zijn, maar net zo goed een geluidsopname, video of ander bestand — zolang het maar onveranderlijk en self-contained is. PDF/A is voor tekstdocumenten een goede keuze (fonts en resources zijn ingesloten en het is geschikt voor duurzame archivering in het EPD), maar het is geen eis.

Uit de onveranderlijkheid volgt een concrete regel: zodra een bestand is gepubliceerd, mag de inhoud op die `attachment.url` niet meer worden gewijzigd. Een eenmaal gepubliceerde versie is definitief. Een EPD dat het bestand heeft opgehaald en gearchiveerd, kan er zo op vertrouwen dat de inhoud achter die URL niet stilzwijgend verandert.

Ontstaat er **binnen de beschikbaarheidstermijn** (zie [Beschikbaarheidstermijn en levenscyclus](#beschikbaarheidstermijn-en-levenscyclus)) een nieuwe versie, dan:

- publiceert de module het nieuwe bestand op een **nieuwe URL** — het bestaande bestand blijft ongewijzigd;
- werkt de module de bestaande DocumentReference bij (`PUT` of `PATCH`) zodat `content.attachment.url` naar het nieuwe bestand verwijst — inclusief een bijgewerkte `attachment.hash` en een nieuwe `masterIdentifier` (versie-identifier), indien die worden meegegeven;
- detecteert het EPD de bijgewerkte DocumentReference (polling of Subscription) en haalt de nieuwe versie op.

Binnen de beschikbaarheidstermijn wordt versiehistorie dus **niet via aparte resources** vastgelegd: een update van de bestaande DocumentReference naar een nieuwe bestands-URL volstaat; de store-interne historie blijft opvraagbaar via `_history`/`vread`. Een herziening **ná de beschikbaarheidstermijn** — bijvoorbeeld wanneer de patiënt in een draaideurscenario na maanden terugkeert — is wél een nieuwe DocumentReference, met een `relatesTo`-verwijzing naar haar voorganger; zie [Versionering en versiestreams](#versionering-en-versiestreams).

### Versionering en versiestreams

Een documentreeks — "Diagnose Jan Jansen", met opeenvolgende versies over meerdere jaren — moet voor het EPD herkenbaar zijn als één stream. FHIR R4 biedt daarvoor twee complementaire identifier-elementen:

- **`identifier`** (`0..*`) — *"Other identifiers associated with the document, including version independent identifiers."* Hier hoort de **reeks-identifier** thuis: één versie-onafhankelijke identifier die alle versies in de stream delen, uitgegeven door de oorspronkelijke bron (bijvoorbeeld een UUID onder het naamsysteem van de module). Dit is het CDA-`setId`-patroon.
- **`masterIdentifier`** (`0..1`) — *"Document identifier as assigned by the source of the document. This identifier is specific to this version of the document."* De **versie-identifier**: door de bron uitgegeven en bij elke inhoudelijke versie vernieuwd — óók bij een update-in-place, waar de resource-id gelijk blijft.

Toegepast op de reeks "Diagnose Jan Jansen" — de situatie ná de herziening van 2025, waarbij dezelfde module de eerdere versies op `superseded` heeft gezet (zie hieronder voor het geval van een andere module):

| Document | `identifier` (reeks) | `masterIdentifier` (versie) | `status` | `relatesTo` |
| --- | --- | --- | --- | --- |
| Diagnose Jan Jansen — 2022-12-01 | `reeks-8f3a…` | `versie-001` | `superseded` | — |
| Diagnose Jan Jansen — 2024-01-03 | `reeks-8f3a…` | `versie-002` | `superseded` | `replaces` → versie 2022 |
| Diagnose Jan Jansen — 2025-03-06 | `reeks-8f3a…` | `versie-003` | `current` | `replaces` → versie 2024 |

Het EPD herkent de stream door te **groeperen op de reeks-identifier** — niet op `title` of bestandsnaam, die zijn mensgericht en instabiel — sorteert op `date`/`creation`, en gebruikt `relatesTo` als expliciete voorganger-verwijzing. De mechanismen versterken elkaar: de reeks-identifier groepeert óók wanneer een schakel in de `relatesTo`-keten ontbreekt; de versie-identifier maakt exacte herkenning en deduplicatie in het archief mogelijk, onafhankelijk van Koppeltaal-resource-ids. In FHIR R5 is `masterIdentifier` opgegaan in `identifier` en is een apart `version`-element toegevoegd; het hier gekozen patroon mapt daar één-op-één op.

**Herziening na de beschikbaarheidstermijn.** De oude DocumentReference is dan uitgedoofd (zie [Beschikbaarheidstermijn en levenscyclus](#beschikbaarheidstermijn-en-levenscyclus)), maar bestaat nog. De module publiceert een **nieuwe DocumentReference** met dezelfde reeks-identifier, een nieuwe `masterIdentifier` en een `relatesTo`-relatie (code `replaces`) met een gewone, oplosbare referentie naar de oude; desgewenst draagt `target.identifier` daarnaast de `masterIdentifier` van de voorganger. Komt de herziening van dezelfde module (de eigenaar van de oude resource), dan zet die de oude DocumentReference op `status = superseded`; komt zij van een andere module, dan kan dat niet (`resource-origin`) en volstaat de `relatesTo`.

**Toegestane relatiecodes.** `relatesTo.code` heeft in R4 een **required binding** op [DocumentRelationshipType](https://hl7.org/fhir/R4/valueset-document-relationship-type.html) — een gesloten set van vier codes; eigen codes zijn niet-conformant. Het profiel staat alle vier de codes toe. Drie ervan hebben een functie in de Koppeltaal-workflow: `replaces` (vervanging/herziening), `appends` (addendum; het origineel blijft geldig) en `transforms` (bewerking of omzetting, bijvoorbeeld formaat- of taalconversie). **`signs`** (ondertekening) is toegestaan — de code hoort bij de required binding — maar heeft binnen Koppeltaal **geen logische functie**: er is geen workflow die erop reageert; ontvangers mogen de relatie tonen of negeren. Relaties met een ándere semantiek passen niet in `relatesTo`; daarvoor is `context.related` het aangewezen element.

**Herziening door een andere module.** Een andere module(leverancier) kent de eerdere DocumentReference niet uit eigen administratie. Die kennis ligt bij het EPD: de toewijzer van de nieuwe interventie én de archiefhouder van het eerdere document. Het EPD reikt bij de toewijzing zowel de referentie naar het eerdere document als de reeks-identifier aan — kandidaat-mechanismen zijn `Task.input` en de launch-context (zie [Open punten](#open-punten)). De module hoeft de oude DocumentReference daarvoor niet te kunnen lezen: zij heeft alleen de referentie nodig, en die krijgt ze aangereikt.

### Aanpassingen aan het DocumentReference-profiel

Koppeltaal definieert een eigen DocumentReference-profiel (`KT2_DocumentReference`) met de volgende aanvullende verplichtingen ten opzichte van het standaard FHIR R4 DocumentReference-resource:

| Element | Regel | Onderbouwing |
| --- | --- | --- |
| `masterIdentifier` | Optioneel maar **sterk aanbevolen** (`0..1`) | Versie-specifieke identifier, door de bron uitgegeven en bij elke inhoudelijke versie vernieuwd — ook bij een update-in-place. Zonder versie-identifier kan het EPD versies niet betrouwbaar herkennen en dedupliceren; de Koppeltaal-resource-id volstaat daarvoor niet (die blijft bij update-in-place gelijk). |
| `identifier` | Ten minste één versie-onafhankelijke **reeks-identifier** (slice) | Dezelfde waarde over alle versies in de stream; de groeperingssleutel waarmee het EPD de versiestream herkent (zie [Versionering en versiestreams](#versionering-en-versiestreams)). Uitgegeven door de oorspronkelijke bron; bij een cross-module herziening aangereikt door het EPD. |
| `relatesTo` | Optioneel (`0..*`), code volgt de required binding | `replaces`, `appends` en `transforms` hebben een functie in de Koppeltaal-workflow; `signs` is toegestaan maar zonder logische functie binnen Koppeltaal. `relatesTo.target` verwijst naar een (mogelijk uitgedoofde) DocumentReference in de Koppeltaal-store. |
| `subject` | Verplicht (`1..1`), target-profiel Koppeltaal Patient | Zonder `subject` is het document niet routeerbaar naar het juiste dossier. |
| `context.related` | Optioneel (`0..*`), met verwijzing naar de `Task` van de interventie | Het is wenselijk de DocumentReference aan ten minste één Task te koppelen: het document blijft dan traceerbaar naar de specifieke behandelopdracht en het EPD kan het in de juiste context plaatsen. De Task-koppeling is echter niet op voorhand verplicht en wordt evenmin uitgesloten — er kunnen ook documenten worden gedeeld zonder (directe) taakcontext. |
| `date` | Verplicht (`1..1`) | Ankerpunt voor onder andere de beschikbaarheidstermijn van de inhoud en archiveringslogica in het EPD. |
| `type` | Verplicht (`1..1`) | Ontvangers moeten direct kunnen zien wat voor soort document binnenkomt — rapportage, ongestructureerde vragenlijst-uitkomst, voortgangsverslag — zonder het bestand te hoeven openen. De binding/ValueSet wordt nog uitgewerkt (zie [Open punten](#open-punten)). |
| `category` | Optioneel (`0..*`) | Leveranciers MOGEN categorieën meegeven (bijvoorbeeld om type-codes op een hoger niveau te groeperen), maar het is geen eis. |
| `content.attachment.url` | Conditioneel: verplicht bij publicatie, verwijderd na de beschikbaarheidstermijn | De *leegmaak-update* (zie [Beschikbaarheidstermijn en levenscyclus](#beschikbaarheidstermijn-en-levenscyclus)). Dit is een procesregel; profieltechnisch blijft `url` `0..1` — de conditie is niet in cardinaliteit uit te drukken. |
| `content.attachment.hash` | Optioneel (`0..1`), **aanbevolen: meegeven tenzij technisch niet mogelijk** | SHA-1-hash (base64) van de bestandsinhoud, conform de definitie van [`Attachment.hash`](https://www.hl7.org/fhir/R4/datatypes-definitions.html#Attachment.hash). Hiermee kan de dossierhouder na het ophalen controleren of de inhoud overeenkomt met wat de DocumentReference aankondigt — een extra waarborg bovenop de onveranderlijkheidseis. Na het uitdoven is de hash het blijvende bewijs van welke inhoud er destijds is aangekondigd. Bij een nieuwe versie werkt de module ook de hash bij. |

Deze regels worden vastgelegd in het `KT2_DocumentReference`-profiel (FSH), met bijbehorende validatie via de IG-publisher. Niet-conformante resources worden op deze regels afgewezen.

### Autorisatie

> **Let op — huidig versus toekomstig model.** In het **huidige** Koppeltaal-autorisatiemodel worden **applicaties** geautoriseerd, niet individuele personen (zie [Topic 05](TOP-KT-005-toegangsbeheersing.md)). Toegang tot een DocumentReference loopt daarmee via de applicatie-autorisatiematrix en is op dit moment **niet** gebonden aan de behandelrelatie. De binding aan de behandelrelatie hieronder beschrijft het **toekomstige** model; die wordt pas werkelijkheid zodra de persoonsgebonden autorisatie is geïmplementeerd.

In het toekomstige model is toegang tot documenten gebonden aan de behandelrelatie:

- **Zorgverleners:** alleen zorgverleners met een geldige behandelrelatie — vastgelegd in het CareTeam (zie [Topic 27](TOP-KT-027-zorgteams.md)) — krijgen toegang tot documenten.
- **RelatedPerson:** personen betrokken bij de behandeling (ouders, mantelzorgers, wettelijk vertegenwoordigers; zie [Topic 26](TOP-KT-026-uitbreiding-rol-van-de-naaste.md)) kunnen beperkte, doelgebonden en tijdgebonden inzage krijgen in documenten. Toegang vervalt automatisch bij het eindigen van de relatie, het intrekken van toestemming of het afsluiten van de behandeling.
- **Logging:** alle inzage en overdracht van documenten wordt gelogd en is auditeerbaar.

Het Koppeltaal-scope-model is gebaseerd op SMART on FHIR v2 scopes met query-parameters (zie [Topic 16](TOP-KT-016-smart-on-fhir-conformiteit.md)). Het patroon `system/Resource.[crud]?param=value` — al toegepast voor `resource-origin` — maakt het mogelijk om in een toekomstige iteratie filtering op bijvoorbeeld `DocumentReference.type` te ondersteunen. De concrete scope-syntax voor DocumentReference wordt vastgelegd in de Koppeltaal-autorisatiematrix (zie [Open punten](#open-punten)).

### Token-validatie en data-owner-verificatie

Wanneer het EPD een externe `attachment.url` aanroept, ontvangt de bronapplicatie een `GET`-request met een Koppeltaal-uitgegeven access_token. De bronapplicatie introspecteert het token bij de Koppeltaal authorization server (zie [Topic 21](TOP-KT-021-token-introspection.md)) en krijgt een set scopes terug. **De regel is:** de scope die het EPD nodig heeft om de DocumentReference te lezen geldt ook als toestemming om het bijbehorende bestand op te halen. Dezelfde permissie dekt zowel metadata als inhoud.

**Data-owner verification** — een succesvolle introspect (`active: true` plus passende scopes) is een **noodzakelijke maar geen voldoende voorwaarde** voor levering. De bronapplicatie MAY na een geldige introspect alsnog toegang weigeren of intrekken op basis van eigen beleid (bijvoorbeeld ingetrokken patiënt-toestemming, bron-specifieke regels, vermoeden van misbruik). In dat geval reageert de bron met `403 Forbidden` en logt de afwijzing zelf.

Twee alternatieven zijn overwogen en niet gekozen:

- **Een nieuwe, expliciete scope voor de documentinhoud** (bijvoorbeeld `documenten/content.read`): zou toegang tot de inhoud loskoppelen van DocumentReference-toegang. **Verworpen omdat het een onduidelijke status institutionaliseert (wel toegang tot de reference, niet tot de data) zonder een gebruiksscenario dat dat onderscheid nodig maakt.**
- **Uitbreiding van het introspect-endpoint met een scope-parameter** (de bron vraagt aan Koppeltaal "mag deze client dit bestand ophalen?"): valt af. [RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662) definieert `/introspect` strikt als token-introspectie en kent geen request-parameters voor een per-resource autorisatiebeslissing. Een policy-decision-point hoort, indien ooit nodig, in een aparte voorziening (UMA-/PDP-pattern), niet in `/introspect`.

### Beschikbaarheidstermijn en levenscyclus

De DocumentReference wordt **niet** na een vaste termijn uit de Koppeltaal FHIR store verwijderd. De 30-dagentermijn is een **beschikbaarheidstermijn van de inhoud**, geen bewaartermijn van de resource:

- **Gedurende 30 dagen na publicatie** (`date`) garandeert de bronapplicatie dat `attachment.url` de inhoud levert. Het EPD moet het document binnen deze termijn detecteren (polling of Subscription) en ophalen; daarna wordt de inhoud niet langer aangeboden.
- **Na afloop van de termijn** verwijdert de bronapplicatie — als `resource-origin`-eigenaar — de `attachment.url` uit de DocumentReference (een reguliere `PUT`/`PATCH`; de *leegmaak-update*). Zij mag het bestand daarna offline halen. De overige attachment-metadata (`contentType`, `title`, `creation`, `size`, `hash`) blijft staan.
- **De DocumentReference zelf blijft bestaan** als metadata-anker — nodig voor de `relatesTo`-verwijzingen bij langlopende versionering (zie [Versionering en versiestreams](#versionering-en-versiestreams)) — en volgt de reguliere patiënt-levenscyclus: zij wordt opgeruimd via het opschoningsproces voor Patient-data, met de `$purge`-cascade als vangnet. Er is geen apart verwijderproces per DocumentReference.

De korte inhoudstermijn weerspiegelt de rol van Koppeltaal als orkestratie- en transportlaag, niet als langetermijn-archief: zodra het document is opgehaald en gearchiveerd in het EPD-dossier, hoeft de inhoud niet meer via de bron beschikbaar te zijn. Dat beperkt het aanvalsoppervlak, voorkomt dat de Koppeltaal-store de facto een tweede dossierstore wordt, en sluit aan op het principe dat de bronhouder verantwoordelijk blijft voor de inhoud.

**FHIR-basis.** De leegmaak-update steunt op de expliciete semantiek van het [Attachment](https://hl7.org/fhir/R4/datatypes.html#attachment)-datatype: alle elementen zijn optioneel (`0..1`), en over het ontbreken van `data` én `url` zegt de specificatie letterlijk: *"If neither data nor a URL is provided, the value should be understood as an assertion that no content for the specified mimeType and/or language is available."* Een attachment zonder `url` en zonder `data` betekent dus precies wat wij willen uitdrukken: het document bestaat (bestond), maar de inhoud is hier niet (meer) beschikbaar. De achterblijvende `hash` en `size` beschrijven de oorspronkelijke inhoud, waardoor de dossierhouder zijn gearchiveerde kopie blijvend kan verifiëren tegen wat de bron destijds heeft aangekondigd.

De levenscyclus in drie fasen:

| Fase | Duur | Inhoud ophaalbaar? | Wie handelt |
| --- | --- | --- | --- |
| **Beschikbaar** | 30 dagen vanaf publicatie (`date`) | Ja — `attachment.url` gegarandeerd | Module publiceert; EPD haalt op en archiveert |
| **Uitgedoofd** | Tot de patiënt-opschoning | Nee — `attachment.url` verwijderd; metadata-anker blijft | Bron voert de leegmaak-update uit en mag het bestand offline halen |
| **Opgeschoond** | — | — | Koppeltaalvoorziening, via het reguliere opschoningsproces voor Patient-data (`$purge`-cascade) |

> De PlantUML-bron van het levenscyclusdiagram is beschikbaar in `input/images-source/documenten-delen-levenscyclus.plantuml`.

Consequenties:

- **De bronapplicatie** behoudt het brondocument in haar eigen omgeving, onafhankelijk van de beschikbaarheidstermijn. De levenscyclus van het brondocument volgt het beleid van de bronhouder.
- **De metadata staat langer in de store** en valt daarmee volledig onder het patiënt-PII-regime: bewaartermijn van 2 jaar na de laatste betrokkenheid, opschoning via het reguliere proces. Dit is consistent met hoe andere patiëntgebonden resources (Task, CareTeam) al behandeld worden.
- **Richtlijn voor metadata-inhoud:** omdat de metadata langer leeft, horen er geen klinische bevindingen in thuis. `title` en overige beschrijvende velden blijven inhoudelijk **neutraal** (bijvoorbeeld "Rapportage interventie", niet een titel die diagnose of uitkomst prijsgeeft). Zie ook [Logische bestandsnaam](#logische-bestandsnaam).
- **Afwijken van de standaard** (langer of korter dan 30 dagen) is in specifieke gebruiksscenario's mogelijk, maar moet expliciet worden vastgelegd in het leveranciersprofiel of een aanvullende afspraak; zo'n afspraak gaat dan over de beschikbaarheidstermijn van de inhoud. Of, en op welk niveau, individuele afwijkingen mogelijk worden gemaakt is nog uit te werken (zie [Open punten](#open-punten)).

### Logische bestandsnaam

Een document heeft in de praktijk een logische bestandsnaam — *Diagnose Jan Jansen — 2024-01-03.pdf* — die de ontvanger wil kunnen tonen en gebruiken bij het archiveren. FHIR heeft daar **geen veld** voor: het Attachment-datatype kent geen bestandsnaam-element, niet in R4 en evenmin in R5. Het dichtstbijzijnde element is `attachment.title`, maar dat is gedefinieerd als weergavelabel (*"a label or set of text to display in place of the data"*), niet als bestandsnaam — en `title` moet juist **inhoudelijk neutraal** blijven omdat de metadata lang leeft (zie hierboven). Een bestandsnaam die de patiëntnaam bevat, hoort dus niet in de blijvende metadata thuis.

De oplossing sluit aan op het levenscyclusmodel: **de bestandsnaam reist met de inhoud mee, niet met de metadata.** Het document-endpoint van de bron geeft de naam mee als `Content-Disposition`-header bij de download ([RFC 6266](https://datatracker.ietf.org/doc/html/rfc6266)):

```http
Content-Disposition: attachment; filename="rapportage.pdf"; filename*=UTF-8''Diagnose%20Jan%20Jansen%20-%202024-01-03.pdf
```

De `filename*`-variant met UTF-8-encoding ([RFC 8187](https://datatracker.ietf.org/doc/html/rfc8187)) ondersteunt diakrieten en spaties; de eenvoudige `filename` dient als ASCII-fallback voor oudere clients. Daarmee bestaat de bestandsnaam precies zo lang als de inhoud beschikbaar is en verdwijnt zij bij het uitdoven — er blijft geen persoonsgegeven achter in de Koppeltaal-store. Het EPD archiveert het bestand onder de meegekregen naam, of onder de eigen dossierconventies. Het meesturen van `Content-Disposition` is voor het document-endpoint een zachte aanbeveling (zie [Beveiligingseisen voor het document-endpoint van de bron](#beveiligingseisen-voor-het-document-endpoint-van-de-bron)).

## Toepassing en restricties

### Workflow

Documenten delen sluit aan op de bestaande Koppeltaal Task lifecycle (zie [Topic 13](TOP-KT-013-levenscyclus-van-een-fhir-resource.md)), maar begint al vóór de toewijzing — bij de publicatie van de `ActivityDefinition` en het herkennen van de uitbreidingscode door het initiërende platform:

| Stap | Beschrijving |
| --- | --- |
| 1. Publiceren `ActivityDefinition` | De module-applicatie publiceert een `ActivityDefinition` met de documenten-delen-uitbreiding in de `useContext` (zie [Aankondiging via de ActivityDefinition](#aankondiging-via-de-activitydefinition)). |
| 2. Inzien en selecteren | De toewijzende applicatie (ECD/EPD) leest de `ActivityDefinition`, herkent aan de `useContext` dat deze interventie een document oplevert, en stelt vast dat zij de te verwachten `DocumentReference` kan verwerken — kan zij dat niet, dan biedt zij de interventie niet aan. |
| 3. Toewijzen | De behandelaar wijst de interventie toe aan de patiënt; een `Task` wordt aangemaakt. |
| 4. Uitvoeren | De patiënt voert de interventie uit via de module. |
| 5. Genereren document | De module genereert een document (bijvoorbeeld een PDF/A) — bij afronding van de interventie of tussentijds. |
| 6. Publiceren `DocumentReference` | De module publiceert een DocumentReference in de Koppeltaal FHIR store, gekoppeld aan de `Patient` en bij voorkeur aan de `Task`. |
| 7. Ophalen en archiveren | Het EPD detecteert de DocumentReference, haalt het document op bij de bron en archiveert het in het patiëntdossier. |

De DocumentReference wordt gekoppeld aan de Patient en bij voorkeur ook aan de Task, zodat het document traceerbaar is naar de specifieke interventie. De Task-koppeling is wenselijk, maar niet verplicht (zie [Aanpassingen aan het DocumentReference-profiel](#aanpassingen-aan-het-documentreference-profiel)).

**Een afgeronde Task is geen voorwaarde.** Een document mag op elk moment in de Task-lifecycle worden gepubliceerd; de Task hoeft hiervoor **niet** de status `completed` te hebben. Zo kunnen ook tussentijdse rapportages worden gedeeld terwijl de interventie nog loopt.

### Aankondiging via de ActivityDefinition

Of een digitale interventie een document oplevert, is voor de toewijzende applicatie niet vanzelfsprekend. Conform het mechanisme van [Topic 25](TOP-KT-025-optionele-uitbreiding-van-de-koppeltaal-standaard.md) kondigt een module-applicatie dit vooraf aan in de `useContext` van de `ActivityDefinition`, met een uitbreidingscode uit het `KoppeltaalExpansion`-codesysteem (hetzelfde patroon als [Topic 26 — Rol van de naaste](TOP-KT-026-uitbreiding-rol-van-de-naaste.md)).

Het voorstel is om hiervoor een nieuwe code op te nemen in het `KoppeltaalExpansion`-codesysteem (`http://vzvz.nl/fhir/CodeSystem/koppeltaal-expansion`):

```text
029-DocumentenDelen — "Documenten Delen"
Met de "Documenten Delen" uitbreiding kunnen applicaties op basis van Taken
voor de patiënt een document door middel van een DocumentReference delen met
andere applicaties in het domein.
```

Een module die documenten oplevert, neemt deze code dan als volgt op in de `useContext` van haar `ActivityDefinition` (illustratief; de code is nog niet vastgelegd):

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

De toewijzende applicatie leest deze `useContext` bij het inzien en selecteren van interventies. Daarmee weet zij **vooraf** dat:

- er op basis van de aangemaakte `Task` een `DocumentReference` in de Koppeltaal FHIR store gepubliceerd zal worden;
- zij in staat moet zijn dit document te verwerken: detecteren (polling of Subscription), ophalen via de externe referentie en archiveren in het dossier.

Een applicatie die documenten delen niet ondersteunt, kan op basis van de `useContext` besluiten de interventie niet aan te bieden of toe te wijzen — net als bij andere optionele uitbreidingen. Zo wordt voorkomen dat een interventie wordt toegewezen waarvan het opgeleverde document vervolgens niet verwerkt kan worden.

Conform het MVP-model van Topic 25 zijn er geen technische controles in het Koppeltaal-stelsel die afdwingen dat de toewijzende applicatie documenten kan verwerken; dit wordt geborgd via acceptatie per uitbreiding en afspraken op zorgaanbieder-domeinniveau.

### Beveiligingseisen voor het document-endpoint van de bron

Om fragmentatie en ongelijke beveiligingsniveaus te voorkomen publiceert Koppeltaal een set eisen voor het document-endpoint dat een bronapplicatie aanbiedt. De eisen worden gesplitst in harde eisen (verplicht; conformance-criterium) en zachte aanbevelingen (best practice; sterk aangeraden maar niet afdwingbaar).

De generieke Koppeltaal-beveiligingseisen uit TOP-KT-008 — Beveiliging aspecten (onder andere: HTTPS-only, JWT-handtekening met asymmetrische algoritmes, security headers zoals `Cache-Control: no-store`, `Strict-Transport-Security`, `X-Content-Type-Options: nosniff` en expliciete `Content-Type`, restrictieve CORS, input-validatie) gelden onverkort ook voor het document-endpoint. De eisen hieronder zijn **aanvullend** en specifiek voor het document-endpoint van de bronapplicatie.

**Hard — verplicht:**

- **TLS-only** (minimaal TLS 1.2, geen klare HTTP)
- **Verplichte token-validatie** (zie [Token-validatie en data-owner-verificatie](#token-validatie-en-data-owner-verificatie)), inclusief afwijzing van requests zonder geldig access_token

**Zacht — aanbevolen:**

- Niet-raadbare paden voor documenten (bijvoorbeeld UUID's of cryptografisch random identifiers; geen incrementele IDs)
- Rate-limiting en standaard hardening (security headers, beperkte error-detail bij 401/403)
- Meesturen van de logische bestandsnaam via `Content-Disposition` (`filename`/`filename*`; zie [Logische bestandsnaam](#logische-bestandsnaam))

### Audit-logging bij de bron

Het ophalen van het bestand loopt niet via Koppeltaal; de **bronapplicatie is verantwoordelijk voor de audit-registratie** van wie/wanneer/welk document. Detail-eisen, AuditEvent-structuur en eventuele uitwisseling met een centrale Koppeltaal-AuditEvent-store worden behandeld in TOP-KT-011 — Logging en tracing en de bijbehorende implementatie-feedback.

## DDL - Eisen (en aanbevelingen) voor documenten delen

> **Let op:** deze eisen volgen de status van dit topic (Concept) en worden definitief vastgesteld samen met het `KT2_DocumentReference`-profiel.

Eisen 1 t/m 10 betreffen het publiceren en versioneren van documenten, eisen 11 t/m 18 het document-endpoint van de bron, eisen 19 t/m 22 het verwerken door de dossierhouder en eisen 23 t/m 24 de levenscyclus.

| # | Eis | Module (bron) | ECD/EPD (dossierhouder) |
| --- | --- | --- | --- |
| 1 | Een module die documenten oplevert MOET de uitbreidingscode voor documenten delen opnemen in de `useContext` van haar `ActivityDefinition`. | X |  |
| 2 | Een applicatie MAG de uitbreidingscode voor documenten delen enkel gebruiken wanneer zij is geaccepteerd voor deze uitbreiding (conform het MVP-model van [Topic 25](TOP-KT-025-optionele-uitbreiding-van-de-koppeltaal-standaard.md)). | X | X |
| 3 | Een gepubliceerde `DocumentReference` MOET voldoen aan het `KT2_DocumentReference`-profiel: `subject` (`1..1`, Koppeltaal Patient), `date` (`1..1`) en `type` (`1..1`). Het koppelen aan de `Task` van de interventie via `context.related` (`0..*`) wordt AANBEVOLEN, maar is niet verplicht. | X |  |
| 4 | De documentinhoud MOET via externe referentie (`content.attachment.url`) worden aangeboden; inline base64 (`attachment.data`) MAG NIET worden gebruikt. Het meegeven van een SHA-1-hash (base64) van de bestandsinhoud via `content.attachment.hash` (`0..1`) wordt AANBEVOLEN (tenzij technisch niet mogelijk), zodat de dossierhouder de integriteit van het opgehaalde bestand kan controleren. | X |  |
| 5 | Het bestand waarnaar een `DocumentReference` verwijst MOET onveranderlijk en self-contained zijn: de inhoud op een gepubliceerde `attachment.url` MAG NIET meer wijzigen. | X |  |
| 17 | Rate-limiting en standaard hardening van het document-endpoint (security headers, beperkte error-detail bij 401/403) worden AANBEVOLEN. | X |  |
| 18 | Het meesturen van de logische bestandsnaam via de `Content-Disposition`-header (`filename`, met `filename*` voor UTF-8) wordt AANBEVOLEN; de bestandsnaam MAG NIET in de blijvende metadata (`attachment.title`) worden opgenomen wanneer zij persoonsgegevens bevat. | X |  |
| 23 | De bronapplicatie MOET na de beschikbaarheidstermijn (standaard 30 dagen na publicatie) de `attachment.url` uit de eigen `DocumentReference` verwijderen (leegmaak-update); de DocumentReference zelf blijft bestaan en volgt de patiënt-opschoning. | X |  |
| 6 | Een nieuwe versie binnen de beschikbaarheidstermijn MOET op een nieuwe URL worden gepubliceerd; de module MOET de bestaande `DocumentReference` bijwerken (`PUT` of `PATCH`) zodat `content.attachment.url` naar de nieuwe versie verwijst. Indien de module een `masterIdentifier` meegeeft, MOET zij die daarbij vernieuwen. | X |  |
| 7 | Een `DocumentReference` MOET ten minste één versie-onafhankelijke reeks-identifier (`identifier`) bevatten, met dezelfde waarde over alle versies in de stream. Het meegeven van een versie-specifieke `masterIdentifier` (bij elke inhoudelijke versie vernieuwd) wordt STERK AANBEVOLEN. | X |  |
| 8 | Een herziening ná de beschikbaarheidstermijn MOET als nieuwe `DocumentReference` worden gepubliceerd, met dezelfde reeks-identifier en een `relatesTo` (code `replaces`) naar de voorganger. `appends` en `transforms` MOGEN worden gebruikt voor addenda respectievelijk bewerkingen; `signs` is toegestaan maar heeft binnen Koppeltaal geen logische functie. | X |  |
| 9 | Een document MAG op elk moment in de Task-lifecycle worden gepubliceerd; een `Task` met status `completed` is geen voorwaarde. | X |  |
| 10 | Er is geen verplicht bestandsformaat; het bestand MOET wel onveranderlijk en self-contained zijn. Voor tekstdocumenten wordt PDF/A AANBEVOLEN. | X |  |
| 11 | Het document-endpoint MOET uitsluitend via TLS (minimaal TLS 1.2) bereikbaar zijn; onversleuteld HTTP MAG NIET worden aangeboden. | X |  |
| 12 | Een `GET` op `attachment.url` MOET de ruwe bestandsinhoud leveren met een `Content-Type` die overeenkomt met `attachment.contentType`. Het document-endpoint is een regulier HTTPS-download-endpoint, geen FHIR-endpoint: `attachment.url` MAG NIET naar een FHIR Binary resource verwijzen. | X |  |
| 13 | Het document-endpoint MOET elk request zonder geldig access_token afwijzen. Token-validatie MOET plaatsvinden via token introspection bij de Koppeltaal authorization server ([RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662); zie [Topic 21](TOP-KT-021-token-introspection.md)); het document MAG pas worden geleverd na een geldige respons (`active: true` plus passende scopes). | X |  |
| 14 | De bronapplicatie MAG na een geldige introspect alsnog toegang weigeren op basis van eigen beleid (data-owner verification). In dat geval MOET zij reageren met `403 Forbidden` en MOET zij de afwijzing zelf loggen. | X |  |
| 15 | De bronapplicatie MOET het ophalen van documenten auditeerbaar registreren (wie, wanneer, welk document). | X |  |
| 19 | De toewijzende applicatie MOET de `useContext` van de `ActivityDefinition` lezen en MAG een interventie met de documenten-delen-uitbreiding alleen aanbieden of toewijzen wanneer zij de resulterende `DocumentReference` kan verwerken. |  | X |
| 20 | De dossierhouder MOET nieuwe en bijgewerkte `DocumentReference`-resources detecteren via polling of een FHIR Subscription op de Koppeltaal-store. |  | X |
| 21 | De dossierhouder MOET bij het ophalen van de documentinhoud een geldig Koppeltaal access_token meesturen (`Authorization: Bearer …`). |  | X |
| 22 | De dossierhouder MOET het document binnen de beschikbaarheidstermijn ophalen en archiveren in het patiëntdossier. |  | X |
| 16 | Het GEBRUIK van niet-raadbare paden voor documenten (UUID's of cryptografisch random identifiers; geen incrementele IDs) wordt AANBEVOLEN. | X |  |
| 24 | Afwijken van de standaard-beschikbaarheidstermijn MOET expliciet worden vastgelegd in het leveranciersprofiel of een aanvullende afspraak. | X | X |

## Open punten

De volgende punten zijn nog uit te werken in samenwerking met leveranciers:

| Open punt | Toelichting |
| --- | --- |
| ValueSet/binding voor `DocumentReference.type` | Welke codes mogen leveranciers gebruiken voor `type`? Opties: LOINC ([valueset-c80-doc-typecodes](https://www.hl7.org/fhir/R4/valueset-c80-doc-typecodes.html), de FHIR R4-default), een Koppeltaal-specifieke ValueSet voor ongestructureerde behandeluitkomsten, of een gelaagde aanpak (LOINC als basis met aanvullende Koppeltaal-codes). Op te nemen in het toekomstige `KT2_DocumentReference`-profiel. |
| Concrete scope-syntax voor DocumentReference in de autorisatiematrix | Het SMART v2 scopes-met-query-patroon (`system/DocumentReference.read?type=…`) moet worden uitgewerkt: welke parameters worden ondersteund, welke combinaties, en hoe verhouden filter-scopes zich tot de generieke `DocumentReference.read`. |
| Uitbreidingscode voor documenten delen | De definitieve codewaarde en het label in het `KoppeltaalExpansion`-codesysteem, naar analogie van `026-RolvdNaaste`; en of documenten delen één enkele uitbreiding vormt of verder verfijnd wordt (bijvoorbeeld onderscheid tussen verplicht en optioneel opleveren van een document). |
| Slice op `context.related` | Of een slice nodig is om de Task-referentie expliciet aan te wijzen (versus andere related resources). |
| Afwijkende beschikbaarheidstermijnen | Of, en op welk niveau (leveranciersprofiel, domeinafspraak), individuele afwijkingen van de standaard-beschikbaarheidstermijn van 30 dagen mogelijk worden gemaakt. |
| Aanreiken van eerdere-document-referentie en reeks-identifier | Bij een herziening door een andere module reikt het EPD de referentie naar het eerdere document en de reeks-identifier aan. Via `Task.input`, de launch-context, of beide? Uit te werken met leveranciers, in samenhang met het `KT2_Task`-profiel. |
| Naamsysteem en formaat van de identifiers | Onder welk `system` geven bronnen de reeks- en versie-identifiers uit (eigen naamsysteem per leverancier, of een Koppeltaal-breed patroon)? |
| Handhaving van de leegmaak-update | Wat als een bron de `attachment.url` na de beschikbaarheidstermijn niet verwijdert? Opties: monitoring/rapportage door de Koppeltaalvoorziening, of een server-side opschoningstaak als vangnet. |
| [Topic 13](TOP-KT-013-levenscyclus-van-een-fhir-resource.md) uitbreiden | De levenscyclus van de DocumentReference (beschikbaar → uitgedoofd → opgeschoond) moet in Topic 13 beschreven worden. |

## Status

Deze pagina beschrijft de oplossingsrichting op hoog niveau. De exacte invulling van profielen, uitwisselingspatronen en autorisatieregels wordt in samenwerking met leveranciers bepaald. Aanvullende inhoudelijke uitwerking volgt uit door de Technical Community aangeleverde documentatie (TC, juni 2026).

## Links naar gerelateerde onderwerpen

| Topic | Beschrijving van relatie met dit onderwerp |
| --- | --- |
| [TOP-KT-005 - Toegangsbeheersing](TOP-KT-005-toegangsbeheersing.md) | Toegang tot de DocumentReference loopt in het huidige model via de applicatie-autorisatiematrix. |
| [TOP-KT-006 - Abonneren op en signaleren van gebeurtenissen](TOP-KT-006-abonneren-op-en-signaleren-van-gebeurtenissen.md) | Het EPD detecteert nieuwe of bijgewerkte DocumentReferences via polling of een FHIR Subscription. |
| TOP-KT-008 - Beveiliging aspecten | De generieke beveiligingseisen gelden onverkort voor het document-endpoint van de bronapplicatie; dit topic voegt endpoint-specifieke eisen toe. |
| [TOP-KT-009 - Overzicht gebruikte FHIR Resources](TOP-KT-009-overzicht-gebruikte-fhir-resources.md) | DocumentReference wordt toegevoegd aan het overzicht van gebruikte resources; de documentinhoud zelf blijft als bestand bij de bron. |
| TOP-KT-011 - Logging en tracing | Audit-registratie van inzage en overdracht van documenten; de bron logt het ophalen van bestanden zelf. |
| [TOP-KT-013 - Levenscyclus van een FHIR Resource](TOP-KT-013-levenscyclus-van-een-fhir-resource.md) | De DocumentReference kent een eigen levenscyclus (beschikbaar → uitgedoofd → opgeschoond). Versionering binnen de beschikbaarheidstermijn verloopt via updates van de DocumentReference (`_history`/`vread`); herzieningen daarna via een nieuwe DocumentReference met `relatesTo`. |
| [TOP-KT-016 - SMART on FHIR Conformiteit](TOP-KT-016-smart-on-fhir-conformiteit.md) | Het scope-model (SMART on FHIR v2, scopes-met-query) bepaalt de toegang tot DocumentReference en daarmee tot de documentinhoud. |
| [TOP-KT-021 - Token Introspection](TOP-KT-021-token-introspection.md) | De bronapplicatie valideert het access_token van het EPD via token introspection bij de Koppeltaal authorization server. |
| [TOP-KT-025 - Optionele uitbreiding van de Koppeltaal standaard](TOP-KT-025-optionele-uitbreiding-van-de-koppeltaal-standaard.md) | Documenten delen is een optionele uitbreiding volgens het mechanisme van Topic 25 (aankondiging via `useContext` op de `ActivityDefinition`). |
| [TOP-KT-026 - Uitbreiding: Rol van de naaste](TOP-KT-026-uitbreiding-rol-van-de-naaste.md) | Zelfde uitbreidingspatroon (`KoppeltaalExpansion`-code in de `useContext`); in het toekomstige autorisatiemodel kunnen RelatedPersons doelgebonden inzage krijgen in documenten. |
| [TOP-KT-027 - Zorgteams](TOP-KT-027-zorgteams.md) | In het toekomstige autorisatiemodel is toegang tot documenten gebonden aan de behandelrelatie, vastgelegd in het CareTeam. |
