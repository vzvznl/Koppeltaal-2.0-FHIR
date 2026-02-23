# TOP-KT-001 - Componenten, Interfaces en Diensten

## Versiegeschiedenis

| Versie | Datum       | Status     | Wijzigingen                                    |
|--------|-------------|------------|------------------------------------------------|
| 1.0.0  | 15 Feb 2023 | definitief | Geen wijzigingen meer sinds laatste versie      |
| 0.1.0  | 11 Nov 2022 | concept    |                                                |

---

## Beschrijving

Koppeltaal bestaat uit een stelsel van Componenten, Interfaces en Diensten (CID) welke bedoeld zijn om de business use case Blended Care (combinatie tussen traditionele therapie en digitale therapie/interventies) te faciliteren. Het stelsel bestaat uit de Koppeltaal voorziening enerzijds en Koppeltaal domeinen anderzijds.

De Koppeltaal voorziening bestaat uit 4 componenten die ieder diensten (services) levert. Elke dienst wordt beschikbaar gemaakt via een interface.

De Koppeltaal domeinen betreft de verschillende zorgaanbieders die hun applicaties aansluiten op de Koppeltaal voorziening teneinde alle informatiestromen tussen (zorg)toepassingen op een veilige manier tot stand te brengen in de context van "Blended Care".

De basis van de Koppeltaal voorziening bestaat uit het beschikbaar maken van de FHIR Store via de FHIR resource service met FHIR R4 RESTful API interface in combinatie met de Autorisatie server via de SMART Backend Interface.

Daarnaast biedt de Koppeltaal voorziening een component voor het registreren van aangesloten applicaties ten behoeve van het Domein beheer en een component voor de logging ten behoeve van de Ketenregie.

<!-- Architectuurdiagram: zie PDF pagina 2 voor het volledige CID-diagram -->

### Koppeltaal 2.0 Stelsel componenten en collaboraties

- **Koppeltaal voorziening**: Alle producten en diensten die nodig zijn om de informatiestromen tussen (zorg)toepassingen op een veilige manier tot stand te brengen in de context van "Blended Care" (combinatie tussen traditionele therapie en digitale therapie/interventies)
- **Koppeltaal domein**: Het geheel van applicatie-instanties onder de verantwoordelijkheid van een zorgaanbieder binnen de juridische kaders van die zorgaanbieder. Applicatie instanties kunnen zijn: instanties van een EPD, een eHealth platform en/of eHealth modules.
- **Applicatie (EPD)**: Electronisch Patienten Dossier.
- **Applicatie (eHealth platform)**: Een platform geeft toegang tot een palet aan gestandaardiseerde informatiesystemen en technologie. Het platform kan gebruik maken van, of diensten verlenen aan een applicatie of eHealth module.
- **Applicatie (portaal)**: Een toegangspoort of -(verzamel)punt tot informatie over een bepaald onderwerp die een gebruiker een uniforme toegang biedt naar achterliggende Stelsel componenten. Het kan ook worden beschouwd als een bibliotheek met gepersonaliseerde en gecategoriseerde inhoud voor een groep personen die toegang krijgen tot functionaliteiten over of het gebruik van activiteiten.
- **Applicatie (eHealth module)**: Is een zelfstandig (software) programma module die rechtstreeks met de gebruikers communiceert en gebruik maakt van de Koppeltaal voorziening om met andere modules gegevens uit te kunnen wisselen, in het zorgproces. Dit betreft bijvoorbeeld een eHealth module. Een eHealth Module is software welke een eHealth toepassing is en dat aangeboden wordt aan clienten zonder tussenkomst van behandelaren, met als doel de gezondheid van de clienten te ondersteunen en te verbeteren.
- **Autorisatieserver**: Stelsel component dat de identiteit van concrete component instanties (diensten) tot stand brengt (en onderhoud en actualiseert) met de daarbij behorende authenticatie middelen. De component besluit vervolgens of een concreet component instantie toegang krijgt tot de FHIR Resource Service.
- **FHIR Store**: Stelsel component die de benodigde gegevens afschermt en reageert op verzoeken om gegevens beschikbaar te stellen en te bewaren met gebruikmaking van toegangstokens.
- **Stelsel log**: Stelsel component die alle uitvoerende handelingen vastlegt, zoals bedoeld in de AVG (Algemene Verordening Gegevensbescherming) en [NEN7513:2018](https://www.nen.nl/nen-7513-2018-nl-245399). Daarnaast wordt er functionaliteit aangeboden om de geregistreerde handelingen te kunnen opvragen.

### Het beheer van de Koppeltaal voorziening gebeurt via de dienst:

- **Beheer service**: Is een beveiligde online omgeving waarin beheerders (technische) configuraties voor Koppeltaal kunnen doorvoeren en beheren, zoals identiteiten, authenticatie middelen en bevoegdheden.

### De Koppeltaal 2.0 Interfaces:

- **FHIR R4 RESTful API**: Via deze interface worden gegevens in de vorm van resources op een consistente manier uitgewisseld op basis van de [HL7 FHIR R4](https://www.hl7.org/fhir/R4B/http.html) specificaties.
- **Notificatiekanaal**: Interface ten behoeve van abonneren en notificeren.
- **SMART Backend Interface**: Een op OAuth2 gebaseerde identificatie van applicaties. OAuth2 (zie [RFC6749](https://tools.ietf.org/html/rfc6749)) is een Open Autorisatie protocol dat gebruikt wordt om toegang te krijgen tot beveiligde resources via FHIR REST API's.
- **HTI + SMART app launch**: Interface om personen een "passend" authenticatie niveau te geven bij een App launch.
- **AppRegistratie**: Via deze interface worden gegevens van een applicatie instantie op een consistente en veilige manier vastgelegd.
- **Stelsellog interface**: Interface voor het raadplegen van de logregel van iedere interactie die binnen het Koppeltaal stelsel heeft plaatsgevonden. Bijvoorbeeld van iedere FHIR REST API interactie maar ook van een launch.

---

## Overwegingen

Voor de gegevensuitwisseling tussen applicatie-instanties en de FHIR store is gekozen voor de internationale standaard HL7 FHIR R4 in combinatie met SMART on FHIR.

SMART on FHIR impliceert dat voor de identificatie, authenticatie en autorisatie gebruik gemaakt wordt van OAuth 2.0 in combinatie met OpenID Connect.

### Specifiek voor Koppeltaal

De Autorisatieserver binnen Koppeltaal authenticeert alleen applicatie's (en geen personen) via de SMART Backend interface. Alleen voor de HTI + SMART App Launch is het in bepaalde gevallen noodzakelijk om personen te identificeren en authenticeren om een voldoende hoog authenticatieniveau te behalen wanneer dit voor het type gegevensuitwisseling nodig is. Aangezien het te behalen authenticatieniveau dus variabel is, is ook de te gebruiken Identity Provider (IdP) variabel. Dit kan de IdP van de zorgaanbieder zelf zijn maar, in bepaalde gevallen, moet dit DigiD zijn.

---

## Toepassing en restricties

De diverse componenten, interfaces en diensten worden in aparte topics uitgewerkt.

---

## Eisen

Zie overige topics.

---

## Links naar gerelateerde onderwerpen

1. FHIR resources, zoals vastgelegd in [Simplifier Koppeltaal v2.0](https://simplifier.net/Koppeltaalv2.0/~resources?fhirVersion=R4)
2. FHIR REST APIs, zoals (generiek) vastgelegd in [HL7 FHIR R4](https://www.hl7.org/fhir/R4B/http.html), en geprofileerd voor Koppeltaal. Zie [Simplifier Koppeltaal v2.0](https://simplifier.net/Koppeltaalv2.0).
3. SMART on FHIR en SMART APP Launch standaarden, zoals vastgelegd in [SMART App Launch](http://hl7.org/fhir/smart-app-launch/index.html)
4. HTI + SMART app launch: [TOP-KT-007 - Koppeltaal Launch](TOP-KT-007-koppeltaal-launch.md)
