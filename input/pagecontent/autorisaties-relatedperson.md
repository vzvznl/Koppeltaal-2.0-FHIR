### Autorisatieregels voor RelatedPerson toegang

Deze pagina beschrijft de autorisatieregels voor een RelatedPerson (mantelzorger/vertegenwoordiger) rol binnen het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

#### Context en Launch types
De onderstaande autorisatieregels gelden voor **alle launch types** waarbij een RelatedPerson betrokken is:

1. **Patiënt/RelatedPerson context**: Wanneer de RelatedPerson inlogt en toegang krijgt tot geautoriseerde resources
2. **Taak context**: Wanneer een taak wordt gelauncht voor de patiënt van deze RelatedPerson
3. **Patiënt-specifieke launch**: Wanneer de RelatedPerson een module start voor de patiënt

Er wordt onderscheid gemaakt tussen verschillende typen:
- **Gemachtigd**: Volledige toegang tot patiëntgegevens met machtiging
- **Samenwerker**: Beperkte toegang als onderdeel van het zorgteam
- **Monitor**: Enkel leesrechten voor monitoring doeleinden

#### Autorisatieregels

De onderstaande tabellen tonen de verschillende autorisatieniveaus voor RelatedPersons:

##### RelatedPerson - Gemachtigd

| Entiteit | Toegang | CRUD | Read validatie | Create validatie |
|----------|---------|------|----------------|------------------|
| **Patient** | Als de RelatedPerson.patient de Patient is | R | `Patient?_has:RelatedPerson:patient:identifier=system\|user_id` | N.v.t. |
| **Practitioner** | Als deze onderdeel is van een CareTeam waar ik lid van ben | R | `Practitioner?_has:CareTeam:participant:participant=RelatedPerson/{id}` | N.v.t. |
| **RelatedPerson** | Als deze onderdeel is van een CareTeam waar ik lid van ben | R | `RelatedPerson?_has:CareTeam:participant:participant=RelatedPerson/{id}` | N.v.t. |
| **CareTeam** | Als ik onderdeel van het CareTeam ben | R | `CareTeam?participant=RelatedPerson/{id}` | N.v.t. |
| **ActivityDefinition** | Geen | - | N.v.t. | N.v.t. |
| **Task** | Als ik de eigenaar van de taak ben | R | `Task?owner=RelatedPerson/{id}` | N.v.t. |
| **Task Launch** | Als ik de eigenaar van de taak ben OF als de taak voor mijn patiënt is | Launch | `Task?owner=RelatedPerson/{id}` OF `Task?patient._has:RelatedPerson:patient:identifier=system\|user_id` | N.v.t. |

##### RelatedPerson - Samenwerker

| Entiteit | Toegang | CRUD | Read validatie | Create validatie |
|----------|---------|------|----------------|------------------|
| **Patient** | Als de RelatedPerson.patient de Patient is | R | `Patient?_has:RelatedPerson:patient:identifier=system\|user_id` | N.v.t. |
| **Practitioner** | Als deze onderdeel is van een CareTeam waar ik lid van ben | R | `Practitioner?_has:CareTeam:participant:participant=RelatedPerson/{id}` | N.v.t. |
| **RelatedPerson** | Als deze onderdeel is van een CareTeam waar ik lid van ben | R | `RelatedPerson?_has:CareTeam:participant:participant=RelatedPerson/{id}` | N.v.t. |
| **CareTeam** | Als ik onderdeel van het CareTeam ben | R | `CareTeam?participant=RelatedPerson/{id}` | N.v.t. |
| **ActivityDefinition** | Geen | - | N.v.t. | N.v.t. |
| **Task** | Als ik de eigenaar van de taak ben | R | `Task?owner=RelatedPerson/{id}` | N.v.t. |
| **Task Launch** | Als ik de eigenaar van de taak ben OF als de taak voor mijn patiënt is | Launch | `Task?owner=RelatedPerson/{id}` OF `Task?patient._has:RelatedPerson:patient:identifier=system\|user_id` | N.v.t. |

##### RelatedPerson - Monitor

| Entiteit | Toegang | CRUD | Read validatie | Create validatie |
|----------|---------|------|----------------|------------------|
| **Patient** | Als de RelatedPerson.patient de Patient is | R | `Patient?_has:RelatedPerson:patient:identifier=system\|user_id` | N.v.t. |
| **Practitioner** | Als deze onderdeel is van een CareTeam waar ik lid van ben | R | `Practitioner?_has:CareTeam:participant:participant=RelatedPerson/{id}` | N.v.t. |
| **RelatedPerson** | Als deze onderdeel is van een CareTeam waar ik lid van ben | R | `RelatedPerson?_has:CareTeam:participant:participant=RelatedPerson/{id}` | N.v.t. |
| **CareTeam** | Als ik onderdeel van het CareTeam ben | R | `CareTeam?participant=RelatedPerson/{id}` | N.v.t. |
| **ActivityDefinition** | Geen | - | N.v.t. | N.v.t. |
| **Task** | Als ik de eigenaar van de taak ben | R | `Task?owner=RelatedPerson/{id}` | N.v.t. |
| **Task Launch** | Als ik de eigenaar van de taak ben OF als de taak voor mijn patiënt is | Launch | `Task?owner=RelatedPerson/{id}` OF `Task?patient._has:RelatedPerson:patient:identifier=system\|user_id` | N.v.t. |

#### CareTeam en autorisatie

Dit autorisatiemodel maakt gebruik van CareTeam voor het bepalen van toegangsrechten tot andere teamleden (Practitioner en RelatedPerson). Voor een uitgebreide beschrijving van:
- Wat een CareTeam is en welke types bestaan
- Hoe CareTeams worden gebruikt voor autorisatie
- De relatie tussen CareTeams en Tasks
- Het voorstel voor het autorisatiemodel
- Validatieregels en implementatieoverwegingen
- Discussiepunten en open vragen (zoals CareTeam gebruik in de praktijk)

Zie de [CareTeam en Autorisaties](autorisaties-careteam.html) pagina.

