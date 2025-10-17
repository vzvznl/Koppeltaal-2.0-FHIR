## Autorisatieregels voor Practitioner toegang

Deze pagina beschrijft de autorisatieregels voor een Practitioner (behandelaar) rol binnen het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

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

### Belangrijke overweging: CareTeam gebruik in de praktijk

> ⚠️ **Spanningsveld tussen huidige praktijk en gewenst autorisatiemodel**
>
> In het huidige gebruik van Koppeltaal wordt **bijna geen gebruik gemaakt van CareTeam**. Echter, voor het opzetten van een goed autorisatiemodel lijkt het gebruik van CareTeam **essentieel**. Dit creëert een uitdaging voor de implementatie van deze autorisatieregels.
>
> **Aandachtspunten:**
> - De meeste bestaande Koppeltaal implementaties werken zonder CareTeam structuren
> - Een robuust autorisatiemodel vereist duidelijke relaties tussen zorgverleners en patiënten
> - CareTeam biedt deze structuur, maar vereist aanpassing van bestaande werkwijzen
>
> **Beslissing nodig:**
> Het autorisatiemodel voor toegang zonder CareTeam (puur task-gebaseerd) vereist nog nadere uitwerking en besluitvorming. Overwegingen hierbij zijn:
> - Hoe waarborgen we veilige toegang zonder formele CareTeam relaties?
> - Welke minimale structuren zijn nodig voor verantwoorde autorisatie?
> - Hoe faciliteren we de transitie van bestaande implementaties?

### Task-gebaseerde toegang als alternatief

Als overbrugging of alternatief voor CareTeam-gebaseerde autorisatie kan task-gebaseerde toegang worden gebruikt. Dit betekent dat:

1. **Directe task toewijzing**: Een Practitioner kan eigenaar worden van een taak zonder lid te zijn van een CareTeam
2. **Afgeleide toegang**: Via task ownership krijgt de Practitioner toegang tot gerelateerde resources zoals de patiënt
3. **Volledige CRUD rechten**: Task-gebaseerde toegang is niet beperkt tot read-only - Practitioners kunnen taken volledig beheren
4. **Flexibele samenwerking**: Maakt ad-hoc samenwerking mogelijk zonder formele CareTeam structuren

Deze aanpak ondersteunt scenario's zoals:
- Consultaties door externe specialisten
- Tijdelijke ondersteuning door andere zorgverleners
- Taken die worden overgedragen tussen afdelingen

**Let op:** De precieze implementatie van task-gebaseerde autorisatie zonder CareTeam context vereist nog verdere uitwerking en standaardisatie.

