### Changelog

| Versie | Datum      | Wijziging                                                            |
|--------|------------|----------------------------------------------------------------------|
| 0.0.4  | 2026-01-16 | Fallback "Overige rollen" toegevoegd voor onbekende UZI/BIG rollen   |
| 0.0.3  | 2026-01-16 | Zorgondersteuner hernoemd naar Zorgondersteuner/Administratief mdw   |
| 0.0.3  | 2026-01-16 | Overzichtstabellen toegevoegd (conform RelatedPerson autorisaties)   |
| 0.0.2  | 2026-01-13 | Tabelstructuur aangepast: Search Narrowing kolom                     |
| 0.0.2  | 2026-01-13 | Tekstuele aanpassing: "rollen" naar "situaties"                      |

---

### Autorisatieregels voor Practitioner toegang

Deze pagina beschrijft de autorisatieregels voor een Practitioner (behandelaar) rol binnen het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

#### Context en Launch types
De onderstaande autorisatieregels gelden voor **alle launch types** waarbij een Practitioner betrokken is:

1. **Behandelaar context**: Wanneer de behandelaar inlogt en toegang krijgt tot meerdere patiënten
2. **Taak context**: Wanneer een taak wordt gelauncht voor een patiënt van deze behandelaar
3. **Patiënt-specifieke launch**: Wanneer de behandelaar een module start voor een specifieke patiënt

De toegang kan op twee manieren worden verkregen:
1. **Via CareTeam lidmaatschap**: Toegang tot patiënten binnen hun CareTeams
2. **Via Task toewijzing**: Toegang verkregen door eigenaar te zijn van taken, ook zonder CareTeam lidmaatschap

#### Situaties voor Practitioner

Er wordt onderscheid gemaakt tussen de volgende situaties:

| Situatie                                  | Omschrijving                             | Bevoegdheden                                         |
|:------------------------------------------|:-----------------------------------------|:-----------------------------------------------------|
| **Practitioner zonder rol in CareTeam**   | Niet opgenomen in CareTeam               | Alleen eigen taken en toegewezen resources           |
| **Behandelaar in CareTeam**               | Behandelend zorgverlener                 | Volledige toegang tot patiënten in hun CareTeams     |
| **Zorgondersteuner/Administratief mdw**   | Ondersteunende rol                       | Taken klaarzetten, niet starten                      |
| **Case Manager**                          | Organisatie-breed overzicht              | Brede toegang binnen de organisatie                  |
| **Overige rollen**                        | Onbekende of niet-gedefinieerde rol      | Alleen eigen taken en toegewezen resources           |

**Toelichting bevoegdheden:**

| Bevoegdheid                    | Betekenis                                                                      |
|:-------------------------------|:-------------------------------------------------------------------------------|
| Alleen eigen taken             | Toegang beperkt tot taken waar de Practitioner eigenaar van is                 |
| Volledige toegang              | CRUD rechten op resources van patiënten binnen de CareTeams                    |
| Read-only CareTeam resources   | Leestoegang tot CareTeam leden, maar geen wijzigingsrechten                    |
| Brede toegang                  | Overzicht en beheer van resources binnen de gehele organisatie                 |

#### Autorisatieregels

De onderstaande tabellen tonen de verschillende autorisatieniveaus voor Practitioners.

##### Overzicht Task autorisaties per situatie

De Task en Task Launch rechten zijn direct gekoppeld aan de bevoegdheden per situatie:

| Situatie                                  | Eigen taak | Patiënt taak | Eigen taak starten | Patiënt taak starten |
|--------------------------------------------|------------|--------------|--------------------|----------------------|
| **Practitioner zonder rol in CareTeam**   | CRUD       | R (via Task) | ✓                  | ✓ (via Task)         |
| **Behandelaar in CareTeam**               | CRUD       | CRUD         | ✓                  | ✓                    |
| **Zorgondersteuner/Administratief mdw**   | -          | CRUD         | -                  | -                    |
| **Case Manager**                          | -          | R            | -                  | ✓                    |
| **Overige rollen**                        | CRUD       | R (via Task) | ✓                  | ✓ (via Task)         |

**Toelichting:**
- **Eigen taak**: Taken waar de Practitioner eigenaar van is
- **Patiënt taak**: Taken die voor patiënten in het CareTeam zijn aangemaakt
- **via Task**: Toegang verkregen via Task toewijzing, niet via CareTeam lidmaatschap
- **Overige rollen**: Fallback voor UZI/BIG rollen die niet in bovenstaande categorieën vallen

##### Practitioner zonder rol in CareTeam
Deze Practitioners hebben toegang tot resources primair via Task toewijzingen. Dit is geen read-only rol - zij hebben volledige CRUD rechten op taken die aan hen zijn toegewezen.

| Entiteit               | Toegang                                            | CRUD   | Search Narrowing                                                                           |
|------------------------|----------------------------------------------------|--------|--------------------------------------------------------------------------------------------|
| **Patient**            | Via taken die aan mij zijn toegewezen              | R      | `Patient?_has:Task:patient:owner=Practitioner/{id}`                                        |
| **Practitioner**       | Via dezelfde Organization                          | R      | `Practitioner?organization=Organization/{id}`                                              |
| **RelatedPerson**      | Via taken relaties                                 | CRUD   | `RelatedPerson?_has:Task:focus:owner=Practitioner/{id}`                                    |
| **CareTeam**           | Als ik lid van het CareTeam ben                    | R      | `CareTeam?participant=Practitioner/{id}`                                                   |
| **ActivityDefinition** | Alles                                              | R      | `ActivityDefinition`                                                                       |
| **Task**               | Eigen taken of aan mij toegewezen                  | CRUD   | `Task?owner=Practitioner/{id}`                                                             |
| **Task Launch**        | Eigen taken OF taken voor mijn patiënten           | Launch | `Task?owner=Practitioner/{id}` OF `Task?patient._has:Task:patient:owner=Practitioner/{id}` |

##### Behandelaar in CareTeam

| Entiteit               | Toegang                                  | CRUD   | Search Narrowing                                                                              |
|------------------------|------------------------------------------|--------|-----------------------------------------------------------------------------------------------|
| **Patient**            | Via CareTeam lidmaatschap                | R      | `Patient?_has:CareTeam:patient:participant=Practitioner/{id}`                                 |
| **Practitioner**       | Via dezelfde Organization                | R      | `Practitioner?organization=Organization/{id}`                                                 |
| **RelatedPerson**      | Via CareTeam lidmaatschap                | CRUD   | `RelatedPerson?_has:CareTeam:participant:participant=Practitioner/{id}`                       |
| **CareTeam**           | Als ik lid van het CareTeam ben          | R      | `CareTeam?participant=Practitioner/{id}`                                                      |
| **ActivityDefinition** | Alles                                    | R      | `ActivityDefinition`                                                                          |
| **Task**               | Eigen taken OF taken van mijn patiënten  | CRUD   | `Task?owner=Practitioner/{id}` OF `Task?patient._has:CareTeam:patient:participant=Practitioner/{id}` |
| **Task Launch**        | Eigen taken OF taken voor mijn patiënten | Launch | `Task?owner=Practitioner/{id}` OF `Task?patient._has:Task:patient:owner=Practitioner/{id}`    |

##### Zorgondersteuner/Administratief medewerker

Deze rol kan taken klaarzetten voor patiënten, maar kan ze niet zelf starten. De rol is bedoeld voor ondersteunende werkzaamheden zoals het voorbereiden van taken.

| Entiteit               | Toegang                                  | CRUD   | Search Narrowing                                                                              |
|------------------------|------------------------------------------|--------|-----------------------------------------------------------------------------------------------|
| **Patient**            | Via CareTeam lidmaatschap                | R      | `Patient?_has:CareTeam:patient:participant=Practitioner/{id}`                                 |
| **Practitioner**       | Via CareTeam lidmaatschap                | R      | `Practitioner?_has:CareTeam:participant:participant=Practitioner/{id}`                        |
| **RelatedPerson**      | Via CareTeam lidmaatschap                | R      | `RelatedPerson?_has:CareTeam:participant:participant=Practitioner/{id}`                       |
| **CareTeam**           | Als ik lid van het CareTeam ben          | R      | `CareTeam?participant=Practitioner/{id}`                                                      |
| **ActivityDefinition** | Alles                                    | R      | `ActivityDefinition`                                                                          |
| **Task**               | Taken van patiënten in mijn CareTeam     | CRUD   | `Task?patient._has:CareTeam:patient:participant=Practitioner/{id}`                            |
| **Task Launch**        | Geen                                     | -      | N.v.t.                                                                                        |

##### Case Manager

De Case Manager heeft organisatie-breed overzicht en kan taken van alle patiënten binnen de organisatie inzien en starten. De Case Manager heeft geen eigen taken.

| Entiteit               | Toegang                                   | CRUD   | Search Narrowing                              |
|------------------------|-------------------------------------------|--------|-----------------------------------------------|
| **Patient**            | Alle patiënten binnen Organization        | R      | `Patient?organization=Organization/{id}`      |
| **Practitioner**       | Alle behandelaren binnen Organization     | R      | `Practitioner?organization=Organization/{id}` |
| **RelatedPerson**      | Geen                                      | -      | N.v.t.                                        |
| **CareTeam**           | Alle CareTeams binnen Organization        | R      | `CareTeam?organization=Organization/{id}`     |
| **ActivityDefinition** | Alles                                     | R      | `ActivityDefinition`                          |
| **Task**               | Taken van patiënten binnen Organization   | R      | `Task?patient.organization=Organization/{id}` |
| **Task Launch**        | Taken van patiënten binnen Organization   | Launch | `Task?patient.organization=Organization/{id}` |

##### Overige rollen

Dit is de fallback categorie voor Practitioners met een rol die niet in de bovenstaande categorieën valt. Dit kunnen andere UZI of BIG rol-codes zijn die niet expliciet zijn gedefinieerd. Deze Practitioners krijgen minimale rechten, vergelijkbaar met "Practitioner zonder rol in CareTeam".

| Entiteit               | Toegang                                            | CRUD   | Search Narrowing                                                                           |
|------------------------|----------------------------------------------------|--------|--------------------------------------------------------------------------------------------|
| **Patient**            | Via taken die aan mij zijn toegewezen              | R      | `Patient?_has:Task:patient:owner=Practitioner/{id}`                                        |
| **Practitioner**       | Via dezelfde Organization                          | R      | `Practitioner?organization=Organization/{id}`                                              |
| **RelatedPerson**      | Via taken relaties                                 | CRUD   | `RelatedPerson?_has:Task:focus:owner=Practitioner/{id}`                                    |
| **CareTeam**           | Als ik lid van het CareTeam ben                    | R      | `CareTeam?participant=Practitioner/{id}`                                                   |
| **ActivityDefinition** | Alles                                              | R      | `ActivityDefinition`                                                                       |
| **Task**               | Eigen taken of aan mij toegewezen                  | CRUD   | `Task?owner=Practitioner/{id}`                                                             |
| **Task Launch**        | Eigen taken OF taken voor mijn patiënten           | Launch | `Task?owner=Practitioner/{id}` OF `Task?patient._has:Task:patient:owner=Practitioner/{id}` |

#### CareTeam en autorisatie

Dit autorisatiemodel maakt intensief gebruik van CareTeam voor het bepalen van toegangsrechten. Voor een uitgebreide beschrijving van:
- Wat een CareTeam is en welke types bestaan
- Hoe CareTeams worden gebruikt voor autorisatie
- De relatie tussen CareTeams en Tasks
- Het voorstel voor het autorisatiemodel
- Validatieregels en implementatieoverwegingen
- Discussiepunten en open vragen (zoals CareTeam gebruik in de praktijk)

Zie de [CareTeam en Autorisaties](care-context-careteam.html) pagina.

