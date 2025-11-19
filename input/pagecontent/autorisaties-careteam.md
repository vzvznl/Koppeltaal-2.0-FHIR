Deze pagina beschrijft de rol van CareTeam binnen het autorisatiemodel van het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

### Wat is een CareTeam?

Een CareTeam is een groep van personen (Practitioners en/of RelatedPersons) die samenwerken aan de zorg voor een specifieke patiënt of binnen een specifieke organisatiecontext. Het CareTeam resource fungeert als de centrale plek waar wordt vastgelegd:
- Wie er betrokken is bij de zorg
- In welke rol zij betrokken zijn
- Voor welke patiënt of organisatie-afdeling het team verantwoordelijk is

### Types van CareTeams

Er zijn twee hoofdtypen van CareTeams in het systeem:

#### 1. Organisatie CareTeams
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

#### 2. Patiënt-specifieke CareTeams
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

#### 3. Task level CareTeams
Dit zijn CareTeams die gebonden zijn aan een specifieke Task en een specifieke patiënt.

**Kenmerken:**
- `CareTeam.patient` verwijst naar de specifieke Patient resource
- Gebonden aan de scope van een specifieke Task via `Task.owner`
- Bevat alleen de personen die direct betrokken zijn bij deze specifieke taak
- Beperkter in scope dan een algemeen patiënt-specifiek CareTeam
- Wordt gebruikt wanneer een taak door een specifiek subteam moet worden uitgevoerd

**Voorbeeld gebruik:**
```
CareTeam voor Intake Gesprek Jan Jansen
├── Patient: Jan Jansen
├── Participants:
│   ├── Practitioner: Dr. Smit (rol: behandelaar)
│   └── Practitioner: Zorgondersteuner Klaas (rol: zorgondersteuner)
├── Gekoppeld aan: Task "Intake gesprek plannen"
```

**Verschil met Patiënt-specifieke CareTeams:**
- Task level CareTeams zijn tijdelijk en taak-specifiek
- Patiënt-specifieke CareTeams omvatten alle betrokkenen voor de gehele taak
- Task level CareTeams kunnen een subset zijn van het bredere patiënt-specifieke CareTeam
- Na voltooiing van de Task kan het Task level CareTeam worden opgeheven

**Nadelen van Task level CareTeams:**
- **Synchronisatie overhead:** Wanneer de samenstelling van een zorgteam wijzigt (bijvoorbeeld een nieuwe behandelaar wordt toegevoegd of een medewerker vertrekt), moeten alle Task level CareTeams van alle lopende taken worden geüpdatet
- Dit kan leiden tot complexe update-procedures en potentiële inconsistenties
- Verhoogde kans op fouten waarbij sommige Task CareTeams niet correct gesynchroniseerd worden
- Aanzienlijke operationele overhead bij frequente teamwijzigingen

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

#### Additionele autorisaties

##### SMART on FHIR Launch en Autorisatie

Bij gebruik van SMART on FHIR en HTI (Health Tools Interoperability) launches speelt autorisatie op launch-niveau:

- Een SMART on FHIR launch definieert een `sub` (subject) in het HTI token voor de Patient, Practitioner of RelatedPerson die de applicatie start
- De launch zelf is een uitdrukking van autorisatie: door de applicatie te lanceren, besluit de lancerende partij dat de betreffende Practitioner of RelatedPerson toegang heeft
- Deze autorisatiebeslissing vindt plaats buiten het FHIR model, maar moet wel gebaseerd zijn op het CareTeam
- **Basisregel:** De Practitioner of RelatedPerson moet lid zijn van het relevante CareTeam met de juiste rol

Deze aanpak biedt de flexibiliteit van externe autorisatiebeslissingen (via launch) gecombineerd met de veiligheid van rol-gebaseerde toegang (via CareTeam membership).

**Voorbeeld Scenario: Launch van een activiteit**

**Situatie:**
- Patient: Maria de Vries
- CareTeam voor Maria bevat:
  - Dr. Peters (behandelaar)
  - Psycholoog van Dam (zorgondersteuner)
  - Zoon van Maria (eerste relatie)
- Task: "Dagboek invullen" (status: ready, owner: CareTeam Maria)

**Launch door portaalapplicatie:**
```
Portal initieert SMART on FHIR launch naar dagboek-applicatie

HTI Token bevat:
{
  "sub": "RelatedPerson/zoon-maria",
  "patient": "Patient/maria-de-vries",
  "fhirUser": "RelatedPerson/zoon-maria",
  "launch_context": {
    "task": "Task/dagboek-invullen"
  }
}
```

**Autorisatie validatie:**
1. ✅ Token bevat valide `sub` (Zoon van Maria)
2. ✅ Zoon van Maria is lid van CareTeam voor Maria de Vries
3. ✅ Zoon heeft rol "eerste relatie" in het CareTeam
4. ✅ Task.for verwijst naar Patient/maria-de-vries (komt overeen met patient in token)
5. ✅ Launch wordt toegestaan

**Resultaat:** De dagboek-applicatie wordt gelanceerd en Zoon van Maria krijgt toegang tot de Task "Dagboek invullen" voor zijn moeder. De autorisatie is gebaseerd op zijn lidmaatschap van het CareTeam, maar de launch beslissing wordt genomen door de portaalapplicatie.

**Afwijzing scenario:**
Als het token `"sub": "RelatedPerson/vriend-van-maria"` zou bevatten, en deze persoon is **geen** lid van het CareTeam, dan zou de launch worden afgewezen:
```
❌ Ongeldig: Vriend van Maria is geen lid van het CareTeam voor Maria de Vries
→ HTTP 403 Forbidden
→ Foutmelding: "User not authorized for this patient context"
```

##### Fijnmazige toegang met sub-taken

Voor situaties waar meer granulaire autorisatie nodig is, kunnen sub-tasks worden gebruikt:

- De specifieke authenticatie en autorisatie van een RelatedPerson of Practitioner kan in FHIR worden gerepresenteerd via sub-tasks
- Door een sub-task aan te maken, kan fijnmazige toegang worden verleend aan een specifieke Practitioner of RelatedPerson voor een bepaalde taak
- Ook hier geldt: de Practitioner of RelatedPerson moet lid zijn van het CareTeam met de juiste rol
- Sub-tasks bieden dus een FHIR-native manier om taak-specifieke autorisaties uit te drukken binnen de context van het bredere CareTeam

Deze aanpak biedt de structuur en traceerbaarheid van FHIR (via CareTeam en sub-tasks) voor fijnmazige autorisatiecontrole.

**Voorbeeld Scenario: Sub-task voor specifieke toegang**

**Situatie:**
- Patient: Jan Jansen
- CareTeam voor Jan bevat:
  - Dr. Smit (behandelaar)
  - Psycholoog van Dam (zorgondersteuner)
  - Verpleegkundige Peters (zorgondersteuner)
  - Zorgondersteuner Klaas (zorgondersteuner)
  - Partner van Jan (eerste relatie)

**Hoofdtaak met brede toegang:**
```json
{
  "resourceType": "Task",
  "id": "behandelplan-opstellen",
  "status": "in-progress",
  "intent": "order",
  "for": {
    "reference": "Patient/jan-jansen"
  },
  "owner": {
    "reference": "Practitioner/dr-smit"
  },
  "description": "Behandelplan opstellen voor depressie"
}
```
→ Eigenaar: Dr. Smit (behandelaar)
→ Zichtbaar voor: Alle leden van CareTeam Jan Jansen

**Sub-task voor specifieke medewerker:**
```json
{
  "resourceType": "Task",
  "id": "vragenlijst-afnemen",
  "status": "ready",
  "intent": "order",
  "partOf": [{
    "reference": "Task/behandelplan-opstellen"
  }],
  "for": {
    "reference": "Patient/jan-jansen"
  },
  "owner": {
    "reference": "Practitioner/zorgondersteuner-klaas"
  },
  "requester": {
    "reference": "Practitioner/dr-smit"
  },
  "description": "PHQ-9 vragenlijst afnemen"
}
```
→ Eigenaar: Zorgondersteuner Klaas (specifiek toegewezen)
→ Aanvrager: Dr. Smit (heeft sub-task gecreëerd)

**Launch en autorisatie:**

*Scenario 1: Zorgondersteuner Klaas lanceert de vragenlijst-applicatie*
```
HTI Token bevat:
{
  "sub": "Practitioner/zorgondersteuner-klaas",
  "patient": "Patient/jan-jansen",
  "fhirUser": "Practitioner/zorgondersteuner-klaas",
  "launch_context": {
    "task": "Task/vragenlijst-afnemen"
  }
}

Autorisatie validatie:
1. ✅ Zorgondersteuner Klaas is lid van CareTeam Jan Jansen
2. ✅ Task.owner = Practitioner/zorgondersteuner-klaas (exacte match)
3. ✅ Task.for = Patient/jan-jansen (komt overeen met CareTeam patient)
4. ✅ Launch toegestaan - Klaas is direct eigenaar van deze sub-task
```

*Scenario 2: Dr. Smit (requester) wil de voortgang bekijken*
```
HTI Token bevat:
{
  "sub": "Practitioner/dr-smit",
  "patient": "Patient/jan-jansen",
  "fhirUser": "Practitioner/dr-smit",
  "launch_context": {
    "task": "Task/vragenlijst-afnemen"
  }
}

Autorisatie validatie:
1. ✅ Dr. Smit is lid van CareTeam Jan Jansen
2. ✅ Dr. Smit is requester van deze sub-task
3. ✅ Dr. Smit is owner van de parent task
4. ✅ Launch toegestaan - Smit heeft toegang als requester en behandelaar
```

*Scenario 3: Verpleegkundige Peters probeert toegang te krijgen*
```
HTI Token bevat:
{
  "sub": "Practitioner/verpleegkundige-peters",
  "patient": "Patient/jan-jansen",
  "fhirUser": "Practitioner/verpleegkundige-peters",
  "launch_context": {
    "task": "Task/vragenlijst-afnemen"
  }
}

Autorisatie validatie:
1. ✅ Verpleegkundige Peters is lid van CareTeam Jan Jansen
2. ⚠️ Peters is niet owner van deze specifieke sub-task
3. ⚠️ Peters is niet requester van deze sub-task

Beslissing: Afhankelijk van autorisatiebeleid:
- Optie A (restrictief): ❌ Toegang geweigerd - alleen owner/requester
- Optie B (permissief): ✅ Toegang toegestaan - alle CareTeam leden mogen taken inzien
```

**Voordelen van sub-tasks:**
- **Expliciete toewijzing:** Duidelijk wie verantwoordelijk is voor specifieke deeltaken
- **Traceerbaarheid:** Vastlegging in FHIR van wie wat mag/moet doen
- **Flexibiliteit:** Kan gecombineerd worden met verschillende autorisatiemodellen
- **Workflow management:** Ondersteunt complexe behandelprocessen met meerdere betrokkenen

**Use cases:**
- Toewijzen van specifieke vragenlijsten aan specifieke zorgverleners
- Delegeren van intake-taken aan gespecialiseerde medewerkers
- Opdelen van behandelplan in deeltaken per discipline
- Toestemming voor tijdelijke toegang (bijv. vervanging tijdens vakantie)

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

4. **Keuze tussen CareTeam types**

   Het systeem ondersteunt drie types CareTeams (zie Types van CareTeams hierboven):
   - **Type 1:** Organisatie CareTeams (geen patient binding)
   - **Type 2:** Patiënt-specifieke CareTeams (patient-wide scope)
   - **Type 3:** Task level CareTeams (task-specific scope)

   **Belangrijke overwegingen bij de keuze:**

   *Autorisatie-architectuur van achterliggende systemen:*
   - Hoe zijn autorisaties in de achterliggende systemen georganiseerd?
   - Is autorisatie **patient-georganiseerd** (toegang tot alle data van een patiënt)?
   - Of is autorisatie **taak-georganiseerd** (toegang tot specifieke taken/activiteiten)?
   - Deze architectuur moet leidend zijn voor de keuze van CareTeam type
   - Mismatch tussen CareTeam type en systeem-architectuur leidt tot complexe mappings en potentiële beveiligingsproblemen

   *Gebruik van Patiënt-specifieke CareTeams (Type 2):*
   - **Beste keuze wanneer:** Achterliggende systemen patient-georganiseerde autorisaties hebben
   - Natuurlijke mapping: CareTeam membership = toegang tot alle patiëntdata
   - Eenvoudiger te beheren: één team per patiënt
   - Geen synchronisatie-overhead bij teamwijzigingen over meerdere taken
   - Minder fragmentatie van autorisatie-informatie

   *Gebruik van Task level CareTeams (Type 3):*
   - **Beste keuze wanneer:** Achterliggende systemen taak-georganiseerde autorisaties hebben
   - Natuurlijke mapping: Task CareTeam = toegang tot specifieke taak en gerelateerde data
   - Fijnmazige controle over wie toegang heeft tot specifieke taken
   - Wel rekening houden met synchronisatie-overhead bij teamwijzigingen (zie nadelen Type 3)

   *Hybride aanpak:*
   - Mogelijk om beide types te combineren voor verschillende use cases
   - Bijvoorbeeld: Patiënt-specifieke CareTeams voor reguliere zorg, Task level CareTeams voor gespecialiseerde interventies
   - Vereist duidelijke governance over wanneer welk type wordt gebruikt

### Zie Ook

- [Autorisaties overzicht](autorisaties.html)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)
- [Patient autorisaties](autorisaties-patient.html)
- [Koppeltaal Domeinen - Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden)
