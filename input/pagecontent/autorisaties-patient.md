## Autorisatieregels voor Patient toegang

Deze pagina beschrijft de autorisatieregels voor een Patient rol binnen het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

### Context en Launch types
De onderstaande autorisatieregels gelden voor **alle launch types** waarbij een Patient betrokken is:

1. **Patient/RelatedPerson context**: Wanneer de patiënt zelf inlogt en toegang krijgt tot alle eigen resources
2. **Taak context**: Wanneer een taak wordt gelauncht die eigendom is van deze patiënt
3. **Behandelaar context met patient selectie**: Wanneer een behandelaar een module start voor deze specifieke patiënt

Deze autorisaties worden gebruikt wanneer:
- Een patiënt inlogt via een PGO (Persoonlijke Gezondheidsomgeving)
- Een patiënt inlogt via een cliëntportaal
- Self-service functionaliteiten worden aangeboden
- Een taak wordt uitgevoerd in de context van de patiënt

### Autorisatieregels

De onderstaande tabel toont:
1. **Entiteit**: De FHIR resource types
2. **Toegangsvoorwaarde**: Wanneer een Patient toegang heeft tot specifieke resources
3. **CRUD**: Of ze de resources kunnen Create (C), Read (R), Update (U) en/of Delete (D)
4. **Validatie query**: De FHIR search query gebruikt voor toegangsvalidatie

| Entiteit | Toegang | CRUD | Read validatie | Create validatie |
|----------|---------|------|----------------|------------------|
| **Patient** | Enkel mijzelf | R | `Patient?identifier=system\|user_id` | N.v.t. |
| **Practitioner** | Als deze in een CareTeam van mij zit | R | `Practitioner?_has:CareTeam:participant:patient=Patient/{id}` | N.v.t. |
| **RelatedPerson** | Als deze in een CareTeam van mij zit | R | `RelatedPerson?_has:CareTeam:participant:patient=Patient/{id}` | N.v.t. |
| **CareTeam** | Als ik subject van het CareTeam ben | R | `CareTeam?patient=Patient/{id}` | N.v.t. |
| **ActivityDefinition** | Enkel van type zelfhulp* | R | `ActivityDefinition?topic=self-help` | N.v.t. |
| **Task** | Als ik de eigenaar van de taak ben | C*R | `Task?owner=Patient/{id}` | `Task.owner=Patient/{id}` |
| **Task Launch** | Als ik de eigenaar van de taak ben (eigen taken launchen) | Launch | `Task?owner=Patient/{id}` | N.v.t. |

*C = Create alleen voor zelfhulp taken

### Belangrijke overweging: CareTeam gebruik

> 📝 **Opmerking over CareTeam in de praktijk**
>
> Hoewel dit autorisatiemodel gebruik maakt van CareTeam voor het bepalen van toegangsrechten, wordt in de huidige Koppeltaal praktijk **bijna geen gebruik gemaakt van CareTeam**. Voor patiënten is dit minder problematisch omdat:
> - Patiënten hebben primair toegang tot hun eigen gegevens
> - CareTeam relaties zijn vooral relevant voor het zien van betrokken zorgverleners
> - Task-gebaseerde toegang kan voldoende zijn voor patiënt scenarios

