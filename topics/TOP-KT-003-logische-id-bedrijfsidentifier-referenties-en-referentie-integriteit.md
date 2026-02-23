# TOP-KT-003 - Logische ID, bedrijfsidentifier, referenties en referentie integriteit

| Versie | Datum       | Status     | Wijzigingen                                              |
|--------|-------------|------------|----------------------------------------------------------|
| 1.0.2  | 13 Feb 2024 | Definitief | Wijziging in van toepassing zijnde eisen voor bron applicatie |
| 1.0.1  | 11 Jul 2023 | Definitief | Deadlink opgelost                                        |
| 1.0.0  | 27 Feb 2023 | Definitief |                                                          |

## Beschrijving

Elke resource moet uniek identificeerbaar zijn door de business en technische systemen. Hypermedia/links kunnen hierbij gebruikt worden om referenties of verwijzingen naar resources te gebruiken.

Voor correct gebruik van Identifiers wordt verwezen naar: [IDR - Eisen (en aanbevelingen) voor identifiers en referenties](IDR)

In deze topic wordt onderscheid gemaakt in Logische ID, Bedrijfsidentifier, Referenties en Referentie integriteit.

## Logische ID

### Overwegingen

Elke resource heeft een ID-element dat de "logische ID" (logical ID) bevat. De Logische ID dient uniek te zijn zodat de resource eenduidig terug te vinden is of naar verwezen kan worden. Verder is moet de logische ID een identifier zijn die met voorkeur slecht te raden is en geen probleem vormt bij toekomstige migratie en integraties tussen systemen. Om deze reden stelt koppeltaal dat de logische id een UUID versie 4 (rfc4122) moet zijn.

### Toepassing en restricties

Volgens de FHIR standaard:

- Wanneer een nieuwe resource wordt aangemeld bij de FHIR Resource Provider, geeft de FHIR Resource Provider een nieuwe uniek logische id af binnen het domein van alle resources op dezelfde FHIR Resource Provider.
- Eenmaal toegewezen door de FHIR Resource Provider, wordt de "logische id" NOOIT gewijzigd. Een nieuwe logische ID betekent namelijk een nieuwe resource-instantie.
- De locatie van een resource-instantie is een absolute (locatie) URL die is samengesteld uit het basisadres waarop de instantie is gevonden, het resourcetype en de logische ID, zoals: `https://vzvz.fhir.nl/Patient/d9333b01-4491-42d3-b670-3cedc6c88a00` (waarbij d9333b01-4491-42d3-b670-3cedc6c88a00 de logische id van een patiënt is).
- Wanneer een resource wordt gekopieerd van de ene provider naar een andere provider, kan de kopie al dan niet dezelfde logische id op de nieuwe server behouden. Dit is afhankelijk van replicatie en beleid.

Specifiek voor Koppeltaal:

- De applicaties mogen zelf geen Logische ID's toekennen.
- De logische ID is een UUID (rfc4122), versie 4.

### Voorbeelden

**Patient.id**

```json
{
  "resourceType": "Patient",
  "id": "8474394b-243c-4935-b403-ccc414090bc8",
  ...
}
```

**Opvragen a.d.h.v een Patient.id**

```
GET [base]/Patient/8474394b-243c-4935-b403-ccc414090bc8
```

## Bedrijfsidentifier

### Overwegingen

Een "bedrijfsidentifier" wordt gebruikt om resources uniek te kunnen identificeren met (andere) systemen, die in andere omgevingen aanwezig zijn.

Een patiënt kan bijvoorbeeld geidentificeerd worden aan de hand van een e-mail adres of een patientnummer. Een zorgverlener kan men identificeren via zijn AGB code. Een taak kan men identificeren aan een Taaknummer.

Met de hulp van de "bedrijfsidentifier" kan je altijd achterhalen of de resource instantie al aanwezig en bekend is. Hiermee kan men vervolgens ook de "logische ID" achterhalen, waaronder deze resource instantie bij de FHIR Resource Provider is aangemeld. Daarnaast kan de bedrijfsidentifier gebruikt worden om de relatie tussen de eigen entiteiten en de server weer op te bouwen als deze verloren is geraakt.

Koppeltaal stelt geen eisen aan welke identifiers gebruikt worden, zolang het bronsysteem de resource eenduidig kan relateren.

### Toepassing en restricties

Volgens de FHIR standaard:

- Naast de "logische ID" (logical ID) kan bij de resource ook één tot meerdere "bedrijf identifier" (business identifier) element(en) gebruikt worden.

Specifiek voor Koppeltaal:

- De applicatie die een nieuwe resource instantie creëert en publiceert MOET het bedrijfsidentifier element ([Identifier](http://hl7.org/fhir/R4/datatypes.html#identifier) type) specificeren, als het identifier element in de resource instantie verplicht is.
- Optioneel mogen andere applicaties ook bedrijfsidentifiers toekennen.

### Voorbeelden

**Patient.identifier**

```json
{
  "resourceType": "Patient",
  "id": "8474394b-243c-4935-b403-ccc414090bc8",
  "identifier": [
    {
      "use": "usual",
      "system": "https://irma.app/email",
      "value": "bard.klein@vzvz.nl"
    },
    {
      "use": "official",
      "system": "urn:oid:2.16.840.1.113883.2.4.6.3",
      "value": "123456789"
    }
  ]
}
```

**Opvragen a.d.h.v een Patient.identifier**

```
GET [base]/Patient?identifier=urn:oid:2.16.840.1.113883.2.4.6.3|123456789
```

## Referenties

### Overwegingen

De "logische ID" (logical ID) kan in combinatie met de resource type gebruikt worden als referentie in resources. Dit wordt dan een zogeheten "literal" reference. Zie ook: https://www.hl7.org/fhir/references.html#literal

### Toepassing en restricties

Specifiek voor Koppeltaal:

- De Logische referentie (op basis van bedrijfsidentifier) wordt in Koppeltaal niet gebruikt.

### Voorbeelden

**"Literal" referentie**

```json
{
  "resourceType": "Task",
  "for": {
    "reference": "Patient/8474394b-243c-4935-b403-ccc414090bc8",
    "type": "Patient"
  }
}
```

## Referentie integriteit

De FHIR resource service MOET referentiële integratie afdwingen. Dit houdt in dat er enkel naar resources gerefereerd kan worden indien deze ook daadwerkelijk bestaan in de FHIR resource service. Deze integriteit MOET op zowel "write" als "delete" interacties gewaarborgd worden.

### Write integriteit

Aangezien gerefereerde resources altijd moeten bestaan, is de volgorde van resources aanmaken van belang. Bijvoorbeeld bij het aanmaken van een `Task`, kan dit de volgorde zijn van resources aanmaken:

`Patient` → `Practitioner` → `Endpoint` → `ActivityDefinition` → `Task`

### Logical Delete integriteit

Koppeltaal raadt het [gebruik van logical deletes af](). By default zal het RBAC permissiemodel ook voorkomen dat deze actie uitgevoerd kan worden door applicatie-instanties.

Indien de logical delete toch gebruikt wordt, moet de referentiële integriteit bewaakt worden. De regel is: een referentie MOET refereren naar een bestaand, non-deleted, object.

Zo is het verwijderen van een `Task` vaak simpel, omdat hier nauwelijks naar gerefereerd wordt. In het geval van een `Patient` delete is de kans op integriteitsproblemen veel groter. Een `Task` of een `Practitioner` verwijzen bijvoorbeeld vaak naar een `Patient` resource. Indien een delete niet voldoet aan de referentiële integriteit MOET de server de request afkeuren middels met een `HTTP 409 Conflict`.

### Uitzondering logical delete integriteit

De FHIR resource service maakt gedurende vele interacties automatisch een log aan in de vorm van een `AuditEvent`. Deze kan refereren naar een resource via het `AuditEvent.entity.what` veld. Wanneer de gerefereerde entiteit wordt verwijderd, moet de `AuditEvent` blijven bestaan. De FHIR resource service MOET een uitzondering bouwen in de referentiële integriteit voor het FHIRPath `AuditEvent.entity.what` tijdens een logical delete.

## Eisen

[IDR - Eisen (en aanbevelingen) voor identifiers en referenties](IDR)

## Links naar gerelateerde onderwerpen

- Logische ID: https://www.hl7.org/fhir/resource.html#id
- UUID: https://datatracker.ietf.org/doc/html/rfc4122
- Bedrijfsidentifier: http://hl7.org/fhir/R4/datatypes.html#identifier
- Referentie: https://www.hl7.org/fhir/references.html
