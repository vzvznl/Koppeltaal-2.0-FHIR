# TOP-KT-025 - Optionele uitbreiding van de Koppeltaal standaard

| Versie | Datum      | Status     | Wijzigingen            |
|--------|------------|------------|------------------------|
| 1.0.0  | 7 Oct 2025 | Definitief | Tekstuele wijzigingen  |
| 0.1.0  | 10 Jul 2025 | Concept   | Eerste concept         |

## Beschrijving

Wanneer de Koppeltaal standaard wordt uitgebreid met nieuwe functionaliteiten, is het voor leveranciers niet altijd mogelijk of wenselijk om deze direct te implementeren. Daarom is het optioneel gebruik van uitbreidingen in de Koppeltaal standaard essentieel: zo kan de ontwikkeling van de standaard onafhankelijk plaatsvinden van de implementaties bij leveranciers.

De Koppeltaal standaard bestaat uit een fundament waar alle applicaties aan moeten voldoen. Dit fundament is Koppeltaal v2.0 (Topic 1 tot en met Topic 25) en zorgt ervoor dat alle door Koppeltaal geaccepteerde applicaties aan dezelfde basis eisen voldoen. Daarbovenop kunnen leveranciers kiezen om optionele uitbreidingen te implementeren, waarin aanvullende functionaliteiten zijn vastgelegd. Deze uitbreidingen zijn niet verplicht, maar kunnen naar behoefte worden geïmplementeerd en gebruikt. Zo ontstaat een gemeenschappelijke basis die betrouwbaarheid en interoperabiliteit garandeert, terwijl er tegelijkertijd ruimte blijft voor innovatie en differentiatie.

## Overweging

Met de introductie van optionele uitbreidingen van de Koppeltaal standaard zijn er veel aspecten die van belang kunnen zijn. Er is gekozen voor een minimal viable product (MVP) oplossing om de complexiteit en impact te beperken. De MVP-oplossing omvat:

- De acceptatie van applicaties op het niveau van elke specifieke uitbreiding.
- De `ActivityDefinition` wordt uitgebreid met de optionele parameter [UseContext](https://www.hl7.org/fhir/metadatatypes.html#UsageContext), die aangeeft welke uitbreidingen nodig zijn voor het gebruik van de digitale interventie.
- De definitie van een Koppeltaal code systeem voor in de `UseContext` om met codes verschillende uitbreidingen te kunnen onderscheiden. Applicaties mogen enkel gebruik maken van specifieke codes wanneer zij zijn geaccepteerd voor die uitbreiding.

### Indicatief functioneel interactie model

| Stap | Beschrijving |
|------|-------------|
| 1. Definiëren digitale interventie | In de module applicatie kunnen digitale interventies worden gedefinieerd die mogelijk gebruik maken van optionele uitbreidingen. Wanneer er gebruik wordt gemaakt van een uitbreiding wordt dit aangegeven in de `UseContext` van een `ActivityDefinition`. Wanneer een `UseContext` een uitbreiding bevat is het gebruik van deze verplicht. |
| 2. Registreren digitale interventie | De module applicatie maakt digitale interventies beschikbaar door `ActivityDefinitions` te registreren in de FHIR store. Deze stap is onveranderd onafhankelijk van het gebruik van uitbreidingen. |
| 3. Inzien en selecteren digitale interventies | De ECD applicatie haalt de beschikbare digitale interventies (`ActivityDefinitions`) op. Hierbij kan optioneel een zoekactie worden toegepast op de `UseContext`. De ECD en haar gebruikers (zorgverleners) hebben inzicht in de uitbreidingen die verplicht zijn bij het gebruik van de digitale interventies. De zorgverlener kan op basis hiervan een geschikte digitale interventie selecteren voor haar cliënt. |
| 4. Toewijzen digitale interventie | Een zorgverlener kan in de ECD applicatie de geselecteerde digitale interventie toewijzen aan haar cliënt. Een `Task` wordt aangemaakt op basis van de `ActivityDefinition`. Deze stap is onveranderd onafhankelijk van het gebruik van uitbreidingen. |
| 5. Openen digitale interventie | De cliënt portaal applicatie kan valideren of het voldoet aan de eisen voor de nodige uitbreidingen (door de `UseContext` van de bijhorende `ActivityDefinition` te controleren). Indien de cliënt portaal de nodige uitbreiding(en) ondersteunt kan de digitale interventie gelanceerd worden. |

### Functionaliteit van de MVP-oplossing

- Backwards compatibiliteit. Elke applicatie is in staat om `UseContext` uit te lezen om te kunnen bepalen of de digitale interventie gebruik maakt van uitbreidingen. Wanneer er geen uitbreidingen worden gebruikt zijn geen additionele functionaliteiten van applicaties nodig.
- Afspraken op zorgaanbieder domein niveau over welke specifieke uitbreidingen gebruikt worden in het domein, inclusief ketentesten van de gebruikte uitbreidingen in het domein.
- Afhankelijk van welke uitbreidingen gebruikt worden in een domein, kan dit een impact hebben over het gebruik van specifieke resources, en het Koppeltaal profiel binnen het domein. Zie [Topic 9](TOP-KT-009-overzicht-gebruikte-fhir-resources.md) voor meer informatie over het Koppeltaal FHIR profiel, en de topics van elke uitbreiding voor informatie over specifieke FHIR resources gebruikt in de uitbreiding.
- Elke uitbreiding is met een aparte code geduid (zie het [Overzicht van uitbreidingen](TOP-KT-025a-overzicht-van-koppeltaal-uitbreidingen.md)).
- Mogelijkheid om uitbreidingen te combineren door meerdere codes op te nemen in de `UseContext`. Alle uitbreidingen opgenomen in de `UseContext` zijn verplicht.
- Een methode waarop module applicaties kunnen aangeven welke optionele uitbreidingen nodig zijn per `ActivityDefinition`.
- Een manier waarop ECD applicaties kunnen zoeken op `ActivityDefinition` met specifieke uitbreidingen bij het toewijzen van `Tasks`.
- Mogelijkheid om in `ActivityDefinitions` gebruik te maken van de additionele `UseContext` concepten gespecificeerd in FHIR, zoals Age, Gender.

### Beperkingen van de MVP-oplossing

- Geen technische controles of applicaties juist kunnen omgaan met uitbreidingen in digitale interventies (bij het registreren, toewijzen of openen van digitale interventies). Daarom zijn extra eisen nodig:
  - Bij het registreren van digitale interventies mogen applicaties enkel digitale interventies registreren indien ze geaccepteerd zijn voor alle nodige uitbreidingen.
  - Bij het toewijzen van digitale interventies kan geen controle worden gedaan of andere applicaties geaccepteerd zijn op uitbreidingen. Er bestaat een risico dat een digitale interventie wordt toegewezen die niet geopend kan worden. Dit risico moet worden gemitigeerd worden door afspraken op zorgaanbieder domein niveau. De toewijzende applicatie is niet verantwoordelijk voor het voordoen van dit risico.
  - Bij het openen van een digitale interventie moet de applicatie controleren wat de verplichte uitbreidingen zijn. De digitale interventie mag niet geopend worden wanneer de applicatie hier niet voor is geaccepteerd.
- In het Stelselregister wordt niet vastgelegd welke applicaties zijn geaccepteerd voor welke uitbreidingen, dit moet op domein niveau afgestemd worden.

## Eisen

[OUK - Eisen (en aanbevelingen) optionele uitbreiding van de Koppeltaal Standaard](OUK)

## Links naar gerelateerde onderwerpen

- [TOP-KT-025a Overzicht van Koppeltaal uitbreidingen](TOP-KT-025a-overzicht-van-koppeltaal-uitbreidingen.md)
