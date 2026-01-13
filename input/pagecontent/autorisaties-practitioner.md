### Changelog

| Versie | Datum      | Wijziging                                        |
|--------|------------|--------------------------------------------------|
| 0.0.2  | 2026-01-13 | Tabelstructuur aangepast: Search Narrowing kolom |
| 0.0.2  | 2026-01-13 | Tekstuele aanpassing: "rollen" naar "situaties"  |

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

Er wordt onderscheid gemaakt tussen verschillende situaties:
- **Practitioner zonder rol in CareTeam**: Toegang via taken die aan hen zijn toegewezen of die zij beheren
- **Behandelaar in CareTeam**: Volledige toegang tot patiënten in hun CareTeams
- **Zorgondersteuner**: Read-only toegang tot CareTeam resources, maar volledige CRUD op eigen taken
- **Case Manager**: Brede toegang binnen de organisatie

#### Autorisatieregels

De onderstaande tabellen tonen de verschillende autorisatieniveaus voor Practitioners:

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

##### Zorgondersteuner

| Entiteit               | Toegang                                  | CRUD   | Search Narrowing                                                                              |
|------------------------|------------------------------------------|--------|-----------------------------------------------------------------------------------------------|
| **Patient**            | Via CareTeam lidmaatschap                | R      | `Patient?_has:CareTeam:patient:participant=Practitioner/{id}`                                 |
| **Practitioner**       | Via CareTeam lidmaatschap                | R      | `Practitioner?_has:CareTeam:participant:participant=Practitioner/{id}`                        |
| **RelatedPerson**      | Via CareTeam lidmaatschap                | R      | `RelatedPerson?_has:CareTeam:participant:participant=Practitioner/{id}`                       |
| **CareTeam**           | Als ik lid van het CareTeam ben          | R      | `CareTeam?participant=Practitioner/{id}`                                                      |
| **ActivityDefinition** | Alles                                    | R      | `ActivityDefinition`                                                                          |
| **Task**               | Eigen taken OF taken van mijn patiënten  | CRUD   | `Task?owner=Practitioner/{id}` OF `Task?patient._has:CareTeam:patient:participant=Practitioner/{id}` |
| **Task Launch**        | Eigen taken OF taken voor mijn patiënten | Launch | `Task?owner=Practitioner/{id}` OF `Task?patient._has:Task:patient:owner=Practitioner/{id}`    |

##### Case Manager

| Entiteit               | Toegang                            | CRUD   | Search Narrowing                        |
|------------------------|------------------------------------|--------|-----------------------------------------|
| **Patient**            | Alle patiënten binnen Organization | R      | `Patient?organization=Organization/{id}`      |
| **Practitioner**       | Alle behandelaren binnen Organization | R   | `Practitioner?organization=Organization/{id}` |
| **RelatedPerson**      | Geen                               | -      | N.v.t.                                  |
| **CareTeam**           | Alle CareTeams binnen Organization | R      | `CareTeam?organization=Organization/{id}`     |
| **ActivityDefinition** | Alles                              | R      | `ActivityDefinition`                    |
| **Task**               | Enkel eigen aangemaakte taken      | CRUD   | `Task?author=Practitioner/{id}`         |
| **Task Launch**        | Geen                               | -      | N.v.t.                                  |

#### CareTeam en autorisatie

Dit autorisatiemodel maakt intensief gebruik van CareTeam voor het bepalen van toegangsrechten. Voor een uitgebreide beschrijving van:
- Wat een CareTeam is en welke types bestaan
- Hoe CareTeams worden gebruikt voor autorisatie
- De relatie tussen CareTeams en Tasks
- Het voorstel voor het autorisatiemodel
- Validatieregels en implementatieoverwegingen
- Discussiepunten en open vragen (zoals CareTeam gebruik in de praktijk)

Zie de [CareTeam en Autorisaties](autorisaties-careteam.html) pagina.

