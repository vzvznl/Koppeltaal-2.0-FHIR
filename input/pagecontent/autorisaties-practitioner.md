## Autorisatieregels voor Practitioner toegang

Deze pagina beschrijft de autorisatieregels voor een Practitioner (behandelaar) rol binnen het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

### Context en Launch types
De onderstaande autorisatieregels gelden voor **alle launch types** waarbij een Practitioner betrokken is:

1. **Behandelaar context**: Wanneer de behandelaar inlogt en toegang krijgt tot meerdere patiënten
2. **Taak context**: Wanneer een taak wordt gelauncht voor een patiënt van deze behandelaar
3. **Patiënt-specifieke launch**: Wanneer de behandelaar een module start voor een specifieke patiënt

De toegang kan op twee manieren worden verkregen:
1. **Via CareTeam lidmaatschap**: Toegang tot patiënten binnen hun CareTeams
2. **Via Task toewijzing**: Toegang verkregen door eigenaar te zijn van taken, ook zonder CareTeam lidmaatschap

Er wordt onderscheid gemaakt tussen verschillende rollen:
- **Practitioner zonder rol in CareTeam**: Toegang via taken die aan hen zijn toegewezen of die zij beheren
- **Behandelaar in CareTeam**: Volledige toegang tot patiënten in hun CareTeams
- **Zorgondersteuner**: Read-only toegang tot CareTeam resources, maar volledige CRUD op eigen taken
- **Case Manager**: Brede toegang binnen de organisatie

### Autorisatieregels

De onderstaande tabellen tonen de verschillende autorisatieniveaus voor Practitioners:

#### Practitioner zonder rol in CareTeam
Deze Practitioners hebben toegang tot resources primair via Task toewijzingen. Dit is geen read-only rol - zij hebben volledige CRUD rechten op taken die aan hen zijn toegewezen.

| Entiteit | Toegang | CRUD | Read validatie | Create validatie |
|----------|---------|------|----------------|------------------|
| **Patient** | Via taken die aan mij zijn toegewezen | R | `Patient?_has:Task:patient:owner=Practitioner/{id}` | N.v.t. |
| **Practitioner** | Als ik onderdeel ben van dezelfde Organization | R | `Practitioner?organization=Organization/{id}` | N.v.t. |
| **RelatedPerson** | Via taken relaties | CRUD | `RelatedPerson?_has:Task:focus:owner=Practitioner/{id}` | Via Task context |
| **CareTeam** | Als ik lid van het CareTeam ben | R | `CareTeam?participant=Practitioner/{id}` | N.v.t. |
| **ActivityDefinition** | Alles | R | `ActivityDefinition` | N.v.t. |
| **Task** | Als ik de eigenaar ben of als de taak aan mij is toegewezen | CRUD | `Task?owner=Practitioner/{id}` | `Task.owner=Practitioner/{id}` |
| **Task Launch** | Als ik eigenaar ben van de taak OF als de taak voor een patiënt is waar ik toegang tot heb | Launch | `Task?owner=Practitioner/{id}` OF `Task?patient._has:Task:patient:owner=Practitioner/{id}` | N.v.t. |

#### Behandelaar in CareTeam

| Entiteit | Toegang | CRUD | Read validatie | Create validatie |
|----------|---------|------|----------------|------------------|
| **Patient** | Als ik lid ben van een CareTeam van de patiënt | R | `Patient?_has:CareTeam:patient:participant=Practitioner/{id}` | N.v.t. |
| **Practitioner** | Als ik onderdeel ben van dezelfde Organization | R | `Practitioner?organization=Organization/{id}` | N.v.t. |
| **RelatedPerson** | Als deze onderdeel is van een CareTeam waar ik lid van ben | CRUD | `RelatedPerson?_has:CareTeam:participant:participant=Practitioner/{id}` | Via CareTeam relatie |
| **CareTeam** | Als ik lid van het CareTeam ben | R | `CareTeam?participant=Practitioner/{id}` | N.v.t. |
| **ActivityDefinition** | Alles | R | `ActivityDefinition` | N.v.t. |
| **Task** | Als ik de eigenaar ben of als de eigenaar van de taak een patiënt is waar ik toegang tot heb | CRUD | `Task?owner=Practitioner/{id},patient._has:CareTeam:patient:participant=Practitioner/{id}` | `Task.owner=Practitioner/{id}` |
| **Task Launch** | Als ik eigenaar ben van de taak OF als de taak voor een patiënt is waar ik toegang tot heb | Launch | `Task?owner=Practitioner/{id}` OF `Task?patient._has:Task:patient:owner=Practitioner/{id}` | N.v.t. |

#### Zorgondersteuner

| Entiteit | Toegang | CRUD | Read validatie | Create validatie |
|----------|---------|------|----------------|------------------|
| **Patient** | Als ik lid ben van een CareTeam van de patiënt | R | `Patient?_has:CareTeam:patient:participant=Practitioner/{id}` | N.v.t. |
| **Practitioner** | Als deze onderdeel is van een CareTeam waar ik lid van ben | R | `Practitioner?_has:CareTeam:participant:participant=Practitioner/{id}` | N.v.t. |
| **RelatedPerson** | Als deze onderdeel is van een CareTeam waar ik lid van ben | R | `RelatedPerson?_has:CareTeam:participant:participant=Practitioner/{id}` | N.v.t. |
| **CareTeam** | Als ik lid van het CareTeam ben | R | `CareTeam?participant=Practitioner/{id}` | N.v.t. |
| **ActivityDefinition** | Alles | R | `ActivityDefinition` | N.v.t. |
| **Task** | Als ik de eigenaar ben of als de eigenaar van de taak een patiënt is waar ik toegang tot heb | CRUD | `Task?owner=Practitioner/{id},patient._has:CareTeam:patient:participant=Practitioner/{id}` | `Task.owner=Practitioner/{id}` |
| **Task Launch** | Als ik eigenaar ben van de taak OF als de taak voor een patiënt is waar ik toegang tot heb | Launch | `Task?owner=Practitioner/{id}` OF `Task?patient._has:Task:patient:owner=Practitioner/{id}` | N.v.t. |

#### Case Manager

| Entiteit | Toegang | CRUD | Read validatie | Create validatie |
|----------|---------|------|----------------|------------------|
| **Patient** | Alle patiënten binnen mijn Organisatie | R | `Patient?organization=Organization/{id}` | N.v.t. |
| **Practitioner** | Alle behandelaren binnen mijn Organisatie | R | `Practitioner?organization=Organization/{id}` | N.v.t. |
| **RelatedPerson** | Geen | - | N.v.t. | N.v.t. |
| **CareTeam** | Alle CareTeams binnen mijn Organisatie | R | `CareTeam?organization=Organization/{id}` | N.v.t. |
| **ActivityDefinition** | Alles | R | `ActivityDefinition` | N.v.t. |
| **Task** | Enkel die ik heb aangemaakt | CRUD | `Task?author=Practitioner/{id}` | `Task.author=Practitioner/{id}` |
| **Task Launch** | Geen (Case Managers launchen geen taken voor patiënten) | - | N.v.t. | N.v.t. |

### CareTeam en autorisatie

Dit autorisatiemodel maakt intensief gebruik van CareTeam voor het bepalen van toegangsrechten. Voor een uitgebreide beschrijving van:
- Wat een CareTeam is en welke types bestaan
- Hoe CareTeams worden gebruikt voor autorisatie
- De relatie tussen CareTeams en Tasks
- Het voorstel voor het autorisatiemodel
- Validatieregels en implementatieoverwegingen
- Discussiepunten en open vragen (zoals CareTeam gebruik in de praktijk)

Zie de [CareTeam en Autorisaties](autorisaties-careteam.html) pagina.

