# TOP-KT-026 - Uitbreiding: Rol van de naaste

| Versie | Datum      | Status     | Wijziging                                                                        |
|--------|------------|------------|----------------------------------------------------------------------------------|
| 1.1.1  | 7 Oct 2025 | Definitief | Tekstuele wijzigingen doorgevoerd. Samenhang met Topic 25 explicieter gemaakt.    |
| 1.1.0  | 6 May 2025 | Definitief | Topic 26 opgesteld                                                               |
| 0.9    | 4 Dec 2024 | Concept    | Concept versie topic 26 opgesteld                                                |

> **Let op:** De rol van de naaste is een optionele uitbreiding aan de Koppeltaal standaard. Het gebruik van deze is niet verplicht. Zie [Topic 25](TOP-KT-025-optionele-uitbreiding-van-de-koppeltaal-standaard.md) voor meer informatie over het gebruik van optionele uitbreidingen.

## Beschrijving

In het zorgtraject kunnen naasten van de cliënt deelnemen. Een naaste van de cliënt is een persoon anders dan zorgverleners, die betrokken zijn bij de zorg voor de cliënt, zoals familieleden, mantelzorgers, geestelijke verzorgers, voogden en wettelijke vertegenwoordigers. Een naaste doet mee in het zorgtraject door bijvoorbeeld mee te kijken in het dossier van de cliënt, een taak uit te voeren voor of samen met de cliënt. Met gebruik van de `RelatedPerson` resource worden deze functionaliteiten mogelijk gemaakt binnen Koppeltaal. Verder kunnen naasten uit het zorgteam vanuit hun functie ook deelnemen aan het zorgtraject.

## User stories

Met deze uitbreiding worden de volgende user stories mogelijk gemaakt:

- Als zorgondersteuner kan ik een naaste opvoeren en koppelen aan een bestaande cliënt. Ik kan de gegevens van de naaste aanpassen en later opvragen.
- Als zorgverlener kan ik zoeken op digitale interventies die geschikt zijn voor een naaste.
- Als zorgverlener kan ik taken toewijzen aan naaste van mijn cliënt.
- Als naaste van een cliënt kan ik taken uitvoeren bij digitale interventies.

## FHIR Resources

Deze uitbreiding wordt gerealiseerd door toepassing van de `RelatedPerson` resource. Deze resource wordt aanvullend ingezet op de in de basis gedefinieerde resources (zie [Topic 09](TOP-KT-009-overzicht-gebruikte-fhir-resources.md)).

| Profiel        | Omschrijving                                                                                                                                                                                           | Simplifier                                                          |
|----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| RelatedPerson  | De (FHIR) **RelatedPerson** (resource) is een representatie van een naaste, een persoon die betrokken is bij de zorg voor een patiënt, maar niet wie in behandeling is bij de Zorgaanbieder, noch formele verantwoordelijkheid heeft in het zorgtraject. | [Koppeltaal v2.0 \| KT2_RelatedPerson - SIMPLIFIER.NET](https://simplifier.net/koppeltaalv2.0) |

Elke naaste heeft een relatie met een cliënt. Dit wordt in de resource aangegeven door de `RelatedPerson.patient` welke aangeeft aan welke `Patient` de naaste gerelateerd is.

Verder kan een `RelatedPerson` deelnemen aan zorgteam. In dat geval is de `RelatedPerson` opgenomen in het `CareTeam` als `CareTeam.participant`.

## Overwegingen

### Toegangscontroles

In de Koppeltaal standaard wordt niet voorgeschreven hoe de toegangscontrole voor de cliënt en de behandelaar moeten plaatsvinden (zie [Topic 5](TOP-KT-005-toegangsbeheersing.md)). Echter, in geval van de naaste is het noodzakelijk om de toegangscontroles te beschrijven, omdat de toegangsrechten van de naaste vaker zullen wijzigen. Voorbeeld situaties waar de toegangsrechten van naaste wijzigen zijn:

- een kind wordt 16 en haar ouders geen toegangsrechten meer hebben,
- ouders of voogden uit het ouderlijk gezag worden gezet,
- mentorschap of curatele ingaat of juist wordt stopgezet,
- een zorgverlener geen onderdeel meer is van het zorgteam van de cliënt,
- of de cliënt niet langer wil dat de betreffende naaste toegangsrechten heeft.

Hierdoor is het essentieel dat de toegangsrechten actief worden gecontroleerd bij het openen van digitale interventies voor een naaste. Echter, omdat de `RelatedPerson` resource meestal wordt geregistreerd en beheerd door een andere applicatie (typisch het ECD) dan de applicatie waarin de naaste de digitale interventie opent (typisch het cliënten- of naastenportaal), is het controleren van toegangsrechten complexer. Dit betekent dat de status en rol van de `RelatedPerson` heeft met de `Patient` moet worden uitgewisseld tussen applicaties. Afhankelijk van de status en rol van de `RelatedPerson` kan de lancerende applicatie bepalen of de naaste toegang krijgt tot een `Task`. Deze controle moet ook plaatsvinden als een applicatie een actie gaat uitvoeren met betrekking tot de `RelatedPerson`.

De gedetailleerde uitwerking van deze (toegangs)controles is op de onderliggende pagina gedaan, zie [Topic 26a - Controles rol van de naaste](TOP-KT-026a-controles-rol-van-de-naaste.md).

## Eisen

[GRP - Eisen (en aanbevelingen) bij gebruik van een RelatedPerson](GRP)

## Links naar gerelateerde onderwerpen

| Topic                                         | Beschrijving van relatie met dit onderwerp                                                                                         |
|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| TOP-KT-002b - Search interacties              | De `RelatedPerson` is opgenomen als mogelijke search parameter van de `ActivityDefinition`.                                         |
| TOP-KT-009 - Overzicht gebruikte FHIR Resources | De `RelatedPerson` is opgenomen in het datamodel en als FHIR resource.                                                            |
| TOP-KT-011 - Logging en tracing               | De `RelatedPerson` is opgenomen in de logging van de paragraaf User Authentication, Launch en Launched.                            |
| TOP-KT-013 - Levenscyclus van een FHIR Resource | De levenscyclus van een `RelatedPerson` is opgenomen.                                                                             |
| TOP-KT-023 - Identity Provisioning            | De `RelatedPerson` is toegevoegd als mogelijk gebruikerstype.                                                                      |
| IAM - Eisen (en aanbevelingen) voor Identity Provisioning | De `RelatedPerson` is toegevoegd als mogelijk gebruikerstype voor de IDP en op welke identifier van de FHIR resource de identiteit gemapped is. |
