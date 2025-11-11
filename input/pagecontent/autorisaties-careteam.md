Deze pagina beschrijft de rol van CareTeam binnen het autorisatiemodel van het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

### Wat is een CareTeam?

Een CareTeam is een groep van personen (Practitioners en/of RelatedPersons) die samenwerken aan de zorg voor een specifieke patiënt of binnen een specifieke organisatiecontext. Het CareTeam resource fungeert als de centrale plek waar wordt vastgelegd:
- Wie er betrokken is bij de zorg
- In welke rol zij betrokken zijn
- Voor welke patiënt of organisatie-afdeling het team verantwoordelijk is

### Types van CareTeams

Er zijn twee hoofdtypen van CareTeams in het systeem:

#### 1. Patiënt-specifieke CareTeams
Dit zijn CareTeams die gekoppeld zijn aan een specifieke patiënt via `CareTeam.patient`.

**Kenmerken:**
- `CareTeam.patient` verwijst naar de specifieke Patient resource
- Bevat alle betrokken Practitioners en RelatedPersons voor deze patiënt
- Definieert de rollen van elk teamlid (bijv. behandelaar, zorgondersteuner, eerste relatie)
- Wordt gebruikt voor autorisatie: lidmaatschap van dit CareTeam geeft toegang tot patiëntgegevens

**Voorbeeld gebruik:**
```
CareTeam voor Jan Jansen
├── Patient: Jan Jansen
├── Participants:
│   ├── Practitioner: Dr. Smit (rol: behandelaar)
│   ├── Practitioner: Zorgondersteuner Klaas (rol: zorgondersteuner)
│   └── RelatedPerson: Partner van Jan (rol: eerste relatie)
```

#### 2. Organisatie CareTeams
Dit zijn CareTeams zonder specifieke patiënt, die gebruikt worden voor organisatorische doeleinden.

**Kenmerken:**
- `CareTeam.patient` is **niet** gezet
- Vertegenwoordigt bijvoorbeeld een afdeling of team binnen een organisatie
- Bevat medewerkers die tot die afdeling/team behoren
- Kan gebruikt worden voor organisatie-brede taken of communicatie

**Voorbeeld gebruik:**
```
CareTeam voor Afdeling Depressie
├── Patient: (niet gezet)
├── Participants:
│   ├── Practitioner: Dr. Smit
│   ├── Practitioner: Dr. Jansen
│   └── Practitioner: Zorgondersteuner Klaas
```

### Relatie met Tasks

CareTeams zijn nauw verbonden met Tasks via de `Task.owner` referentie:

#### Task.owner = CareTeam
Een Task kan eigendom zijn van een CareTeam, wat betekent dat:
- Alle leden van het CareTeam de taak kunnen beheren (zie autorisatieregels per rol)
- De taak zichtbaar is voor het gehele team
- Verantwoordelijkheid gedeeld wordt binnen het team

#### Task.owner = Practitioner/RelatedPerson
Een Task kan ook individueel toegewezen zijn, waarbij:
- De specifieke persoon eigenaar is
- Deze persoon **moet** lid zijn van het relevante CareTeam (zie autorisatiemodel hieronder)
- Andere teamleden mogelijk beperkte toegang hebben (afhankelijk van hun rol)

### Autorisatiemodel CareTeam (Voorstel)

Het voorgestelde autorisatiemodel voor CareTeams is gebaseerd op onderstaande principes om een duidelijke en veilige autorisatiestructuur te garanderen:

#### Basisprincipes

1. **Één CareTeam per patiënt/organisatie combinatie**
   - Er is één en slechts één actief CareTeam per unieke patiënt/organisatie combinatie
   - Dit betekent: voor dezelfde patiënt kunnen meerdere CareTeams bestaan als deze bij verschillende organisaties in zorg is
   - Voor organisatie-teams (zonder patiënt) is er één CareTeam per afdeling/team

2. **Alle betrokkenen in het CareTeam**
   - Alle betrokken Practitioners **moeten** met hun correcte rol in het CareTeam staan
   - Alle betrokken RelatedPersons **moeten** met hun correcte rol in het CareTeam staan
   - De rol bepaalt de autorisaties volgens de autorisatiematrix

3. **Rollen en Autorisatiematrix**
   - De rollen in het CareTeam komen overeen met de rollen in de [autorisatiematrix](autorisaties.html)
   - Elke rol heeft specifieke rechten zoals gedefinieerd in:
     - [Practitioner autorisaties](autorisaties-practitioner.html)
     - [RelatedPerson autorisaties](autorisaties-relatedperson.html)
     - [Patient autorisaties](autorisaties-patient.html)

4. **Task betrokkenen moeten in CareTeam staan**
   - `Task.owner` **moet** lid zijn van het relevante CareTeam
   - `Task.requester` **moet** lid zijn van het relevante CareTeam
   - De patiënt waarvoor de Task is (`Task.for`) moet de patiënt zijn waarvoor het CareTeam is opgezet

5. **CareTeam als Task.owner** ⚠️
   - Een CareTeam **kan mogelijk niet** direct Task.owner zijn
   - Dit punt is nog in discussie en wordt nader uitgewerkt
   - Alternatief: Tasks worden toegewezen aan individuele teamleden die lid zijn van het CareTeam

#### Validatieregels

Bij het aanmaken of wijzigen van Tasks moeten de volgende validaties plaatsvinden:

**Task.owner validatie:**
```
Als Task.owner verwijst naar een Practitioner of RelatedPerson:
  MOET deze persoon lid zijn van het CareTeam van Task.for (patient)

Als Task.owner verwijst naar een CareTeam:
  [Nog te bepalen - zie discussiepunt hierboven]
```

**Task.requester validatie:**
```
Als Task.requester is ingevuld:
  MOET deze persoon lid zijn van het CareTeam van Task.for (patient)
```

**Task.for (patient) validatie:**
```
Als Task.for verwijst naar een Patient:
  MOET er een CareTeam bestaan met CareTeam.patient = deze Patient
  EN Task.owner en Task.requester moeten lid zijn van dit CareTeam
```

### Voorbeeld Scenario

**Situatie:**
- Patient: Jan Jansen
- CareTeam voor Jan Jansen bevat:
  - Dr. Smit (behandelaar)
  - Zorgondersteuner Klaas (zorgondersteuner)
  - Partner van Jan (eerste relatie)

**Geldige Task:**
```json
{
  "resourceType": "Task",
  "status": "requested",
  "intent": "order",
  "for": {
    "reference": "Patient/jan-jansen"
  },
  "owner": {
    "reference": "Practitioner/dr-smit"
  },
  "requester": {
    "reference": "Practitioner/zorgondersteuner-klaas"
  }
}
```
✅ Geldig: Zowel owner als requester zijn lid van het CareTeam

**Ongeldige Task:**
```json
{
  "resourceType": "Task",
  "status": "requested",
  "intent": "order",
  "for": {
    "reference": "Patient/jan-jansen"
  },
  "owner": {
    "reference": "Practitioner/dr-anderen"
  }
}
```
❌ Ongeldig: Dr. Anderen is geen lid van het CareTeam voor Jan Jansen

### Implementatie Overwegingen

#### CareTeam Lifecycle
- CareTeams worden typisch aangemaakt bij start van een behandeltraject
- CareTeams kunnen gedurende het behandeltraject worden uitgebreid of aangepast
- Bij het afsluiten van een behandeltraject kan een CareTeam op inactive worden gezet
- Historische CareTeam data blijft beschikbaar voor audit doeleinden

#### Performance
- Autorisatie-checks op basis van CareTeam lidmaatschap moeten efficiënt worden uitgevoerd
- Caching van CareTeam memberships wordt aanbevolen
- Bij wijzigingen in CareTeam compositie moet de cache worden geïnvalideerd

#### Privacy
- Toegang tot CareTeam informatie zelf is beperkt tot leden van dat CareTeam
- Patiënten hebben inzage in hun eigen CareTeam
- RelatedPersons zien alleen hun eigen rol binnen het CareTeam

### Discussiepunten en Open Vragen

De volgende punten vereisen nog nadere besluitvorming:

1. **CareTeam als Task.owner**
   - Kan een CareTeam direct eigenaar zijn van een Task?
   - Of moet ownership altijd individueel zijn?
   - Implicaties voor autorisatie en notificaties

2. **Multiple CareTeams per patiënt**
   - Huidige voorstel: één CareTeam per patiënt
   - Uitzondering mogelijk voor complexe zorgtrajecten?
   - Hoe om te gaan met parallelle behandeltrajecten?

3. **CareTeam rol granulariteit**
   - Welke rollen worden ondersteund?
   - Mapping naar autorisatiematrix
   - Extensibility voor organisatie-specifieke rollen

4. **CareTeam-Patient vs CareTeam-Task binding**

   Er zijn twee verschillende benaderingen mogelijk voor de relatie tussen CareTeam, Patient en Task:

   **Optie A: CareTeam gebonden aan Patient (huidige voorstel)**
   - Eén CareTeam per patiënt binnen een organisatie (1-op-1 relatie)
   - CareTeam wordt opgezet bij start van behandeltraject
   - Alle Tasks voor deze patiënt refereren naar hetzelfde CareTeam
   - CareTeam blijft stabiel gedurende het behandeltraject

   *Voordelen:*
   - Eenvoudiger model: één centraal punt voor wie betrokken is bij de zorg voor een patiënt
   - Consistente autorisaties: alle betrokkenen hebben toegang tot alle data van de patiënt
   - Minder overhead: CareTeam hoeft niet per Task te worden bepaald
   - Duidelijke lifecycle: gekoppeld aan het behandeltraject

   *Nadelen:*
   - Minder flexibel: kan niet eenvoudig wisselen van teamsamenstelling per taak
   - Bij parallelle behandeltrajecten binnen één organisatie kunnen problemen ontstaan
   - Alle teamleden zien alle Tasks, ook als ze alleen bij specifieke taken betrokken zijn

   **Optie B: CareTeam gebonden aan Task**
   - Per Task wordt een CareTeam opgezet of geselecteerd
   - Task.owner verwijst naar het specifieke CareTeam voor die taak
   - Verschillende Tasks kunnen verschillende CareTeams hebben, zelfs voor dezelfde patiënt

   *Voordelen:*
   - Maximale flexibiliteit: per taak kan de teamsamenstelling verschillen
   - Fijnmazige autorisatie: alleen betrokkenen bij specifieke taak hebben toegang
   - Beter geschikt voor complexe zorgtrajecten met wisselende teams
   - Natuurlijke ondersteuning voor parallelle behandeltrajecten

   *Nadelen:*
   - Complexer model: meer CareTeams om te beheren
   - Overhead: bij elke Task moet CareTeam worden bepaald/aangemaakt
   - Potentieel verwarrend: wie heeft nu toegang tot welke patiëntdata?
   - Fragmentatie: patiëntbeeld verspreid over meerdere CareTeams

   **Beslissing:**
   Op basis van de meeting is voorlopig gekozen voor **Optie A** (CareTeam gebonden aan Patient), met als belangrijkste argumenten:
   - Eenvoud en overzichtelijkheid in de praktijk
   - Behoud van een centraal overzicht van betrokkenen per patiënt
   - Aansluit bij gangbare zorgpraktijk waar een vast team verantwoordelijk is voor een patiënt

   De mogelijkheid om in de toekomst Optie B te ondersteunen blijft open, mocht blijken dat deze flexibiliteit noodzakelijk is voor specifieke use cases.

### Zie Ook

- [Autorisaties overzicht](autorisaties.html)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)
- [Patient autorisaties](autorisaties-patient.html)
- [Koppeltaal Domeinen - Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden)
