# TOP-KT-009 - Overzicht gebruikte FHIR Resources

## Versiegeschiedenis

| Versie | Datum        | Status     | Wijzigingen                                                                                                                                                                                                                                   |
|--------|--------------|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2.0.3  | 30 Sept 2025 | definitief | Tekstuele wijzigingen om duidelijkheid te scheppen over het feit dat er een set van Koppeltaal profielen bestaat met functionaliteiten die niet voor alle applicaties verplicht is. Expliciet gemaakt dat onderdelen van de profielen horen bij optionele uitbreidingen van de Koppeltaal standaard. Links naar bronnen actueel gemaakt. |
| 2.0.2  | 21 Feb 2025  | definitief | Toevoeging RelatedPerson resource. Toegevoegd aan het functioneel datamodel en de profielen tabel. Wijziging van de paragraaf toepassingen en restricties en de correcte afbeelding is daaraan toegevoegd. Verwijderen van de links naar architectuurbesluiten 11 en 12. |
| 2.0.1  | 20 Mar 2024  | definitief | Toevoeging ImplementationGuide resource                                                                                                                                                                                                       |
| 2.0.0  | 15 Nov 2023  | definitief | Aanpassing instantiatesCanonical naar ext:instantiates                                                                                                                                                                                         |
| 1.0.0  | 27 Feb 2023  | definitief | Geen wijzigingen ten opzichte van laatste concept                                                                                                                                                                                              |
| 0.1.0  | 1 Feb 2023   | concept    |                                                                                                                                                                                                                                               |

---

## Beschrijving

Gegevens worden uitgewisseld tussen verschillende dienstverlenende applicaties. In Koppeltaal staat het begrip applicaties voor alle vormen van ICT-systemen en eHealth platformen die voor een zorgaanbieder relevant zijn om gegevens tussen uit te wisselen in de context van **eHealth activiteiten**. De dienstverlenende applicaties worden geleverd door verschillende **leveranciers**. Deze leveranciers kunnen hun dienstverlenende applicaties ontsluiten via Koppeltaal onder de verantwoordelijkheid van de zorgaanbieder. Alle FHIR resources van een zorgaanbieder kunnen via de **Koppeltaal (FHIR Resource) Provider** ontsloten worden, voor die dienstverlenende applicaties die aangesloten zijn op Koppeltaal. Daarbij maken wij gebruik van gemeenschappelijke begrippen en standaarden die gebaseerd zijn op [HL7/FHIR](https://www.hl7.org/fhir/http.html).

---

## Overwegingen

<!-- Resourcediagram: zie PDF pagina 2-3 voor het volledige FHIR resource relatiediagram -->

### Rol owner

De owner van de `Task` in het diagram hieronder moet een van vier entiteiten zijn: de `Patient`, de `Practitioner`, de `RelatedPerson` of een `CareTeam`. In het geval dat een `CareTeam` een `Task` owner is, dan moet de `CareTeam` de `Patient` als subject hebben. Let op, in het diagram lijkt het dat er vier mogelijke owners zijn van een `Task`, echter in de realiteit heeft elke `Task` maar een owner.

### FHIR standaard

Alle FHIR Resources en de daarbij behorende elementen in Koppeltaal 2.0 zijn gebaseerd op FHIR Release #4 (4.0.1 2019-10-30) - [http://hl7.org/fhir/R4/](http://hl7.org/fhir/R4/).

### Formaten

Bij daadwerkelijke uitwisseling kunnen de FHIR Resources worden weergegeven in XML en/of JSON format.

---

## Koppeltaal profielen

De Koppeltaal 2.0 FHIR profielen zijn in Simplifier.net vastgelegd onder [Koppeltaal v2.0](https://simplifier.net/Koppeltaalv2.0). Deze profielen worden als basis gebruikt voor Koppeltaal.

- De Koppeltaal 2.0 FHIR profielen zijn (hierarchisch) gebaseerd op:
  - a. hl7.fhir.r4.core (4.0.1)
  - b. nictiz.fhir.nl.r4.zib2020 (0.5.0-beta1)
  - c. nictiz.fhir.nl.r4.nl-core (0.5.0-beta1)
- De URL `http://koppeltaal.nl/` is als canonical claim (basis url) voor alle profielen vastgelegd.
- Elk Koppeltaal 2.0 FHIR profiel begint met `KT2_`
- Een Koppeltaal 2.0 profiel is een verklaring over de regels hoe een FHIR resource voor Koppeltaal 2.0 wordt aangemaakt.

Daaraan zijn toegevoegd de profielen:

- `ImplementationGuide`
- `CapabilityStatement`
- `Bundle`
- `OperationOutcome`

Elke resource wordt voorzien van:

- `Metadata`

De `ImplementationGuide`, `CapabilityStatement`, `Bundle` en `OperationOutcome` zijn niet opgenomen in Simplifier, omdat deze resources niet in de FHIR Store worden opgenomen. Via een `Metadata` reference naar de `ImplementationGuide` wordt een overzicht van de beschikbare resource profielen beschikbaar gesteld.

> **Merk op:** Er bestaat een set van Koppeltaal FHIR profielen welke alle profielen bevat voor alle functionaliteiten beschreven in Koppeltaal. Niet alle functionaliteiten (en FHIR resources) zijn verplicht voor alle applicaties. Dit is afhankelijk van de rol die de applicatie vervult, en de gebruikte optionele uitbreidingen (zie Topic 25).

---

## Koppeltaal fundament functionele profielen

De profielen beschreven in de onderstaande tabel zijn een onderdeel van het Koppeltaal fundament.

| Profiel | Omschrijving | User stories | Simplifier |
|---------|-------------|--------------|------------|
| `Patient` | De (FHIR) **Patient** (resource) is een representatie van een persoon die in behandeling is bij de Zorgaanbieder aan wie eHealth activiteiten worden toegewezen. | Opvoeren van een (nieuwe) patient; Aanpassen van patientgegevens; Opvragen van patientgegevens; Zoeken van patientgegevens op basis van identifier | [KT2_Patient](https://simplifier.net/koppeltaalv2.0/kt2_patient) |
| `Practitioner` | De (FHIR) **Practitioner** (resource) is een representatie van een persoon die direct of indirect betrokken is bij het verlenen van gezondheidszorg. | Opvoeren van een (nieuwe) behandelaar; Toevoegen van een email adres van een behandelaar; Opvragen van een behandelaar; Zoeken naar een behandelaar | [KT2_Practitioner](https://simplifier.net/koppeltaalv2.0/kt2_practitioner) |
| `Task` | De (FHIR) **Task** (resource) beschrijft een eHealth taak. Een eHealth taak is een aan een patient toegewezen eHealth activiteit die door een task.owner wordt uitgevoerd. De task.owner is dan de Patient, de Practitioner of de RelatedPerson. | De aanbieder registreert de module als FHIR ActivityDefinition; Een behandelaar selecteert de gewenste eHealth module; Uit een ActivityDefinition wordt via een operation een Task aangemaakt; De eHealth module update de Task resource voor status en resultaten; De RelatedPerson kan owner van een task of subtask zijn | [KT2_Task](https://simplifier.net/koppeltaalv2.0/kt2_task) |
| `ActivityDefinition` | De (FHIR) **ActivityDefinition** beschrijft een eHealth activiteit die beschikbaar is voor toewijzing aan een Patient, Practitioner of RelatedPerson in het kader van de behandeling van een specifieke patient. Bij toewijzing ontstaat een eHealth Taak (Task), waarbij subactiviteiten kunnen worden opgenomen als contained resources die verwijzen naar de hoofdtaak via Task.PartOf. | De eHealth module moet zich authentiseren; Na authenticatie registreert de module zijn activiteit als FHIR ActivityDefinition | [KT2_ActivityDefinition](https://simplifier.net/koppeltaalv2.0/kt2_activitydefinition) |
| `Endpoint` | De (FHIR) **Endpoint** (resource) is een representatie van een technisch contactpunt/adres (URL) van een applicatie instantie die een of meerdere eHealth diensten aanbiedt. Belangrijke informatie is het `Endpoint.address` URL. | Het kunnen activeren en de-activeren van een endpoint. | [KT2_Endpoint](https://simplifier.net/koppeltaalv2.0/kt2_endpoint) |
| `Device` | De (FHIR) **Device** (resource) is een representatie van een gefabriceerd applicatie instantie dat wordt gebruikt bij het verlenen van gezondheidszorg. Het device (of applicatie instantie) kan een medische of niet-medische ondersteunende applicatie zijn. | Het kunnen activeren en de-activeren van het device (applicatie). | [KT2_Device](https://simplifier.net/koppeltaalv2.0/kt2device) |
| `Organization` | De (FHIR) **Organization** (resource) beschrijft de formele eHealth aanbieder of zorginstelling. De Organization resource wordt in de context van Koppeltaal als domein en ondersteuning gebruikt voor andere resources, die naar de eHealth aanbieder verwijst. | Registreren van de eHealth aanbieder in de vorm van een FHIR Organization | [KT2_Organization](https://simplifier.net/koppeltaalv2.0/kt2_organization) |
| `Subscription` | De (FHIR) **Subscription** (resource) is een representatie van een abonnement op bepaalde type gebeurtenissen/wijzigingen op resources. Zodra een Subscription bij de FHIR Resource Provider is geregistreerd, controleert de FHIR Resource Provider elke resource die is aangemaakt en/of bijgewerkt en als de resource overeenkomt met de criteria, stuurt deze een notificatie (zonder payload) naar het gedefinieerde "kanaal". | Abonnement nemen op nieuwe opgevoerde patienten; Volgen of het monitoren van (afgeronde) taken | [KT2_Subscription](https://simplifier.net/koppeltaalv2.0/kt2subscription) |
| `CareTeam` | De (FHIR) **CareTeam** (resource) is een representatie van het zorgteam van alle participanten die deelnemen in het zorgproces van de patient, waarbij de patient het onderwerp is van het team. | Opvoeren van een (nieuwe) patient; Toekennen van patient aan behandela(a)r(en) (registratie behandelrelatie) | [KT2_CareTeam](https://simplifier.net/koppeltaalv2.0/kt2_careteam) |
| `AuditEvent` | De (FHIR) **AuditEvent** (resource) is een representatie van een logrecord van een interactie tussen 2 systemen. Koppeltaal Logging moet het mogelijk maken "achteraf onweerlegbaar vast te stellen welke gebeurtenissen waar en wanneer hebben plaatsgevonden. | Loggen van een gebeurtenis of interactie tussen systemen | [KT2_AuditEvent](https://simplifier.net/koppeltaalv2.0/kt2_auditevent) |

---

## Koppeltaal optionele uitbreidingen profiel

De profielen beschreven in de onderstaande tabel zijn een onderdeel van optionele Koppeltaal uitbreidingen. Zie Topic 25 voor details over optionele uitbreidingen.

| Topic | Profiel | Omschrijving | User stories | Simplifier |
|-------|---------|-------------|--------------|------------|
| TOP-KT-026 - Uitbreiding: Rol van de naaste | `RelatedPerson` | De (FHIR) **RelatedPerson** (resource) is een representatie van een naaste, een persoon die betrokken is bij de zorg voor een patient, maar niet wie in behandeling is bij de Zorgaanbieder, noch formele verantwoordelijkheid heeft in het zorgtraject. | Opvoeren van een (nieuwe) RelatedPerson en deze koppelen aan een bestaande patient; Aanpassen van gegevens; Opvragen van gegevens; Zoeken op basis van identifier; Rol en/of Relatie t.o.v. de Patient toekennen | [KT2_RelatedPerson](https://simplifier.net/koppeltaalv2.0/kt2_relatedperson) |

---

## Toepassing en restricties

In tegenstelling tot de algemene FHIR-regel "*een zender zendt wat hij kan, een ontvanger leest wat hij kan*" is op basis van Architectuur besluit AB.012 afgesproken alleen gebruik te maken van bepaalde velden. Dit om de interoperabiliteit tussen de systemen te bevorderen. In Simplifier is dit aangegeven via de cardinaliteit.

- **Verplicht**: cardinaliteit begint met 1 (1..1 of 1..*)
- **Niet gebruiken**: cardinaliteit is 0..0
- **Optioneel**: cardinaliteit is 0..* (Overige velden)

---

## Eisen

[PRF - Eisen aan FHIR Profielen](PRF-eisen-aan-fhir-profielen.md)

---

## Voorbeelden

Zie Simplifier: [https://simplifier.net/Koppeltaalv2.0](https://simplifier.net/Koppeltaalv2.0)

---

## Links naar gerelateerde onderwerpen

- [Simplifier Koppeltaal](https://simplifier.net/Koppeltaalv2.0)
