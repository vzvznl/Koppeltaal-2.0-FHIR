### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-04-13 | Initiële versie                          |
| 0.0.2  | 2026-04-24 | Pad C toegevoegd (Binary in Koppeltaal-store, autorisatie via bestaande matrix) |

---

### Resultaten delen

De inzet van eHealth en blended care is breed ingebed in de zorg. Digitale interventies leveren waardevolle resultaten op — zoals vragenlijsten, scores en voortgangsinformatie — die essentieel zijn voor goede behandelbeslissingen. In de praktijk zijn deze resultaten echter vaak opgesloten binnen afzonderlijke applicaties, wat leidt tot informatieversnippering en extra administratieve lasten.

Door resultaten delen expliciet te ondersteunen binnen Koppeltaal ontstaat een uniforme en gestandaardiseerde manier om interventieresultaten veilig en geautoriseerd over te dragen van de bronapplicatie (module) naar de dossierhouder (EPD). Hierbij wordt aangesloten op bestaande MedMij- en Nictiz-standaarden. Koppeltaal fungeert als orkestratie-, transport- en autorisatielaag — niet als opslagsysteem.

### Typen resultaten

#### Documenten (DocumentReference)

Ongestructureerde resultaten zoals PDF/A-rapporten, vragenlijstuitkomsten of samenvattingen worden uitgewisseld via het FHIR [DocumentReference](https://www.hl7.org/fhir/documentreference.html) resource. Een DocumentReference bevat metadata over het document (type, datum, auteur, patiënt) en een verwijzing naar een [Binary](https://www.hl7.org/fhir/binary.html) resource met het daadwerkelijke document.

Waar de Binary wordt opgeslagen verschilt per uitwisselingspatroon: bij Pad A en Pad B blijft de Binary bij de bronapplicatie en bevat de DocumentReference een externe referentie; bij Pad C wordt de Binary in de Koppeltaal FHIR store geplaatst. Zie de sectie [Uitwisselingspatronen](#uitwisselingspatronen) voor de afweging tussen deze patronen.

De module genereert automatisch een PDF/A bij afronding van de interventie. PDF/A is het vereiste formaat voor duurzame archivering in het EPD.

#### Gestructureerde resultaten (Observation)

Gestructureerde, meetbare uitkomsten — zoals scores, metingen of gecodeerde antwoorden — worden uitgewisseld via het FHIR [Observation](https://www.hl7.org/fhir/observation.html) resource. Observations bieden een gestandaardiseerde manier om resultaten machineleesbaar vast te leggen, inclusief codering (bijv. SNOMED CT, LOINC) en eenheden.

QuestionnaireResponse-resultaten (zoals ingevulde vragenlijsten) kunnen eveneens via dit mechanisme worden overgedragen.

### Uitwisselingspatronen

Er zijn drie paden voor het overdragen van resultaten van de module naar het EPD:

#### Pad A: Direct ophalen via Koppeltaal FHIR store

In dit patroon publiceert de module een DocumentReference in de Koppeltaal FHIR store. Het EPD detecteert de nieuwe DocumentReference — via polling of een FHIR Subscription — en haalt vervolgens het daadwerkelijke document (Binary) op bij de bronapplicatie.

<div style="clear: both; margin: 1em 0;">
{% include resultaten-delen-pad-a.svg %}
</div>

Pad A kent de minste orkestratie — er is geen aparte Notification Task — maar het EPD moet zelf detecteren dat er nieuwe resultaten beschikbaar zijn (via polling of een Subscription), en de bronapplicatie moet een beveiligd Binary-endpoint aanbieden. Voor de implementatielast bij bron en consument is Pad A daarmee niet eenvoudiger dan Pad C (zie hieronder).

#### Pad B: Notified Pull

In het Notified Pull patroon — gebaseerd op de [TA Notified Pull v1.0.1](https://www.nictiz.nl/) — neemt de module het initiatief door het EPD actief te notificeren dat er resultaten klaarstaan. Dit gebeurt via een Notification Task.

<div style="clear: both; margin: 1em 0;">
{% include resultaten-delen-pad-b.svg %}
</div>

De Notification Task bevat verwijzingen naar de op te halen FHIR resources (DocumentReference, Binary). Het EPD haalt op eigen initiatief en tempo de data op bij de bron.

**Voordelen van Notified Pull ten opzichte van Pad A:**

- **Actieve notificatie**: het EPD hoeft niet te pollen of een eigen Subscription-implementatie te onderhouden; de module signaleert wanneer er iets klaarstaat
- **Volume-controle aan consumentzijde**: het EPD bepaalt zelf op welk moment en in welk tempo de data daadwerkelijk wordt opgehaald uit de aangeboden set
- **Identificatie bij ophalen**: de ontvanger identificeert zich bij het ophalen aan de bronapplicatie, waardoor inzichtelijk is wie de data raadpleegt (mits die authenticatie is ingericht — zie bezwaren bij Pad C hieronder)

#### Pad C: Directe deling via de Koppeltaal FHIR store

Pad A en Pad B gaan beide uit van Binary-opslag bij de bronapplicatie. Dat heeft drie praktische nadelen:

1. **Adressering lastig door onbekende Device-referenties**: er is geen praktisch werkbaar mechanisme om een document aan een specifieke ontvangende applicatie toe te wijzen. Applicaties kennen elkaars `Device`-referenties binnen het domein doorgaans niet en mogen deze ook niet ophalen, waardoor de bronapplicatie in Pad B niet weet welke `Device`-id bij het beoogde EPD hoort. In Pad A ontbreekt zelfs dit adresseringsmechanisme. Pad C omzeilt dit door deling via de autorisatiematrix, zonder dat partijen elkaars `Device`-referenties hoeven te kennen.
2. **Bronapplicatie als FHIR-server**: elke bronapplicatie moet een eigen, beveiligd FHIR-endpoint aanbieden voor de Binary — inclusief OAuth-flow, scope-enforcement, audit-logging, search-parameters en versie-onderhandeling. Dat betekent effectief een FHIR-server nabootsen naast Koppeltaal. Een toekomstige FHIR-versie (R5, R6) vereist aanpassingen bij iedere bronapplicatie.
3. **Vertrouwen van binnenkomende requests**: de bronapplicatie moet verifiëren dat een inkomend `GET Binary` afkomstig is van een legitieme, gemachtigde ontvanger — en niet van een willekeurige partij die de referentie heeft onderschept. Dat vereist minimaal JWT-validatie van een Koppeltaal-uitgegeven access_token (via een introspection-endpoint of JWKS-handtekeningcontrole), interpretatie van de scope-claims ter plaatse, en synchronisatie met de autorisatiematrix die in Koppeltaal wordt beheerd. De huidige specificatie benoemt dit mechanisme niet. Zonder expliciete invulling is de Binary-endpoint bij de bronapplicatie effectief een open endpoint, of elke leverancier implementeert zijn eigen (mogelijk afwijkende) vertrouwensmodel — met fragmentatie en security-risico's tot gevolg.

In Pad C wordt de Binary zelf in de Koppeltaal FHIR store geplaatst (naast de DocumentReference). Koppeltaal fungeert als tijdelijk doorgeefluik: de bronapplicatie publiceert, ontvangende applicaties halen op via een echt FHIR-endpoint, en na succesvolle archivering bij de dossierhouder kunnen DocumentReference en Binary opgeruimd worden.

Autorisatie verloopt via het bestaande Koppeltaal autorisatiemodel: de permissies uit de autorisatiematrix (zie [TOP-KT-005b Rollen Matrix](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27125119/TOP-KT-005b+-+Rollen+Matrix)) worden vertaald naar SMART scopes in het access_token en afgedwongen bij search en read. Daarmee wordt expliciet per applicatie bepaald welke documenten toegankelijk zijn, zonder dat bronapplicaties zelf een eigen OAuth- of resource-server hoeven te implementeren.

**Voordelen van Pad C:**

- **Expliciete deling per applicatie zonder Device-referenties**: de autorisatiematrix bepaalt centraal welke applicaties resources mogen ophalen, zonder dat partijen elkaars `Device`-referenties hoeven te kennen of zelf autorisatielogica hoeven te implementeren
- **Echt FHIR-endpoint**: clients gebruiken standaard FHIR-operaties (search, read) op de Koppeltaal-server; bronapplicaties hoeven geen FHIR-server na te bootsen
- **Toekomstbestendig bij FHIR-versiewijzigingen**: upgrades (R4 → R5 → R6) raken alleen de Koppeltaal-server, niet iedere bronapplicatie
- **Eén autorisatie-laag**: clients gebruiken hun bestaande access_token voor Koppeltaal; geen tweede OAuth-flow naar een bronapplicatie
- **Centrale token-validatie en introspectie**: JWT-validatie, introspection en scope-enforcement gebeuren op één plek (de Koppeltaal FHIR store), in plaats van dat elke bronapplicatie een eigen vertrouwensmodel moet implementeren en onderhouden
- **Automatische AuditEvents (NEN 7510)**: de Koppeltaal-standaard schrijft voor dat de Koppeltaal-store bij elke search- en read-actie automatisch een AuditEvent-resource aanmaakt. Daarmee wordt de traceerbaarheid die NEN 7510 vereist centraal geborgd, zonder dat elke bronapplicatie een eigen audit-implementatie hoeft te onderhouden
- **Opruim-permissie via matrix**: applicaties kunnen delete-permissie krijgen om na archivering de DocumentReference en Binary op te ruimen, waarmee dataminimalisatie in de Koppeltaal-store wordt geborgd

**Uitbreidbaarheid: fijnmaziger autorisatie**

De initiële invulling van Pad C werkt op resource-type-niveau: de matrix bepaalt welke applicaties `DocumentReference` en `Binary` mogen lezen. Deze basis kan later stapsgewijs worden uitgebreid:

- **Category-gebonden scopes**: `DocumentReference.category` kan als filter aan scopes worden toegevoegd, zodat per soort document (bijvoorbeeld `behandelresultaat`, `tussentijdse-rapportage`, `overdrachtsdocument`) verschillende applicaties geautoriseerd worden.
- **FHIRPath-gebonden scopes**: FHIRPath-expressies aan matrix-regels toevoegen om op *individueel* resource-niveau te delen — bijvoorbeeld alleen documenten binnen een bepaalde behandelepisode, Task of CareTeam-context, of om tijdgebonden toegang uit te drukken. FHIRPath in scopes is geen onderdeel van de huidige SMART-specificatie en zou een Koppeltaal-eigen uitbreiding zijn.

Een dergelijke uitbreiding zou mooi aansluiten op de SMART App Launch-koers die voor KoppelMij (de combinatie van Koppeltaal 2.0 en MedMij) wordt uitgewerkt: een gelaagd autorisatiemodel van resource-niveau via category-niveau naar FHIRPath-niveau. Pad C landt op het eerste niveau en is ontworpen om naar de hogere niveaus mee te kunnen groeien zonder architectuurwijziging.

**Positionering ten opzichte van "data aan de bron":**

Het uitgangspunt "data aan de bron" past bij inzage-scenario's waarbij de ontvanger alleen raadpleegt zonder duurzame kopie — bijvoorbeeld een live medicatielijst of gestructureerde data via een Koppeltaal launch. Resultaat delen is echter per definitie een overdrachts-scenario: de dossierhouder moet het document duurzaam archiveren (bijvoorbeeld 20 jaar bewaarplicht), waardoor er hoe dan ook een kopie bij de ontvanger ontstaat. In dit scenario is dataminimalisatie beter gediend met *"tijdelijke doorvoer via Koppeltaal, duurzame opslag bij dossierhouder"* dan met *"permanent bij bronapplicatie"*.

### Workflow

Resultaat delen is het sluitstuk van de bestaande Koppeltaal Task lifecycle:

1. De behandelaar wijst een interventie toe aan de patiënt (Task wordt aangemaakt)
2. De patiënt voert de interventie uit via de module
3. De interventie wordt afgerond (Task.status → `completed`)
4. De module genereert het resultaat (PDF/A en/of Observation)
5. De module deelt het resultaat via pad A, pad B of pad C
6. Het EPD haalt het resultaat op en archiveert het in het patiëntdossier

De DocumentReference wordt gekoppeld aan zowel de Patient als de Task, zodat het resultaat traceerbaar is naar de specifieke interventie.

### Autorisatie

Toegang tot resultaten is gebonden aan de behandelrelatie:

- **Zorgverleners**: alleen zorgverleners met een geldige behandelrelatie — vastgelegd in het CareTeam — krijgen toegang tot resultaten
- **RelatedPerson**: personen betrokken bij de behandeling (ouders, mantelzorgers, wettelijk vertegenwoordigers) kunnen beperkte, doelgebonden en tijdgebonden inzage krijgen in resultaten. Toegang vervalt automatisch bij het eindigen van de relatie, het intrekken van toestemming of het afsluiten van de behandeling
- **Logging**: alle inzage en overdracht van resultaten wordt gelogd en is auditeerbaar

### Status

Deze pagina beschrijft de oplossingsrichting op hoog niveau. De exacte invulling van profielen, uitwisselingspatronen en autorisatieregels wordt in samenwerking met leveranciers bepaald.
