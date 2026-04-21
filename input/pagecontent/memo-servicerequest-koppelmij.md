### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-04-20 | Initiële versie                          |
| 0.0.2  | 2026-04-21 | Feedback verwerkt: centraal overzicht benadrukt, scope-notitie behandelaar, FHIR workflow-aansluiting, COW IG referentie |
| 0.0.3  | 2026-04-21 | Impact op ECD en patiëntportaal toegevoegd |

---

### Memo: ServiceRequest als orkestratiemiddel in KoppelMij

| | |
|---|---|
| **Datum** | 2026-04-20 |
| **Status** | Concept |
| **Auteur** | Roland Groen |

---

### 1. Aanleiding

In Koppeltaal wordt een digitale interventie (module) als geheel toegewezen aan een cliënt. De behandelaar zegt in feite: *"Patiënt X gaat werken met module Y."* De module is daarbij een ondeelbaar geheel — het EPD weet niet welke individuele taken er binnen de module bestaan, en de patiënt ziet de module als één activiteit.

In KoppelMij is deze granulariteit onvoldoende. Het Persoonlijke Gezondheidsomgeving (PGO) fungeert als het portaal van de cliënt — vergelijkbaar met het patiëntportaal in Koppeltaal. Cliënten en behandelaars willen de **individuele taken binnen een module** zichtbaar hebben:

- De cliënt wil in het PGO **in één oogopslag een overzicht van taken van verschillende zorgaanbieders** — zonder eerst in afzonderlijke modules te moeten kijken. Dit centrale overzicht geeft rust en duidelijkheid voor de cliënt. Dit is ook de oplossingsrichting die bijvoorbeeld DigiZorg kiest om aan te sluiten bij de gebruikersbehoefte.
- De behandelaar wil vanuit het ECD inzicht in welke concrete taken een cliënt uitvoert binnen een module en hoe ver hij hiermee is, zonder daarvoor naar losse modules te moeten navigeren. *Opmerking: deze behoefte wordt door de gekozen oplossingsrichting technisch mogelijk gemaakt, maar valt buiten de huidige scope van het KoppelMij-project (dat zich richt op beschikbaarheid in het PGO). Uitbreiding naar het ECD vereist interne afstemming en bespreking met de stuurgroep.*
- Het PGO moet de cliënt direct naar een specifieke taak binnen een module kunnen launchen

Dit betekent dat het proces van taakaanmaak fundamenteel anders werkt dan in Koppeltaal.

### 2. Wat verandert er?

#### Huidige situatie (Koppeltaal)

In Koppeltaal is het proces eenvoudig en lineair:

1. De behandelaar wijst module Y toe aan de patiënt
2. Er ontstaat één taak in de Koppeltaalvoorziening
3. De patiënt opent de module en werkt alles af
4. De module rapporteert het resultaat terug

De behandelaar heeft geen zicht op wat er *binnen* de module gebeurt. De module is een black box.

#### Gewenste situatie (KoppelMij)

In KoppelMij wordt het proces uitgebreider en collaboratief:

1. De behandelaar vraagt een interventie aan voor de cliënt (bijv. *"Start behandelprogramma B"*)
2. Er ontstaat een **overkoepelende opdracht** (ServiceRequest) in de Centrale Koppeltaal (CKT) voorziening
3. De module-aanbieder detecteert deze opdracht en **vult deze aan met individuele taken** (B1, B2, B3, ...) voor de cliënt
4. De behandelaar kan ook **handmatig extra taken toevoegen** binnen dezelfde opdracht
5. De cliënt ziet in het PGO alle taken en kan ze individueel uitvoeren
6. Elke taak kan apart worden gelanceerd, gevolgd en afgerond

Het wezenlijke verschil: de module is niet langer een black box, maar een **samenwerkingspartner** die taken aandraagt binnen een door de behandelaar geïnitieerde opdracht.

### 3. Het voorstel: ActivityDefinition.kind als discriminator

#### ActivityDefinition in Koppeltaal

Een ActivityDefinition (AD) beschrijft *wat* een module kan doen — het is het sjabloon op basis waarvan taken worden aangemaakt. Elke module-aanbieder registreert één of meer ADs in de Koppeltaalvoorziening.

In de huidige Koppeltaal-specificatie is het veld `ActivityDefinition.kind` niet gevuld. Impliciet geldt `kind = Task`: het aanmaken van een instantie van deze AD leidt tot precies één taak.

#### Voorstel: twee typen ActivityDefinitions

Door het veld `ActivityDefinition.kind` expliciet te vullen, kan de module-aanbieder aangeven welk type flow de module ondersteunt:

| `AD.kind` | Betekenis | Flow |
|-----------|-----------|------|
| `Task` (of leeg) | Module werkt op taakniveau | EPD maakt één taak aan per toewijzing. Huidige Koppeltaal-werkwijze. |
| `ServiceRequest` | Module werkt op opdrachtniveau | EPD maakt een ServiceRequest aan. De module luistert op nieuwe ServiceRequests en vult deze aan met taken voor de cliënt. |

Dit is een **hybride model**: beide typen kunnen naast elkaar bestaan. Een module-aanbieder kan zowel ADs van type `Task` als van type `ServiceRequest` aanbieden. KoppelMij geeft aan dat `AD.kind = ServiceRequest` **noodzakelijk** is voor de gewenste cliëntbeleving in het PGO.

#### Aansluiting op FHIR Workflow

Het gekozen patroon sluit aan op de [FHIR Workflow](https://www.hl7.org/fhir/workflow.html) specificatie:

- **ServiceRequest** beschrijft de *intentie* of *opdracht*: wat er moet gebeuren — vergelijkbaar met een order, eventueel als onderdeel van een CarePlan
- **Task** beschrijft de *concrete uitvoering* van deze opdracht, inclusief status (`requested`, `accepted`, `in-progress`, `completed`)

Het aansluiten op internationale standaarden is één van onze uitgangspunten. Door nu het patroon (Service)Request → Task te hanteren, leggen we een fundament dat in lijn is met de FHIR Workflow en voorbereid is op toekomstige uitbreidingen:

- **Projectfase 2**: (Service)Request → Task → Observation — het delen van resultaten (scores, meetwaarden) die voortkomen uit de uitgevoerde taken
- **Verdere toekomst**: uitbreiding met CarePlan als overkoepelend behandelplan, en andere typen Requests zoals DeviceRequest en MedicationRequest

De HL7 [Clinical Order Workflow (COW) IG](https://build.fhir.org/ig/HL7/fhir-cow-ig/en/workflow-patterns.html) beschrijft patronen voor het coördineren van orders tussen een *Placer* (besteller) en *Filler* (uitvoerder), waaronder het gebruik van een *Coordination Task* om de onderhandeling over wie een ServiceRequest gaat invullen te faciliteren. In onze context gaan we ervan uit dat deze onderhandeling reeds heeft plaatsgevonden: de module-aanbieder is bekend en de toewijzing is overeengekomen. We sluiten aan bij het COW-patroon in zoverre dat we starten met een overeengekomen ServiceRequest met `Task.basedOn` als verbinding naar de taken. De Coordination Task — bedoeld voor het onderhandelingsproces tussen Placer en Filler — valt buiten onze scope.

#### Wat betekent dit voor de module-aanbieder?

- Bij `AD.kind = Task`: geen verandering. De module ontvangt taken zoals nu.
- Bij `AD.kind = ServiceRequest`: de module moet een ActivityDefinition **publiceren met `kind = ServiceRequest`**, zich **abonneren op nieuwe ServiceRequests** die naar deze AD verwijzen, en vervolgens **zelf taken aanmaken** binnen de Centrale Koppeltaal (CKT) voorziening.

#### Wat betekent dit voor de ECD-aanbieder?

- **ServiceRequest aanmaken**: bij het toewijzen van een interventie met `AD.kind = ServiceRequest` moet het ECD een ServiceRequest aanmaken in plaats van (of naast) een Task
- **Koppeling met taken**: het ECD moet de relatie tussen de ServiceRequest en de onderliggende taken inzichtelijk maken. Deze informatie zit mogelijk impliciet al in het ECD (bijv. als behandelplan of interventietoewijzing), maar moet nu expliciet gekoppeld worden aan de FHIR-resources in de Centrale Koppeltaal (CKT) voorziening
- **Meerdere ServiceRequests**: het ECD moet meerdere actieve ServiceRequests per cliënt kunnen beheren, elk met hun eigen set aan taken

#### Wat betekent dit voor de patiëntportaal-aanbieder?

- **Groepering van taken**: taken worden niet langer als losse items getoond, maar gegroepeerd onder hun ServiceRequest. De cliënt ziet bijvoorbeeld *"Behandelprogramma B"* met daaronder de individuele taken B1, B2, B3
- **UX-wijziging**: dit vereist een aanpassing in de gebruikersinterface — van een platte takenlijst naar een gestructureerd overzicht met niveaus (ServiceRequest → taken)

### 4. Technische uitwerking

#### Betrokken FHIR resources

| Resource | Rol |
|----------|-----|
| `ActivityDefinition` | Sjabloon van de module; `kind` bepaalt de flow |
| `ServiceRequest` | Overkoepelende opdracht van behandelaar aan module |
| `Task` | Individuele taak voor de cliënt, gebonden aan de ServiceRequest |
| `Patient` | De cliënt |
| `Practitioner` | De behandelaar |
| `Subscription` | Mechanisme waarmee de module nieuwe ServiceRequests detecteert |

#### Relaties tussen resources

<div style="clear: both; margin: 1em 0;">
{% include memo-sr-resource-relaties.svg %}
</div>

#### Interactiediagram: ServiceRequest flow (KoppelMij)

<div style="clear: both; margin: 1em 0;">
{% include memo-sr-koppelmij-flow.svg %}
</div>

#### Interactiediagram: huidige Koppeltaal-flow (ter vergelijking)

<div style="clear: both; margin: 1em 0;">
{% include memo-sr-koppeltaal-flow.svg %}
</div>

#### Link naar ActivityDefinition: extensie `instantiates`

In Koppeltaal wordt op de Task een custom extensie [`instantiates`](http://vzvz.nl/fhir/StructureDefinition/instantiates) gebruikt om te verwijzen naar de ActivityDefinition. Deze extensie is destijds geïntroduceerd omdat het standaard FHIR-element `Task.instantiatesCanonical` niet bruikbaar bleek als zoekcriterium. Er is een bijbehorende [SearchParameter](http://koppeltaal.nl/fhir/SearchParameter/task-instantiates) gedefinieerd die zoeken op deze extensie mogelijk maakt.

Het voorstel is om dezelfde `instantiates` extensie **symmetrisch op de ServiceRequest** toe te passen. Hiermee:

- Wordt de verwijzing van ServiceRequest naar ActivityDefinition op dezelfde manier geïmplementeerd als bij Task
- Kan een vergelijkbare SearchParameter worden gedefinieerd voor ServiceRequest
- Wordt het zoek- en Subscription-criterium gebaseerd op een bewezen mechanisme

#### Subscription-mechanisme

De module-aanbieder moet genotificeerd worden over nieuwe ServiceRequests die betrekking hebben op haar ActivityDefinition(s). Dit kan via een FHIR Subscription op basis van de `instantiates` extensie:

```json
{
  "resourceType": "Subscription",
  "status": "active",
  "reason": "Notificatie bij nieuwe ServiceRequests voor module X",
  "criteria": "ServiceRequest?instantiates=ActivityDefinition/module-x",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://module-x.example.com/notifications/servicerequest",
    "payload": "application/fhir+json"
  }
}
```

**Opmerking**: dit vereist een nieuwe SearchParameter voor de `instantiates` extensie op ServiceRequest, analoog aan de bestaande [`task-instantiates`](http://koppeltaal.nl/fhir/SearchParameter/task-instantiates) SearchParameter.

### 5. Open vragen

#### Wie wordt de requester van de taken?

Wanneer de module taken aanmaakt binnen een ServiceRequest, is de vraag wie de `Task.requester` wordt:

- **De behandelaar** — logisch vanuit zorgperspectief (de behandelaar heeft de interventie aangevraagd), maar de module kent de behandelaar mogelijk niet direct
- **De module-aanbieder** — technisch correct (de module maakt de taak aan), maar functioneel misleidend
- **Overgenomen van de ServiceRequest** — de `Task.requester` wordt overgenomen van `ServiceRequest.requester`. Dit lijkt het meest consistent: de behandelaar is en blijft de opdrachtgever, ook voor de individuele taken

#### Kan een ServiceRequest taken van meerdere module-aanbieders bevatten?

Het huidige voorstel gaat uit van één module-aanbieder per ServiceRequest. Maar het is denkbaar dat een behandelprogramma taken bevat die door **verschillende modules** worden aangeboden:

- Module A levert vragenlijsten
- Module B levert video-oefeningen
- Module C levert psycho-educatie

In dat geval zou de ServiceRequest een **samengestelde opdracht** worden, met taken van meerdere module-aanbieders. Dit heeft consequenties voor:

- **Subscription**: meerdere module-aanbieders moeten dezelfde ServiceRequest ontvangen
- **Autorisatie**: elke module-aanbieder moet taken kunnen aanmaken binnen dezelfde ServiceRequest
- **Afsluiting**: wanneer is de ServiceRequest `completed`? Als alle taken van alle modules zijn afgerond?

Dit scenario verhoogt de complexiteit aanzienlijk en vereist nadere uitwerking.

#### Hoe verhoudt zich dit tot de bestaande Task lifecycle?

De bestaande Koppeltaal Task lifecycle (requested → accepted → in-progress → completed) blijft van toepassing op de individuele taken. Maar de ServiceRequest introduceert een **bovenliggende lifecycle**:

- ServiceRequest `active`: er kunnen nog taken worden toegevoegd
- ServiceRequest `completed`: alle taken zijn afgerond, geen nieuwe taken meer
- ServiceRequest `revoked`: de opdracht is ingetrokken

De relatie tussen de Task-lifecycles en de ServiceRequest-lifecycle moet eenduidig worden gedefinieerd.

### 6. Referenties

- [FHIR Workflow](https://www.hl7.org/fhir/workflow.html)
- [Clinical Order Workflow (COW) IG](https://build.fhir.org/ig/HL7/fhir-cow-ig/en/workflow-patterns.html)
- [FHIR ActivityDefinition](https://www.hl7.org/fhir/activitydefinition.html)
- [FHIR ServiceRequest](https://www.hl7.org/fhir/servicerequest.html)
- [FHIR Task](https://www.hl7.org/fhir/task.html)
- [FHIR Subscription](https://www.hl7.org/fhir/subscription.html)
