# TOP-KT-012c - Foutafhandeling bij de launch

| Versie | Datum       | Status  | Wijzigingen                                                                    |
|--------|-------------|---------|--------------------------------------------------------------------------------|
| 1.01   | 14 Mar 2025 | concept | Een alinea is toegevoegd aan deze topic over de te tonen HTTP-foutcodes.       |

## Beschrijving

De ontvanger van een launch is verplicht om het inkomende bericht te valideren en de entiteiten waarnaar het bericht verwijst te kunnen verwerken. Daarnaast voert de autorisatieservice een autorisatie van de gebruiker uit. Op het moment dat er in dit proces iets mis gaat moet, naast dat de gebruiker op de juiste manier geïnformeerd wordt, ook de ander applicatie-instanties in het Koppeltaal domein van deze fout op de hoogte gebracht worden.

## Overwegingen

### Informeren van de eindgebruiker

De eindgebruiker moet worden geïnformeerd over het mislukken van de launch. Hoewel hier de gebruiker geïnformeerd moet worden, moet er spaarzaam omgegaan worden met het verspreiden van technische details. Dit om te voorkomen dat ongewenst technische details over het systeem kenbaar gemaakt worden aan derden.

### Informeren van de infrastructuur

Er is binnen SMART on FHIR app launch of HTI geen methode om een fout in het proces te communiceren met andere applicaties in een domein. Binnen de gangbare workflow is het natuurlijk wel mogelijk met HTTP status codes de gebruiker en de betrokken systemen van een mogelijke fout op de hoogte te brengen. Om de andere applicaties in het domein te informeren over een dergelijke fout maakt koppeltaal gebruik van het AuditEvent.

### Relatie tot logging

Houd er rekening mee dat een succesvolle launch gelogd dient te worden met een AuditEvent, de foutafhandeling is dus een specifieke casus van deze logging.

## Toepassing, restricties en eisen

### Foutpagina

Indien er in de launch iets misgaat zodat de eindgebruiker niet verder kan, wordt de eindgebruiker hierover geïnformeerd met een foutpagina. Deze pagina kan zowel op de ontvangende applicatie als op de autorisatie service voorkomen. Deze pagina bevat geen technische details, echter, het is aan te raden iets van een referentie op de pagina te zetten waarmee de melding van de gebruiker gekoppeld kan worden aan de verdere referenties van de foutmelding in het systeem, zoals de waarden van extension.request-id en/of extension.trace-id.

Verder wordt geadviseerd om aan de foutpagina de van toepassing zijnde HTTP status codes toe te voegen:

- **4xx**: deze range komen fouten voor waarvan de oorzaak bij de aanvrager ligt. De 401 en 403 codes worden gebruikt voor de autorisatie- en authenticatiefouten en liggen vast.
- **5xx**: deze range zou bij normaal gebruik en een stabiele FHIR resource service niet mogen voorkomen. Deze fouten hebben betrekking op de onverwachte fouten aan de server kant.

### De mapping van het AuditEvent

| Veldnaam              | Waarde                                                                                          |
|-----------------------|-------------------------------------------------------------------------------------------------|
| `extension.trace-id`  | De waarde van het `jti` veld uit de HTI token, indien beschikbaar.                              |
| `type`                | `{ "system": "http://dicom.nema.org/resources/ontology/DCM", "code": "110100", "display": "Application Activity" }` |
| `subtype`             | `{ "system": "http://dicom.nema.org/resources/ontology/DCM", "code": "110120", "display": "Application Start" }` |
| `action`              | E                                                                                               |
| `recorded`            | Timestamp van vastlegging, bijvoorbeeld: `2024-02-05T12:06:13+0000`                             |
| `outcome`             | "Verwacht": 4, "Onverwacht": 8. Zie het onderdeel Type fouten uit topic 12b                     |
| `outcomeDesc`         | Een door mensen te begrijpen foutmelding.                                                       |
| `agent.who`           | De client_id van de eigen applicatie: `{ "reference": "Device/<id\|client_id>" }`               |
| `agent.type`          | `{ "coding": { "system": "http://dicom.nema.org/resources/ontology/DCM", "code": "110150", "display": "Application" } }` |
| `agent.requestor`     | `false` (deze applicatie is niet requester)                                                     |
| `entity.what`         | Referentie naar de specifieke Taak: `{ "reference": "Task/<id>/_history/<version>" }`           |
| `source.site`         | Base URL van de applicatie waar het event wordt vastgelegd.                                      |
| `source.observer`     | De device reference van het device dat het event waarneemt: `{ "reference": "Device/<id\|client_id>" }` |
