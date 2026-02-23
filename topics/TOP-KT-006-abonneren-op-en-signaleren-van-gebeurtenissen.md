# TOP-KT-006 - Abonneren op en signaleren van gebeurtenissen

| Versie | Datum       | Status     | Wijzigingen |
|--------|-------------|------------|-------------|
| 1.0.0  | 22 May 2023 | Definitief |             |

## Beschrijving

Systemen kunnen zich abonneren op specifieke type van gebeurtenissen, zoals het creëren en wijzigen van resources, zodat ze automatisch van dergelijke gebeurtenissen op de hoogte kunnen worden gesteld wanneer ze optreden. Voorbeeld van een gebeurtenis is als een patiënt een activiteit beëindigd dat onderdeel is van een behandeling, zodat de behandelaar hierover geïnformeerd wordt.

## Overwegingen

### Geen payload

Koppeltaal maakt enkel gebruik van het kanaal type `rest-hook` bij het toestaan van Subscriptions, dit omdat de andere typen de notificaties voorzien van inhoud. Aangezien er geen sprake is van autorisatie bij het verzenden van gegevens, en wel bij het ophalen van gegevens, is er voor gekozen enkel deze methode toe te staan. Een keerzijde van deze aanpak is dat de ontvanger van de melding geen zicht heeft op wát er exact veranderd is. Als ontvanger van de notificatie is het de bedoeling een search request uit te voeren op de FHIR resource service waar de wijzigingen worden opgehaald.

### Search Narrowing en Subscription Narrowing

Bij het aanmaken van notificaties wordt dezelfde logica toegepast als bij search narrowing, alleen dan op de `Subscription.criteria` (zie ook: TOP-KT-005a - Rollen en rechten voor applicatie-instanties). De informatie waarop deze wordt toegepast kan verouderd zijn. Echter, omdat de notificatie geen payload bevat, zullen de juiste restricties vanzelf worden toegepast bij het ophalen van de resources.

### Trace headers

In het onderdeel TOP-KT-011 - Logging en tracing wordt besproken hoe de logging en tracing werkt. In het geval van abonneren en signaleren is er specifiek een vereiste rond traceerbaarheid, omdat verschillende gebeurtenissen aan elkaar gerelateerd zijn. Het moet mogelijk zijn deze in de AuditLog records terug te vinden en aan elkaar te correleren.

### Rest-hook endpoint en headers

Het rest-hook endpoint kan in de Subscription voorzien worden van een of meerdere headers die mee wordt gezonden bij de uitvoer aan de rest-hook. Deze zijn nuttig om te differentiëren tussen de verschillende Subscriptions, hoewel dit ook door middel van verschillende URLs kan. Verder is een header nuttig om te voorkomen dat er ongewenst gebruik gemaakt wordt van het endpoint, zoals DDoS aanvallen.

### Events en foutafhandeling

Bij het verzenden van een notificatie wordt een AuditEvent met als code `transmit` aangemaakt door de FHIR resource service. Bij het ontvangen van een notificatie dient er een AuditEvent met als code `recieve` aangemaakt worden door de ontvangende applicatie. Voor meer details zie TOP-KT-011 - Logging en tracing.

Bij het afhandelen van de resources die voortkomen uit het ophalen van de resources kan het gebeuren dat er een resource niet goed verwerkt kan worden. Een voorbeeld is een Patient zonder e-mail adres. Dit mag volgend het FHIR profiel, maar sommige applicaties kunnen hier niet mee overweg. In dit geval moet de applicatie duidelijk maken aan de infrastructuur dat de resource niet verwerkt kan worden. In het onderdeel TOP-KT-012b - FHIR REST Client foutafhandeling wordt besproken hoe het AuditEvent moet worden aangemaakt.

## Toepassing en restricties

### Specifiek voor Koppeltaal

De Subscription in koppeltaal volgt de FHIR Subscription in het Koppeltaal profiel. Hierbij wordt afgeweken van de standaard FHIR Subscription op de volgende punten:

- Het `channel.type` moet altijd `rest-hook` zijn.
- Het `channel.endpoint` moet een een https url zijn, zie ook TOP-KT-008 - Beveiliging aspecten.
- De payload mag nooit gevuld worden.
- Bij het aanmaken van notificaties wordt dezelfde logica toegepast als bij search narrowing.
- De criteria werken hetzelfde als de TOP-KT-002b - Search interacties, zie ook het onderdeel Subscription Criteria.
- De FHIR resource service mag de criteria valideren op validiteit, indien de criteria niet voldoen als valide search query kan het aanmaken van de Subscription met een foutmelding met foutcode in de 400 range worden afgewezen.
- De trace headers spelen een rol bij de uitvoer van het abonnement. Tevens beschreven in TOP-KT-011 - Logging en tracing, bestaan de trace headers uit:
  - X-Request-ID: een unieke ID voor het request.
  - X-Correlation-ID: de X-Request-ID van het bovenliggende request, indien die bestaat.
  - X-Trace-ID: een overkoepelend trace ID, indien aanwezig wordt deze onveranderd meegegeven. Indien niet, mag deze aangemaakt worden.

## De FHIR Subscription

De FHIR Subscription wordt typisch aangemaakt door de applicatie-instantie die updates over resources wil ontvangen. Beheerders van de applicatie-instantie zijn zelf verantwoordelijk voor het aanmaken, up-to-date houden en verwijderen van abonnomenten, er is geen use case vanuit domeinbeheer om de abonnementen te beheren.

Een abonnement is van het type [Subscription](https://www.hl7.org/fhir/subscription.html) resource en bevat standaard de volgende gegevens:

- **Status**: de status van het abonnement
- **Contact**: optioneel een ContactPoint waarmee contact kan worden opgenomen rond het abonnement.
- **End**: optioneel de datum tot wanneer het abonnement geldig is.
- **Reason**: de reden waarom het abonnement is afgenomen.
- **Criteria**: Hierin worden afnemers (of gebruikers) in de gelegenheid gesteld zich te abonneren op specifieke typen van gebeurtenissen, zodat een afnemer op de hoogte wordt gesteld van dergelijke gebeurtenissen. Criteria zijn onderhevig aan dezelfde beperkingen als de client applicatie die het heeft gemaakt.
- **Error**: de laatste error die is voorgekomen bij het uitvoeren van de rest-hook door de server. Dit veld is enkel leesbaar en kan niet gezet worden.
- `channel.type`: altijd de waarde `rest-hook`.
- `channel.endpoint`: Hier wordt het type kanaal en afleverpunt van de notificatie vastgelegd. Er mag alleen gebruik gemaakt worden van (eigen) geregistreerde endpoints van applicatie instanties.
- `channel.header`: nul, één of meerdere headers die bij het uitvoeren van de `rest-hook` worden meegezonden.

## Subscription Criteria

Het is mogelijk om te abonneren op specifieke eigenschappen van resources. Dit geldt voor zowel de standaard FHIR SearchParameters als de custom Koppeltaal SearchParameters. Op deze manier kan bijvoorbeeld geabonneerd worden op changes in alle `Tasks` die gekoppeld zijn aan `ActivityDefinitions` van een specifieke applicatie-instantie.

Zie TOP-KT-002b - Search interacties voor de voorbeelden van deze `SearchParameters`.

## De notificatie in stappen

Een applicatie kan een abonnement op een gebeurtenis aanvragen, opzeggen en opvragen. Als in een systeem, bijvoorbeeld bij een eHealth Module, een nieuwe gebeurtenis plaats vindt, het beëindigen van een activiteit, wordt dit gemeld aan de FHIR Resource Service. De FHIR Resource Service zorgt ervoor dat de gebeurtenis gemeld wordt bij de juiste afhandelaar (het geregistreerde endpoint in de Subscription) door middel van een notificatie te versturen naar dat endpoint.

### Voorbereiding

- De applicatie A maakt een FHIR Subscription aan in de FHIR resource service.

### De uitvoer

1. De applicatie B doet een update op een resource die binnen de search criteria en search narrowing van de Subscription van applicatie A valt, de applicatie A mag de X-Request-ID vullen. Indien niet, vult de FHIR resource service deze in met een nieuwe UUIDv4. Applicatie A mag een X-Trace-ID meesturen, indien afwezig mag de FHIR resource service deze zelf vullen met een UUIDv4.
2. De FHIR resource service maakt een AuditEvent aan zoals beschreven in het onderdeel TOP-KT-011 - Logging en tracing.
3. De FHIR resource service verzendt een request naar de rest-hook. De X-Request-ID is een nieuw UUIDv4, de X-Correlation-ID is de X-Request-ID uit het vorige request. De X-Trace-ID uit de vorige stap moet meegezonden worden als deze aanwezig of aangemaakt is. De FHIR resource service maakt een AuditEvent van met code `transmit` aan.
4. Applicatie A ontvangt het request op de rest-hook URL met de X-Request-ID, X-Correlation-ID en eventueel de X-Trace-ID headers.
5. Applicatie A maakt een AuditEvent van met code `recieve` wordt aan zoals beschreven in onderdeel TOP-KT-011 - Logging en tracing.
6. De applicatie voert een search request uit met dezelfde criteria als de FHIR Subscription, de X-Request-ID is een nieuwe UUIDv4, de X-Correlation-ID is het X-Request-ID uit het vorige request en de X-Trace-ID moet ongewijzigd meegestuurd worden indien deze in het vorige request aanwezig is.
7. De FHIR resource service maakt een AuditEvent aan zoals beschreven in het onderdeel TOP-KT-011 - Logging en tracing.
8. De applicatie A verwerkt de resources, indien er hier een fout zich voordoet, moet er een AuditEvent worden aangemaakt. De waarden in het AuditEvent moeten worden gevuld als beschreven in TOP-KT-012b - FHIR REST Client foutafhandeling, de trace headers dienen gevuld te worden met de waarden van het laatste request naar de FHIR resource service.

## Voorbeelden

**Subscription (Abonnement)**

```json
{
  "meta": {
    "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2Subscription"]
  },
  "resourceType": "Subscription",
  "criteria": "Task?status=completed",
  "reason": "Meld afgeronde taken",
  "status": "active",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://vzvz.koppeltaal.nl/fictief-subscription-test",
    "header": ["X-KTSubscription: UpdateTask"]
  }
}
```

**Notificatie bericht**

```
POST /fictief-subscription-test HTTP/1.1
Content-Type: application/fhir+json; fhirVersion=4.0; charset=utf-8
Content-Length: 0
Host: vzvz.koppeltaal.nl
X-KTSubscription: UpdateTask
```

Dit bericht zal gepost worden op het endpoint zoals in bovenstaande abonnement is weergegeven `https://vzvz.koppeltaal.nl/fictief-subscription-test` met de daar aangegeven extra header informatie X-KTSubscription: UpdateTask

## Eisen

[SIG - Eisen (en aanbevelingen) van het registreren en signaleren van gebeurtenissen](SIG)

## Links naar gerelateerde onderwerpen

- [FHIR Subscription in het Koppeltaal 2.0 profiel](https://simplifier.net/koppeltaalv2.0)
