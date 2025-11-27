### Autorisatieregels voor Patient toegang

Deze pagina beschrijft de autorisatieregels voor een Patient rol binnen het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

#### Context en Launch types
De onderstaande autorisatieregels gelden voor **alle launch types** waarbij een Patient betrokken is:

1. **Taak context**: Wanneer een taak wordt gelauncht die eigendom is van deze patiënt
2. **Behandelaar context met patient selectie**: Wanneer een behandelaar een taak start voor deze specifieke patiënt

Deze autorisaties worden gebruikt wanneer:
- Een patiënt een KoppelMij launch uitvoert via een PGO (Persoonlijke Gezondheidsomgeving) in de context van een Taak
- Een patiënt een Koppeltaal launch uitvoert via een cliëntportaal in de context van een Taak
- Self-service functionaliteiten worden aangeboden vanuit andere bronnen die zich in de context van een Taak bevinden
- Een taak wordt uitgevoerd in de context van de patiënt door bijvoorbeeld een behandelaar. De zogenaamde "on behalf of" functionaliteit waar de behandelaar samen met de patient de taak start.

#### Autorisatieregels

De onderstaande tabel toont:
1. **Entiteit**: De FHIR resource types
2. **Toegangsvoorwaarde**: Wanneer een Patient toegang heeft tot specifieke resources
3. **CRUD**: Of ze de resources kunnen Create (C), Read (R), Update (U) en/of Delete (D)
4. **Validatie query**: De FHIR search query gebruikt voor toegangsvalidatie

| Entiteit               | Toegang                                                            | CRUD   | Read validatie                                                     | Create validatie          |
|------------------------|--------------------------------------------------------------------|--------|--------------------------------------------------------------------|---------------------------|
| **Patient**            | Enkel mijzelf                                                      | R      | `Patient?identifier=system\|user_id`                               | N.v.t.                    |
| **Practitioner**       | Als deze in een CareTeam van mij zit                               | R      | `Practitioner?_has:CareTeam:participant:patient=Patient/{id}`      | N.v.t.                    |
| **RelatedPerson**      | Zie [Beslispunt 1](#beslispunt-1-relatedperson-koppeling)          | R      | Zie [Beslispunt 1](#beslispunt-1-relatedperson-koppeling)          | N.v.t.                    |
| **CareTeam**           | Zie [Beslispunt 2](#beslispunt-2-patient-als-careteam-participant) | R      | Zie [Beslispunt 2](#beslispunt-2-patient-als-careteam-participant) | N.v.t.                    |
| **ActivityDefinition** | Enkel van type zelfhulp*                                           | R      | `ActivityDefinition?topic=self-help`                               | N.v.t.                    |
| **Task**               | Als ik de eigenaar van de taak ben                                 | C*R    | `Task?owner=Patient/{id}`                                          | `Task.owner=Patient/{id}` |
| **Task Launch**        | Als ik de eigenaar van de taak ben (eigen taken launchen)          | Launch | `Task?owner=Patient/{id}`                                          | N.v.t.                    |

*C = Create alleen voor zelfhulp taken

#### CareTeam en autorisatie

Dit autorisatiemodel maakt gebruik van CareTeam voor het bepalen van toegangsrechten tot Practitioner en RelatedPerson resources. Voor een uitgebreide beschrijving van:
- Wat een CareTeam is en welke types bestaan
- Hoe CareTeams worden gebruikt voor autorisatie
- De relatie tussen CareTeams en Tasks
- Validatieregels en implementatieoverwegingen

Zie de [CareTeam en Autorisaties](autorisaties-careteam.html) pagina.

### Te beslissen punten

De volgende punten zijn nog niet definitief besloten en worden voorgelegd ter review.

#### Beslispunt 1: RelatedPerson koppeling

**Vraag:** Hoe krijgt een Patient toegang tot RelatedPerson resources?

**Opties:**

| Optie | Beschrijving                             | Toegangsvoorwaarde                                                          | Validatie query                                                |
|-------|------------------------------------------|-----------------------------------------------------------------------------|----------------------------------------------------------------|
| A     | Via CareTeam                             | RelatedPerson moet lid zijn van een CareTeam waar de Patient subject van is | `RelatedPerson?_has:CareTeam:participant:patient=Patient/{id}` |
| **B** | **Via RelatedPerson.patient (voorstel)** | Directe koppeling via het `patient` veld van RelatedPerson                  | `RelatedPerson?patient=Patient/{id}`                           |
| C     | Beide methoden                           | Toegang via CareTeam óf via directe `RelatedPerson.patient` koppeling       | Combinatie van A en B                                          |

**Overwegingen:**
- **Optie A (CareTeam):** Consistent met hoe Practitioner toegang werkt; alle autorisatie via CareTeam
- **Optie B (RelatedPerson.patient):** Simpeler, directe FHIR relatie; RelatedPerson is per definitie gekoppeld aan een Patient
- **Optie C (Beide):** Maximale flexibiliteit, maar complexer te implementeren en valideren

**Besluit:** *Nog te bepalen*

#### Beslispunt 2: Patient als CareTeam participant

**Vraag:** Moet een Patient die lid is van een CareTeam (als participant, niet als subject) toegang krijgen tot dat CareTeam en de andere leden?

**Context:** In de huidige tabel heeft een Patient alleen toegang tot CareTeams waar zij subject van is (`CareTeam.patient`). Maar een Patient kan ook participant zijn in een CareTeam (bijvoorbeeld in een groepstherapie setting of als mantelzorger voor een andere patiënt).

**Opties:**

| Optie | Beschrijving                      | Toegangsvoorwaarde                                                  | Validatie query                                                        |
|-------|-----------------------------------|---------------------------------------------------------------------|------------------------------------------------------------------------|
| **A** | **Alleen als subject (voorstel)** | Patient heeft alleen toegang tot CareTeams waar zij subject van is  | `CareTeam?patient=Patient/{id}`                                        |
| B     | Ook als participant               | Patient heeft ook toegang tot CareTeams waar zij participant van is | `CareTeam?patient=Patient/{id}` of `CareTeam?participant=Patient/{id}` |

**Overwegingen:**
- **Optie A (Alleen subject):** Simpeler, huidige situatie; Patient ziet alleen "eigen" zorgteams
- **Optie B (Ook participant):** Consistenter met hoe andere rollen werken; relevant voor scenario's waar Patient ook zorgverlener is (bijv. mantelzorg)
- In de praktijk zal dit scenario minder snel voorkomen, maar het is wel relevant voor de consistentie van het autorisatiemodel

**Besluit:** *Nog te bepalen*

