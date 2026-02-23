# TOP-KT-018 - Multitenancy

| Datum      | Versie | Status     | Wijziging |
|------------|--------|------------|-----------|
| 1 Jun 2023 | 1.0.0  | Definitief |           |

## Beschrijving

In de gegevensuitwisseling met de FHIR service dient duidelijk onderscheid gemaakt te worden welk domein wordt bedoeld. Tevens dienen de OTAP omgevingen (Ontwikkeling, Test, Acceptatie of Productie) duidelijk gescheiden te zijn. Daarom wordt gestreefd naar een multi-tenant architectuur.

> **Let op:** multitenancy is nog niet gerealiseerd in de referentie implementatie.

## Overwegingen

De leverancier van de Koppeltaal voorziening levert deze voor meerdere domeinen.

Voor opslag van gegevens kan de voorziening leverancier kiezen voor opslag van gegevens in één database per domein, of kiezen voor een multi-tenant database met meerdere domeinen per database. Dit is een implementatiekeuze waarin de leverancier vrij is om de kiezen wat het best past binnen de kaders van de standaard en kwaliteitseisen. Beide vormen zijn voorbeelden van multi-tenancy.

Om onderscheid te kunnen maken tussen de verschillende domeinen wordt een identificatie van het domein in de URL opgenomen. Tevens worden aparte baseURLs gedefinieerd voor elke OTAP omgeving.

Voordelen van een multi-tenant architectuur zijn:

- **Kostenreductie.** Met resource pooling, zijn er aanzienlijke besparingen mogelijk op hardware en energie verbruik.
- **Security.** Data zijn logisch gescheiden.
- **Upgrades eenvoudiger.** Eenmalige update op een multi-tenant omgeving. Let op: een update beïnvloedt dus alle tenants.

## Toepassing en restricties

Er zijn meerdere mogelijkheden om multi-tenancy toe te passen. Binnen Koppeltaal is gekozen voor UrlBaseTenantIdentificationStrategy. Hierbij wordt de baseURL uitgebreid met een domeinaanduiding.

De domeinID wordt vastgesteld bij aansluiten van het domein op de koppeltaal voorziening.

## Voorbeelden

De te gebruiken URL's zien er als volgt uit:

- Het OAuth2 endpoint is `<baseURL>/api/v1/<DOMEIN>/oauth2`
- De verschillende resource URLs zijn `<baseURL>/api/v1/<DOMEIN>/fhir/r4/<RESOURCE>`

Waarbij de baseURL een van de volgende zal worden:

- Ontwikkeling: https://ont21.koppeltaal.nl
- Test: https://tst21.koppeltaal.nl
- Acceptatie1: https://acc21.koppeltaal.nl
- Acceptatie2: https://acc22.koppeltaal.nl
- Productie: https://prd2.koppeltaal.nl

## Links naar gerelateerde onderwerpen

- HAPI FHIR multi-tenancy: [multi-tenancy - HAPI FHIR Documentation](https://hapifhir.io/hapi-fhir/docs/server_jpa/multitenancy.html)
