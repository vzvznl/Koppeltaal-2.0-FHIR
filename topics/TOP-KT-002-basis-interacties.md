# TOP-KT-002 - Basis interacties

## Versiegeschiedenis

| Versie | Datum       | Status     | Wijzigingen                                                             |
|--------|-------------|------------|-------------------------------------------------------------------------|
| 1.0.2  | 11 Jul 2023 | definitief | Deadlinks opgelost                                                      |
| 1.0.1  | 5 Jul 2023  | definitief | Bij samen voegen van eisen was een fout gemaakt. Deze is hersteld.       |
| 1.0.0  | 29 Mar 2023 | definitief |                                                                         |

---

## Beschrijving

Koppeltaal is een interoperabiliteit standaard. Om op een eenduidige manier gegevens uit te wisselen, dient er een duidelijke beschrijving van de interacties te zijn. De interacties bestaan uit de volgende componenten:

1. Gegevens uitwisselen middels de FHIR resource service
2. Resources zoeken
3. Abonneren op veranderingen
4. Launchen van applicaties

### FHIR resource service

Koppeltaal maakt gebruik van een FHIR resource service. Zie TOP-KT-002a - FHIR Resource Service interacties voor meer informatie.

### Resources zoeken

Er dient een duidelijke specificatie te zijn hoe applicaties kunnen zoeken op resources in de FHIR resource service. Zie TOP-KT-002b - Search interacties voor meer informatie.

### Abonneren op veranderingen

Het abonneren op veranderingen werkt zoals hierboven beschreven. Het is namelijk een `Subscription` resource die op de FHIR resource service aangemaakt wordt. Zie TOP-KT-006 - Abonneren op en signaleren van gebeurtenissen voor meer informatie.

### Launchen

De launch kan op twee manieren uitgevoerd worden. De standaard beschrijft hoe veilig vanuit een applicatie een andere applicatie opgestart kan worden. Zie TOP-KT-007 - Koppeltaal Launch voor meer informatie.

---

## BIA - Eisen (en aanbevelingen) voor Basis interacties

| # | Eis | Applicatie-instantie | FHIR Resource service |
|---|-----|:--------------------:|:---------------------:|
| 1 | Alle FHIR resource service interacties zijn minimaal middels HTTP v1.1 en gebaseerd op de FHIR RESTful API standaard | X | X |
| 2 | Alle requests binnen een domein MOETEN een valide Bearer token bevatten, m.u.v. het `/metadata` endpoint en eventuele andere publiek beschikbare endpoints. Deze kan conform TOP-KT-005c - Applicatie toegang: SMART on FHIR backend services aangevraagd worden. | X | X |
| 3 | Een PUT MOET een `If-Match` header bevatten | X | X |
| 4 | Indien een DELETE request een `If-Match` header bevat, moet deze gevalideerd worden. | | X |
| 5 | De FHIR RESTful API MOET functionaliteit implementeren conform de [specificaties](https://www.hl7.org/fhir/R4B/http.html) | | X |
| 6 | Berichtinhoud MOET voldoen aan en MOET meegegeven worden middels de `Content-Type` header. De waarde van de header MOET met een van de twee waarden gevuld worden: `application/fhir+json` of `application/fhir+xml`. De Content-Type header MAG uitgebreid worden met de FHIR versie en/of de encoding. De encoding MOET altijd utf-8 zijn: `application/fhir+json; fhirVersion=4.0; charset=utf-8` of `application/fhir+xml; fhirVersion=4.0; charset=utf-8` | X | X |
| 7 | Wanneer de `Accept` header gebruikt wordt, MOET de waarde van de header met een van de twee waarden gevuld worden: `application/fhir+json` of `application/fhir+xml`. De Accept header MAG uitgebreid worden met de FHIR versie en/of de encoding. De encoding MAG worden toegevoegd: `application/fhir+json; fhirVersion=4.0; charset=utf-8` of `application/fhir+xml; fhirVersion=4.0; charset=utf-8` | X | X |
| 8 | De encoding van zowel `application/fhir+json` en `application/fhir+xml` MOET altijd utf-8 zijn voor alle resources die vanuit de FHIR resource service komen. Indien een andere encoding wordt meegegeven vanuit de client van de FHIR resource service is het aan de FHIR resource service om een fout te genereren in de 4xx serie, of de encoding te accepteren. Hoewel de FHIR resource service de resources MAG accepteren in een andere encoding dan UTF-8, is de FHIR resource service wel verplicht deze als utf-8 aan te bieden. | X | X |
| 9 | `StructureDefinition` resources worden ALLEEN door Koppeltaal beheerd | | X |
| 10 | Er is GEEN ondersteuning binnen Koppeltaal voor een "whole system interaction search" (TOP-KT-002a - FHIR Resource Service interacties) | | X |
| 11 | Het [Ondersteunde search parameters](TOP-KT-002a-fhir-resource-service-interacties.md) overzicht MOET geimplementeerd zijn | | X |
| 12 | Paginatie MOET ondersteund zijn conform [Http - FHIR v4.0.1](https://www.hl7.org/fhir/R4/http.html) en [Feed Paging and Archiving (RFC5005)](https://tools.ietf.org/html/rfc5005). | | X |
| 13 | De Koppeltaal SearchParameters MOETEN uitvoerbaar zijn | | X |
