### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-04-20 | Initiële versie                          |

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

- De cliënt wil in het PGO zien welke taken er voor hem klaarstaan (*"Vul vragenlijst A in"*, *"Bekijk video B"*, *"Doe oefening C"*)
- De behandelaar wil taken kunnen volgen, aanvullen en indien nodig handmatig toevoegen
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
2. Er ontstaat een **overkoepelende opdracht** (ServiceRequest) in de CKT-voorziening
3. De module-aanbieder detecteert deze opdracht en **vult deze aan met individuele taken** (B1, B2, B3, ...) voor de cliënt
4. De behandelaar kan ook **handmatig extra taken toevoegen** binnen dezelfde opdracht
5. De cliënt ziet in het PGO alle taken en kan ze individueel uitvoeren
6. Elke taak kan apart worden gelanceerd, gevolgd en afgerond

Het wezenlijke verschil: de module is niet langer een black box, maar een **samenwerkingspartner** die taken aandraagt binnen een door de behandelaar geïnitieerde opdracht.

### 3. Het voorstel: ActivityDefinition.kind als schakelaar

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

#### Wat betekent dit voor de module-aanbieder?

- Bij `AD.kind = Task`: geen verandering. De module ontvangt taken zoals nu.
- Bij `AD.kind = ServiceRequest`: de module moet zich **abonneren op nieuwe ServiceRequests** die naar haar verwijzen, en vervolgens **zelf taken aanmaken** binnen de CKT-voorziening.

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
  <img src="memo-sr-resource-relaties.png" alt="Relaties tussen FHIR resources in de ServiceRequest flow" style="display: block; max-width: 100%; height: auto;"/>
</div>

#### Interactiediagram: ServiceRequest flow (KoppelMij)

<div style="clear: both; margin: 1em 0;">
  <img src="memo-sr-koppelmij-flow.png" alt="ServiceRequest flow in KoppelMij" style="display: block; max-width: 100%; height: auto;"/>
</div>

#### Interactiediagram: huidige Koppeltaal-flow (ter vergelijking)

<div style="clear: both; margin: 1em 0;">
  <img src="memo-sr-koppeltaal-flow.png" alt="Huidige Koppeltaal flow" style="display: block; max-width: 100%; height: auto;"/>
</div>

#### Subscription-mechanisme

De module-aanbieder moet genotificeerd worden over nieuwe ServiceRequests die betrekking hebben op haar ActivityDefinition(s). Dit kan via een FHIR Subscription:

```json
{
  "resourceType": "Subscription",
  "status": "active",
  "reason": "Notificatie bij nieuwe ServiceRequests voor module X",
  "criteria": "ServiceRequest?instantiatesCanonical=https://example.com/ActivityDefinition/module-x",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://module-x.example.com/notifications/servicerequest",
    "payload": "application/fhir+json"
  }
}
```

**Aandachtspunt**: het `instantiatesCanonical` zoekcriterium moet door de CKT-voorziening ondersteund worden als Subscription-criterium. Dit is een uitbreiding ten opzichte van de huidige Koppeltaal-functionaliteit.

#### Launch naar specifieke taak

In het PGO moet de cliënt direct naar een specifieke taak binnen een module kunnen worden gelanceerd. Dit vereist dat de launch-context niet alleen de module identificeert, maar ook de specifieke taak:

- De `launch`-parameter bevat een verwijzing naar de specifieke Task resource
- De module ontvangt via de launch-context welke taak de cliënt wil uitvoeren
- De module toont direct de juiste inhoud (vragenlijst, oefening, video, etc.)

Dit is een verfijning van het bestaande SMART on FHIR launch-mechanisme.

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

- [FHIR ActivityDefinition](https://www.hl7.org/fhir/activitydefinition.html)
- [FHIR ServiceRequest](https://www.hl7.org/fhir/servicerequest.html)
- [FHIR Task](https://www.hl7.org/fhir/task.html)
- [FHIR Subscription](https://www.hl7.org/fhir/subscription.html)
