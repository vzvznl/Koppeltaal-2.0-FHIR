### Changelog

| Versie | Datum      | Wijziging                                                                                                            |
|--------|------------|----------------------------------------------------------------------------------------------------------------------|
| 0.0.4  | 2026-01-16 | Fallback "Overige relaties" toegevoegd voor onbekende FHIR/SNOMED rollen                                             |
| 0.0.3  | 2026-01-13 | Naaste en Buddy: Task rechten gewijzigd van R naar RU                                                                |
| 0.0.2  | 2026-01-13 | Terminologie "rol" gewijzigd naar "relatie"; "Geen relatie in CareTeam" toegevoegd                                   |
| 0.0.1  | 2026-01-13 | Eerste versie autorisatiematrix RelatedPerson met relaties Naaste, Mantelzorger, Wettelijk vertegenwoordiger en Buddy |

---

### Autorisatieregels voor RelatedPerson toegang

Deze pagina beschrijft de autorisatieregels voor RelatedPersons binnen het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

#### Scope en overwegingen

Deze autorisatiematrix beschrijft de rechten voor RelatedPersons binnen de context van behandeltaken. De volgende onderwerpen vallen buiten de huidige scope:

- **Zelfhulp taken**: Het aanmaken van zelfhulp taken door RelatedPersons (met name de Wettelijk vertegenwoordiger) is nog niet uitgewerkt. In een toekomstige versie kan dit worden toegevoegd, vergelijkbaar met hoe Patiënten zelfhulp taken kunnen aanmaken.

- **Patiënt/RelatedPerson context**: Het launch type **Patiënt/RelatedPerson context** is bedoeld voor portal applicaties (zoals een patiëntportaal) en niet voor module applicaties. Deze wordt meegenomen in de autorisatiematrix ter volledigheid en omdat deze in de toekomst van toepassing wordt.

#### Context en Launch types
De onderstaande autorisatieregels gelden voor **alle launch types** waarbij een RelatedPerson betrokken is:

1. **Patiënt/RelatedPerson context**: Wanneer de RelatedPerson inlogt en toegang krijgt tot geautoriseerde resources (portal context)
2. **Taak context (eigen taak)**: Wanneer de RelatedPerson een eigen taak start
3. **Taak context (patiënt taak)**: Wanneer de RelatedPerson een taak van de patiënt start

#### Relaties voor RelatedPerson

Er wordt onderscheid gemaakt tussen de volgende relaties:

| Relatie                         | Omschrijving                      | Bevoegdheden                                               |
|:--------------------------------|:----------------------------------|:-----------------------------------------------------------|
| **Geen rol in CareTeam**        | Niet opgenomen in CareTeam        | Alleen eigen taken                                         |
| **Naaste**                      | Algemene naaste/verwant           | Meekijken, ondersteunen, communiceren                      |
| **Mantelzorger**                | Structurele zorgverlener          | Meekijken, uitvoeren (beperkt), ondersteunen, communiceren |
| **Wettelijk vertegenwoordiger** | Juridisch gemachtigd              | Meekijken, uitvoeren, namens patiënt handelen              |
| **Buddy**                       | Ervaringsdeskundige begeleider    | Meekijken, ondersteunen, communiceren                      |
| **Overige relaties**            | Onbekende of niet-gedefinieerde relatie | Alleen eigen taken                                   |

**Toelichting bevoegdheden:**

| Bevoegdheid             | Betekenis                                                                      |
|:------------------------|:-------------------------------------------------------------------------------|
| Meekijken               | Leestoegang tot relevante patiëntgegevens en voortgang                         |
| Ondersteunen            | Actief bijdragen aan het zorgproces door begeleiding en motivatie              |
| Communiceren            | Berichten uitwisselen met het zorgteam                                         |
| Uitvoeren (beperkt)     | Beperkte acties uitvoeren zoals taken afronden namens de patiënt               |
| Uitvoeren               | Volledige acties uitvoeren namens de patiënt                                   |
| Namens patiënt handelen | Juridisch gemachtigd om beslissingen te nemen en te handelen namens de patiënt |

**Let op:** Deze relaties zijn indicatief en moeten nog worden vastgesteld door de visiegroep en tech community.

#### Autorisatieregels

De onderstaande tabellen tonen de verschillende autorisatieniveaus voor RelatedPersons.

##### Overzicht Task autorisaties per relatie

De Task en Task Launch rechten zijn direct gekoppeld aan de bevoegdheden per relatie:

| Relatie                         | Eigen taak | Patiënt taak | Eigen taak starten | Patiënt taak starten |
|---------------------------------|------------|--------------|--------------------|----------------------|
| **Geen rol in CareTeam**        | RU         | -            | ✓                  | -                    |
| **Naaste**                      | RU         | -            | ✓                  | -                    |
| **Mantelzorger**                | RU         | R            | ✓                  | -                    |
| **Wettelijk vertegenwoordiger** | RU         | RU           | ✓                  | ✓                    |
| **Buddy**                       | RU         | -            | ✓                  | -                    |
| **Overige relaties**            | RU         | -            | ✓                  | -                    |

**Toelichting:**
- **Eigen taak**: Taken waar de RelatedPerson eigenaar van is
- **Patiënt taak**: Taken die voor de patiënt zijn aangemaakt (door behandelaar)
- **Overige relaties**: Fallback voor FHIR/SNOMED relaties die niet in bovenstaande categorieën vallen

##### Geen relatie in CareTeam

Deze RelatedPersons hebben toegang tot resources primair via Task toewijzingen. Dit is de huidige situatie waarin RelatedPersons niet zijn opgenomen in een CareTeam.

| Entiteit               | Toegang                                    | CRUD   | Search Narrowing                                                |
|------------------------|--------------------------------------------|--------|-----------------------------------------------------------------|
| **Patient**            | Als de RelatedPerson.patient de Patient is | R      | `Patient?_has:RelatedPerson:patient:identifier=system\|user_id` |
| **Practitioner**       | Geen                                       | -      | N.v.t.                                                          |
| **RelatedPerson**      | Geen                                       | -      | N.v.t.                                                          |
| **CareTeam**           | Geen                                       | -      | N.v.t.                                                          |
| **ActivityDefinition** | Geen                                       | -      | N.v.t.                                                          |
| **Task**               | Eigen taken                                | RU     | `Task?owner=RelatedPerson/{id}`                                 |
| **Task Launch**        | Eigen taken                                | Launch | `Task?owner=RelatedPerson/{id}`                                 |

##### Naaste

De Naaste heeft leestoegang en kan ondersteunen en communiceren, maar kan geen acties uitvoeren namens de patiënt.

| Entiteit               | Toegang                                    | CRUD   | Search Narrowing                                                       |
|------------------------|--------------------------------------------|--------|-----------------------------------------------------------------|
| **Patient**            | Als de RelatedPerson.patient de Patient is | R      | `Patient?_has:RelatedPerson:patient:identifier=system\|user_id` |
| **Practitioner**       | Via CareTeam lidmaatschap                  | R      | `Practitioner?_has:CareTeam:participant:participant=RelatedPerson/{id}` |
| **RelatedPerson**      | Via CareTeam lidmaatschap                  | R      | `RelatedPerson?_has:CareTeam:participant:participant=RelatedPerson/{id}` |
| **CareTeam**           | Als ik lid van het CareTeam ben            | R      | `CareTeam?participant=RelatedPerson/{id}`                       |
| **ActivityDefinition** | Geen                                       | -      | N.v.t.                                                          |
| **Task**               | Eigen taken                                | RU     | `Task?owner=RelatedPerson/{id}`                                 |
| **Task Launch**        | Eigen taken                                | Launch | `Task?owner=RelatedPerson/{id}`                                 |

##### Mantelzorger

De Mantelzorger is een structurele zorgverlener met uitgebreidere rechten. Kan beperkt uitvoeren namens de patiënt.

| Entiteit               | Toegang                                      | CRUD   | Search Narrowing                                                                                               |
|------------------------|----------------------------------------------|--------|---------------------------------------------------------------------------------------------------------|
| **Patient**            | Als de RelatedPerson.patient de Patient is   | R      | `Patient?_has:RelatedPerson:patient:identifier=system\|user_id`                                         |
| **Practitioner**       | Via CareTeam lidmaatschap                    | R      | `Practitioner?_has:CareTeam:participant:participant=RelatedPerson/{id}`                                 |
| **RelatedPerson**      | Via CareTeam lidmaatschap                    | R      | `RelatedPerson?_has:CareTeam:participant:participant=RelatedPerson/{id}`                                |
| **CareTeam**           | Als ik lid van het CareTeam ben              | R      | `CareTeam?participant=RelatedPerson/{id}`                                                               |
| **ActivityDefinition** | Geen                                         | -      | N.v.t.                                                                                                  |
| **Task (lezen)**       | Eigen taken OF taken voor mijn patiënt       | R      | `Task?owner=RelatedPerson/{id}` OF `Task?patient._has:RelatedPerson:patient:identifier=system\|user_id` |
| **Task (wijzigen)**    | Eigen taken                                  | U      | `Task?owner=RelatedPerson/{id}`                                                                         |
| **Task Launch**        | Eigen taken                                  | Launch | `Task?owner=RelatedPerson/{id}`                                                                         |

##### Wettelijk vertegenwoordiger

De Wettelijk vertegenwoordiger is juridisch gemachtigd om namens de patiënt te handelen en heeft de meest uitgebreide rechten.

| Entiteit               | Toegang                                    | CRUD   | Search Narrowing                                                                                               |
|------------------------|--------------------------------------------|--------|---------------------------------------------------------------------------------------------------------|
| **Patient**            | Als de RelatedPerson.patient de Patient is | R      | `Patient?_has:RelatedPerson:patient:identifier=system\|user_id`                                         |
| **Practitioner**       | Via CareTeam lidmaatschap                  | R      | `Practitioner?_has:CareTeam:participant:participant=RelatedPerson/{id}`                                 |
| **RelatedPerson**      | Via CareTeam lidmaatschap                  | R      | `RelatedPerson?_has:CareTeam:participant:participant=RelatedPerson/{id}`                                |
| **CareTeam**           | Als ik lid van het CareTeam ben            | R      | `CareTeam?participant=RelatedPerson/{id}`                                                               |
| **ActivityDefinition** | Geen                                       | -      | N.v.t.                                                                                                  |
| **Task**               | Eigen taken OF taken voor mijn patiënt     | RU     | `Task?owner=RelatedPerson/{id}` OF `Task?patient._has:RelatedPerson:patient:identifier=system\|user_id` |
| **Task Launch**        | Eigen taken OF taken voor mijn patiënt     | Launch | `Task?owner=RelatedPerson/{id}` OF `Task?patient._has:RelatedPerson:patient:identifier=system\|user_id` |

##### Buddy

De Buddy is een ervaringsdeskundige begeleider met vergelijkbare rechten als de Naaste.

| Entiteit               | Toegang                                    | CRUD   | Search Narrowing                                                       |
|------------------------|--------------------------------------------|--------|-----------------------------------------------------------------|
| **Patient**            | Als de RelatedPerson.patient de Patient is | R      | `Patient?_has:RelatedPerson:patient:identifier=system\|user_id` |
| **Practitioner**       | Via CareTeam lidmaatschap                  | R      | `Practitioner?_has:CareTeam:participant:participant=RelatedPerson/{id}` |
| **RelatedPerson**      | Via CareTeam lidmaatschap                  | R      | `RelatedPerson?_has:CareTeam:participant:participant=RelatedPerson/{id}` |
| **CareTeam**           | Als ik lid van het CareTeam ben            | R      | `CareTeam?participant=RelatedPerson/{id}`                       |
| **ActivityDefinition** | Geen                                       | -      | N.v.t.                                                          |
| **Task**               | Eigen taken                                | RU     | `Task?owner=RelatedPerson/{id}`                                 |
| **Task Launch**        | Eigen taken                                | Launch | `Task?owner=RelatedPerson/{id}`                                 |

##### Overige relaties

Dit is de fallback categorie voor RelatedPersons met een relatie die niet in de bovenstaande categorieën valt. Dit kunnen andere FHIR of SNOMED relatie-codes zijn die niet expliciet zijn gedefinieerd. Deze RelatedPersons krijgen minimale rechten, vergelijkbaar met "Geen relatie in CareTeam".

| Entiteit               | Toegang                                    | CRUD   | Search Narrowing                                                |
|------------------------|--------------------------------------------|--------|-----------------------------------------------------------------|
| **Patient**            | Als de RelatedPerson.patient de Patient is | R      | `Patient?_has:RelatedPerson:patient:identifier=system\|user_id` |
| **Practitioner**       | Geen                                       | -      | N.v.t.                                                          |
| **RelatedPerson**      | Geen                                       | -      | N.v.t.                                                          |
| **CareTeam**           | Geen                                       | -      | N.v.t.                                                          |
| **ActivityDefinition** | Geen                                       | -      | N.v.t.                                                          |
| **Task**               | Eigen taken                                | RU     | `Task?owner=RelatedPerson/{id}`                                 |
| **Task Launch**        | Eigen taken                                | Launch | `Task?owner=RelatedPerson/{id}`                                 |

#### CareTeam en autorisatie

Dit autorisatiemodel maakt gebruik van CareTeam voor het bepalen van toegangsrechten tot andere teamleden (Practitioner en RelatedPerson). Voor een uitgebreide beschrijving van:
- Wat een CareTeam is en welke types bestaan
- Hoe CareTeams worden gebruikt voor autorisatie
- De relatie tussen CareTeams en Tasks
- Het voorstel voor het autorisatiemodel
- Validatieregels en implementatieoverwegingen
- Discussiepunten en open vragen (zoals CareTeam gebruik in de praktijk)

Zie de [CareTeam en Autorisaties](autorisaties-careteam.html) pagina.

