# TOP-KT-012b - FHIR REST Client foutafhandeling

## Beschrijving

In de interactie met de FHR REST API kunnen zich, naast de fouten die zich voordoen aan de serverzijde, er zich ook fouten voordoen bij de verwerking van de resources door de cliënt van de FHIR REST API. Het is van belang deze fouten te melden, omdat anders de infrastructuur ervan uit kan gaan dat het clientsysteem de informatie correct verwerkt heeft, of correct kan verwerken. De foutafhandeling door de client bestaat uit het aanmaken van een AuditEvent, hiermee maakt de applicatie duidelijk aan de andere applicaties en de beheerder van het domein dat er iets niet goed is gegaan. Het type AuditEvent maakt duidelijk wat er exact aan de hand is. Een applicatie kan een FHIR resource om verschillende redenen niet verwerken. Dit onderscheid is belangrijk, omdat sommige fouten verwacht kunnen zijn en geen aandacht van een beheerder vereisen, terwijl andere type fouten onverwacht zijn en aandacht vereisen.

## Overwegingen

### Grijze gebieden in het FHIR profiel

Bij het vaststellen van het FHIR profiel is er een ultieme inspanning gedaan deze enkel en eenduidig te houden. Echter, bij een klein aantal velden is er een onmogelijkheid voorgekomen; in een bepaalde situatie bleek een veld totaal niet van toepassing, terwijl het in een andere situatie juist verplicht bleek. De leveranciers hebben hierover gestemd en besloten dat de koppeltaal infrastructuur er vanuit moet gaan dat het veld in deze situatie niet verplicht is, en applicaties, ook degene die het veld vereisen, hiermee om moeten gaan.

### Onverwerkbare informatie

Naast het grijze gebied in het FHIR profiel doet zich nog een ander probleem voor. Het FHIR profiel legt vast welke velden kunnen worden verwacht, en wat de inhoud van de velden is. Dit voorkomt niet dat in de verwerking van de velden zich er een probleem voordoet. Het kan zo zijn dat een veld illegale inhoud kent, bijvoorbeeld een illegaal e-mail adres, postcode of telefoonnummer. De validatieregels van de applicatie kunnen nu eenmaal strenger zijn dan Koppeltaal en het FHIR profiel deze stelt.

### Verwacht vs. onverwacht, herstelbaar vs onherstelbaar (repareerbaar)

Een verwachte fout doet zich voor als men redelijkerwijs kan voorspellen dat een fout zich voordoet. Een onverwachte systeemfout kan men niet verwachten. Dit onderscheid is belangrijk, omdat onverwachte systeemfouten aandacht vereisen van de rest van de applicaties in het domein, en verwachte fouten niet.

Een verwerkingsfout die voortkomt uit tijdelijke problemen in de infrastructuur kan hersteld worden door de resource op een ander moment opnieuw proberen te verwerken. Een fout die voortkomt uit een validatiefout of ontbrekend veld kan niet hersteld worden door het opnieuw aanbieden van dezelfde versie van de resource.

### Informeren

Het doel van de foutafhandeling aan de kant van de cliënt van de FHIR resource service is informeren. De cliënt moet in staat zijn de andere applicaties in het domein ervan op de hoogte te stellen dat de applicatie de resource niet goed verwerkt heeft.

## Toepassing, restricties en eisen

### Aanleiding

De aanleiding van het aanmaken van een AuditEvent van dit type is een fout die zich voordoet in een van de applicaties, niet fouten die zich voordoen bij de interacties met de FHIR resource service. Typisch komen de fouten voor in de volgende situaties:

- Het verwerken van resources die zijn opgehaald bij de FHIR resource service in het eigen systeem.
- De verwerking van FHIR resources betrokken in een update ontvangen uit een abonnement (subscriptie, Subscription).
- Het doen van een launch tussen applicaties en de uitwisseling van gegevens en FHIR resources die hierbij betrokken zijn.

### Type fouten

In koppeltaal gaan we ervan uit dat er drie type fouten zich kunnen voordoen aan de zijde van de client:

|                     | Tijdelijke fout | Gegevensverwerkingsfout | Terminale fout |
|---------------------|-----------------|-------------------------|----------------|
| onverwacht/verwacht | onverwacht      | verwacht                | onverwacht     |
| herstelbaar         | ja              | nee                     | nee            |

1. **Een tijdelijke fout**: het systeem van de client kan de resource tijdelijk niet goed verwerken. De verwachting is dat dit in een later stadium wel kan. De client is verantwoordelijk voor het correct verwerken van de resource in een later stadium.
2. **Een gegevensverwerkingsfout**: het systeem kan een resource niet verwerken omdat er iets in de gegevens ontbreekt of incorrect is. Deze valt in de categorie voorspelbaar.
3. **Een terminale fout**: het systeem van de cliënt kan de resource niet goed verwerken, en de verwachting is dat dit in de toekomst ook niet kan. Dit type fout is onverwacht.

### De mapping van het AuditEvent

| Veldnaam                   | Waarde                                                                                              |
|----------------------------|-----------------------------------------------------------------------------------------------------|
| `extension.request-id`     | De waarde van de betrokken X-Request-Id veld.                                                       |
| `extension.correlation-id` | De waarde van de betrokken X-Correlation-Id veld.                                                   |
| `extension.trace-id`       | De waarde van de betrokken X-Trace-Id veld.                                                         |
| `type`                     | `{ "system": "http://terminology.hl7.org/CodeSystem/audit-event-type", "code": "rest" }`            |
| `subtype`                  | Afhankelijk van het type actie, bv. `{ "system": "http://hl7.org/fhir/restful-interaction", "code": "read" }` |
| `action`                   | R (Afhankelijk van het type actie die wordt uitgevoerd)                                              |
| `recorded`                 | Timestamp van vastlegging, bijvoorbeeld: `2024-02-05T12:06:13+0000`                                 |
| `outcome.code`             | "Verwacht": 4, "Onverwacht": 8                                                                      |
| `outcomeDesc`              | Een door mensen te begrijpen foutmelding.                                                           |
| `agent.who`                | De client_id van de eigen applicatie: `{ "reference": "Device/<id\|client_id>" }`                   |
| `agent.type`               | `{ "coding": { "system": "http://dicom.nema.org/resources/ontology/DCM", "code": "110150", "display": "Application" } }` |
| `agent.requestor`          | `true` (Deze applicatie is de requester)                                                            |
| `entity.what`              | Referentie naar de specifieke resource en versie: `{ "reference": "<ResourceType>/<id>/_history/<version>" }` |
| `entity.query`             | De betrokken query, indien van toepassing. De query wordt base64 geëncodeerd opgeslagen.             |
| `source.site`              | Base URL van de applicatie waar het event wordt vastgelegd.                                          |
| `source.observer`          | De device reference van het device dat het event waarneemt.                                          |

### Het fouttype

| | Tijdelijke fout | Gegevensverwerkingsfout | Interne fout |
|---|---|---|---|
| AuditEvent.type | transmit | transmit | transmit |
| AuditEvent.outcome | 4 of 12 | 4 | 8 |

Audit event outcome codes (`http://hl7.org/fhir/audit-event-outcome`):

| Code | Display        | Definition                                                                                |
|------|----------------|-------------------------------------------------------------------------------------------|
| 0    | Success        | The operation completed successfully (whether with warnings or not).                      |
| 4    | Minor failure  | The action was not successful due to some kind of minor failure (often equivalent to an HTTP 400 response). |
| 8    | Serious failure | The action was not successful due to some kind of unexpected error (often equivalent to an HTTP 500 response). |
| 12   | Major failure  | An error of such magnitude occurred that the system is no longer available for use (i.e. the system died). |

## Eisen

- Een client van de FHIR resource service MOET een AuditEvent aanmaken indien deze niet in staat is de gegevens van de FHIR resource service als door het domein wordt verwacht te verwerken.
- Het applicatie moet de relevante waarden van X-Request-Id, X-Correlation-Id, en X-Trace-Id uit het originele request in het AuditEvent meesturen.
- De POST request headers moet een nieuw X-Request-Id bevatten, de waarde van het X-Correlation-Id als de X-Trace-Id meegeven volgen de standaard regels rond het vullen van deze waarden.
- De mapping uit het onderdeel De mapping van het AuditEvent is van toepassing op de inhoud van het AuditEvent object.
