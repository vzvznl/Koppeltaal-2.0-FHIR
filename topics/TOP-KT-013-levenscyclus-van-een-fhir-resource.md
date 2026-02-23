# TOP-KT-013 - Levenscyclus van een FHIR Resource

| Versie | Datum       | Status     | Wijzigingen                                                                                   |
|--------|-------------|------------|-----------------------------------------------------------------------------------------------|
| 1.0.1  | 21 Feb 2025 | definitief | RelatedPerson toegevoegd, tekst statussen verduidelijkt, naaste voorbeelden toegevoegd          |
| 1.0.0  | 29 Mar 2023 | definitief |                                                                                               |

## Beschrijving

Voor Koppeltaal maken we gebruik van verschillende resource types. De verschillende resource types gebruiken verschillende elementen om aan te geven of de resource content daadwerkelijk gebruikt en wat de status binnen de levenscyclus is. Dit laatste is extra van belang binnen koppeltaal omdat er gebruik wordt gemaakt van soft-deletes; resources worden in normaal gebruik nooit echt verwijderd, maar door middel van status worden ze op inactief gezet. Hiervoor wordt het element **active** of het element **status** gebruikt. Het element **active** is van het type 'boolean' en het element **status** heeft een lijstje van kiesbare enumeratie waarden. Elk resource in Koppeltaal heeft een active of status veld, en het veld heeft daadwerkelijk een betekenis. Als aanbieder en afnemer van de FHIR resources is het van belang de status van de resource goed te verwerken.

## Overwegingen

### Semantiek

De resources binnen FHIR hebben in sommige gevallen een active veld met een boolean waarde, en in andere resources is er een status veld met een lijst aan mogelijkheden. Aangezien Koppeltaal gebruik maakt van soft-deletes worden deze velden gebruikt om de levenscyclus van de FHIR resources aan te geven. De kernvraag die steeds geldt is welk gedrag er bij welke status hoort. Mag een inactieve gebruiker inloggen? Mag een voltooide taak gestart worden?

### Soft en Hard Delete

In Koppeltaal wordt in normaal gebruik geen gebruik gemaakt van de delete functionaliteit, er wordt door middel van de status of active vlag aangegeven wat de huidige status van de levenscyclus van het FHIR object is. Echter, het gebruik van de delete blijft bestaan binnen koppeltaal in specifieke situaties zoals migraties en beheersscenario's.

## Toepassing, restricties en eisen

### De FHIR specificatie

| Resource           | Element | Waarde          | Betekenis                                                                                 |
|--------------------|---------|-----------------|-------------------------------------------------------------------------------------------|
| ActivityDefinition | status  | draft           | This resource is still under development and is not yet considered to be ready for normal use. |
|                    |         | active          | This resource is ready for normal use.                                                    |
|                    |         | retired         | This resource has been withdrawn or superseded and should no longer be used.              |
|                    |         | unknown         | The authoring system does not know which of the status values currently applies.          |
| Endpoint           | status  | active          | This endpoint is expected to be active and can be used.                                   |
|                    |         | suspended       | This endpoint is temporarily unavailable.                                                 |
|                    |         | error           | This endpoint has exceeded connectivity thresholds and is considered in an error state.   |
|                    |         | off             | This endpoint is no longer to be used.                                                    |
|                    |         | entered-in-error | This instance should not have been part of this patient's medical record.                |
|                    |         | test            | This endpoint is not intended for production usage.                                       |
| Device             | status  | active          | The device is available for use.                                                          |
|                    |         | inactive        | The device is no longer available for use.                                                |
|                    |         | entered-in-error | The device was entered in error and voided.                                              |
|                    |         | unknown         | The status of the device has not been determined.                                         |
| Task               | status  | (zie hieronder) |                                                                                           |
| Patient            | active  | true            | The patients record is in active use.                                                     |
|                    |         | false           | The patients record is not in active use.                                                 |
| Practitioner       | active  | true            | The practitioner's record is in active use.                                               |
|                    |         | false           | The practitioner's record is not in active use.                                           |
| RelatedPerson      | active  | true            | The RelatedPerson record is in active use.                                                |
|                    |         | false           | The RelatedPerson record is not in active use.                                            |
| CareTeam           | status  | proposed        | The care team has been drafted and proposed.                                              |
|                    |         | active          | The care team is currently participating in care.                                         |
|                    |         | suspended       | The care team is temporarily on hold or suspended.                                        |
|                    |         | inactive        | The care team was, but is no longer, participating in care.                               |
|                    |         | entered-in-error | The care team should have never existed.                                                 |
| Organization       | active  | true            | The organization's record is in active use.                                               |
|                    |         | false           | The organization's record is not in active use.                                           |
| Subscription       | status  | requested       | The client has requested the subscription, and the server has not yet set it up.          |
|                    |         | active          | The subscription is active.                                                               |
|                    |         | error           | The server has an error executing the notification.                                       |
|                    |         | off             | Too many errors have occurred or the subscription has expired.                            |

### Statussen van een task

FHIR kent standaard een aantal mogelijke statussen voor een task. In de onderstaande tabel worden die aan Koppeltaal use cases gebonden, waaronder ook de launch.

| Stap                          | Voorbeeld (niet bindend)                                                   | Taak status      | Betekenis                                                              |
|-------------------------------|---------------------------------------------------------------------------|------------------|------------------------------------------------------------------------|
| Interventie kiezen & taak aanmaken | Een behandelaar kiest een interventie voor een patiënt en/of naaste     | draft            | The task is not yet ready to be acted upon.                            |
|                               | Een behandelaar komt erachter dat de taak foutief aangemaakt is.          | entered-in-error | The task should never have existed and is retained only because of the possibility it may have used. |
| Taak toewijzen                | De behandelaar geeft de taak vrij voor patiënt en/of naaste               | ready            | The task is ready to be performed, but no action has yet been taken.   |
| Uitvoeren taak                | De patiënt en/of naaste start(en) met het uitvoeren van de taak           | in-progress      | The task has been started but is not yet complete.                     |
|                               | Er kan iets mis gaan tijdens de uitvoering                                | cancelled        | The task was not completed.                                            |
|                               |                                                                           | on-hold          | The task has been started but work has been paused.                    |
|                               |                                                                           | failed           | The task was attempted but could not be completed due to some error.  |
|                               | De taak is succesvol afgerond                                             | completed        | The task has been completed.                                           |
| Inzien interventie            | Zowel de behandelaar als de patiënt en/of naaste kunnen de interventie inzien. | completed   | The task has been completed.                                           |

### Overige statussen van een task

Wanneer een taak-toekenning wordt beoordeeld door de patiënt of naaste:

| Taak status | Betekenis                                                                     |
|-------------|-------------------------------------------------------------------------------|
| requested   | The task is ready to be acted upon and action is sought.                       |
| received    | A potential performer has claimed ownership of the task and is evaluating whether to perform it. |
| accepted    | The potential performer has agreed to execute the task but has not yet started work. |
| rejected    | The potential performer who claimed ownership of the task has decided not to execute it. |

### Hard Delete

Indien men gebruik maakt van de FHIR **DELETE** operatie wordt er een "logische" verwijdering uitgevoerd. Dat wil zeggen dat men niet meer bij de inhoud van de resource kan komen, en dus ook niet de status van de resource kan bekijken. **Belangrijk** hierbij is dat de gegevens niet fysiek uit de FHIR datastore (database) worden verwijderd.

Een verwijderde resource verschijnt niet langer in de zoekresultaten en pogingen om de resource te lezen zullen falen met een "HTTP 410 Gone" melding met een Location header die een URL bevat met resource id en versie id.

De originele resource inhoud wordt niet verwijderd. Men kan de geschiedenis van de resource nog steeds opvragen:

```
GET Patient/123/_history/1
```

> **Recht op vergetelheid**
>
> In een aantal gevallen mag een gebruiker aan een organisatie vragen om alle (historische) gegevens, van die gebruiker, uit hun systeem te verwijderen. Voor het fysiek verwijderen van resources hebben sommige FHIR Resource Providers een `$expunge` functionaliteit geïmplementeerd. De `$expunge` operatie is echter *GEEN STANDAARD FHIR RESTfull) operatie*, en moet apart geïmplementeerd worden voor de FHIR Store. Deze operatie mag alleen op instance-level aangeroepen worden.

## Voorbeelden

Zie [simplifier](https://simplifier.net/koppeltaalv2.0).
