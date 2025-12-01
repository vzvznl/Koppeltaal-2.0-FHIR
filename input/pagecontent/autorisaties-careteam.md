### Changelog

| Datum | Wijziging |
|-------|-----------|
| 2025-12-01 | HTI token voorbeelden aangepast conform [HTI 2.0 specificatie](https://github.com/GIDSOpenStandaarden/GIDS-HTI-Protocol/blob/main/HTI_2.0.md) |

---

Deze pagina beschrijft de rol van CareTeam binnen het autorisatiemodel van het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

### Wat is een CareTeam?

Een CareTeam is een groep van personen (Practitioners en/of RelatedPersons) die samenwerken aan de zorg voor een specifieke patiënt of binnen een specifieke organisatiecontext. Het CareTeam resource fungeert als de centrale plek waar wordt vastgelegd:
- Wie er betrokken is bij de zorg
- In welke rol zij betrokken zijn
- Voor welke patiënt of organisatie-afdeling het team verantwoordelijk is

### Types van CareTeams

Er zijn drie hoofdtypen van CareTeams in het systeem:

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
- **Onduidelijke verantwoordelijkheid:** Wanneer een Task is toegewezen aan een CareTeam (in plaats van een individuele Practitioner of RelatedPerson), is het onduidelijk wie de taak daadwerkelijk moet uitvoeren. Dit kan leiden tot taken die blijven liggen omdat niemand zich persoonlijk verantwoordelijk voelt

### Autorisatiemodel CareTeam (Voorstel)

Het gebruik van het CareTeam als autorisatiemodel is onderdeel van het breder uitzetten van het autorisatiemodel in Koppeltaal 2.0. Het CareTeam is een van de entiteiten betrokken in het autorisatiemodel, maar zeker niet de enige entiteit noch middel betrokken in het autorisatiemodel.
Het voorgestelde autorisatiemodel voor CareTeams is gebaseerd op onderstaande principes om een duidelijke en veilige autorisatiestructuur te garanderen:

#### Basisprincipes

1. **Meerdere CareTeams per patiënt mogelijk**
   - Er kunnen meerdere actieve CareTeams bestaan voor dezelfde patiënt binnen dezelfde organisatie
   - Dit kan bijvoorbeeld voorkomen bij parallelle behandeltrajecten of verschillende zorgprogramma's
   - Voor organisatie-teams (zonder patiënt) kunnen er meerdere CareTeams per afdeling/team bestaan

   **Ambiguïteit bij meerdere rollen:**
   - Een deelnemer kan in meerdere CareTeams voorkomen met verschillende rollen
   - Bijvoorbeeld: een Practitioner is "behandelaar" in CareTeam A en "zorgondersteuner" in CareTeam B voor dezelfde patiënt
   - Het is aan de applicatie zelf om te bepalen hoe met deze ambiguïteit om te gaan:
     - **Optie A:** Meerdere rollen toestaan en combineren
     - **Optie B:** Één rol boven de andere plaatsen (bijvoorbeeld behandelaar > zorgondersteuner)
     - **Optie C:** Context-afhankelijk de relevante rol selecteren (bijvoorbeeld op basis van de Task)

2. **Alle betrokkenen in het CareTeam**
   - Alle betrokken Practitioners **moeten** met hun correcte rol in het CareTeam staan
   - Alle betrokken RelatedPersons **moeten** met hun correcte rol in het CareTeam staan
   - De rol bepaalt de autorisaties volgens de autorisatiematrix

   **Scope van het CareTeam:**
   - Het FHIR CareTeam heeft betrekking op de *uitwisseling* van gegevens tussen systemen binnen het Koppeltaal domein. Koppeltaal beperkt zich tot het delen van gegevens die nodig zijn voor het uitvoeren van de Use Cases.
   - Binnen een applicatie (zoals een ECD) kunnen bredere autorisaties gelden dan wat in het CareTeam is vastgelegd.
   - Bijvoorbeeld: administratieve medewerkers die taken klaarzetten hoeven niet in het CareTeam te staan als verder geen deelnemer zijn in het zorgproces.

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

5. **CareTeam als Task.owner** ❌
   - Een CareTeam kan **niet** direct Task.owner zijn
   - Tasks worden altijd toegewezen aan individuele Practitioners of RelatedPersons die lid zijn van het CareTeam
   - Dit voorkomt onduidelijkheid over wie verantwoordelijk is voor de uitvoering van een taak

#### Validatieregels

Bij het aanmaken of wijzigen van Tasks moeten de volgende validaties plaatsvinden:

**Task.owner validatie:**
```
Task.owner MOET verwijzen naar een Practitioner of RelatedPerson (niet naar een CareTeam)
EN deze persoon MOET lid zijn van een CareTeam van Task.for (patient)
```

**Task.requester validatie:**
```
Als Task.requester is ingevuld:
  MOET deze persoon lid zijn van een CareTeam van Task.for (patient)
```

**Task.for (patient) validatie:**
```
Als Task.for verwijst naar een Patient:
  MOET er minimaal één CareTeam bestaan met CareTeam.patient = deze Patient
  EN Task.owner en Task.requester moeten lid zijn van minimaal één van deze CareTeams
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
- Task: "Dagboek invullen" (status: ready, owner: Zoon van Maria)

**Launch door portaalapplicatie:**
```
Portal initieert SMART on FHIR launch naar dagboek-applicatie

HTI Token bevat:
{
  "iss": "https://portal.example.org",
  "aud": "https://dagboek-app.example.org",
  "jti": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "iat": 1733054400,
  "exp": 1733054700,
  "sub": "RelatedPerson/zoon-maria",
  "patient": "Patient/maria-de-vries",
  "resource": "Task/dagboek-invullen"
}
```

**Autorisatie validatie:**
1. ✅ Token bevat valide `sub` (Zoon van Maria)
2. ✅ Zoon van Maria is lid van een CareTeam voor Maria de Vries
3. ✅ Zoon heeft rol "eerste relatie" in het CareTeam
4. ✅ Task.for verwijst naar Patient/maria-de-vries (komt overeen met patient in token)
5. ✅ Launch wordt toegestaan

**Resultaat:** De dagboek-applicatie wordt gelanceerd en Zoon van Maria krijgt toegang tot de Task "Dagboek invullen" voor zijn moeder. De autorisatie is gebaseerd op zijn lidmaatschap van het CareTeam, maar de launch beslissing wordt genomen door de portaalapplicatie.

**Afwijzing scenario:**
Als het token `"sub": "RelatedPerson/vriend-van-maria"` zou bevatten, en deze persoon is **geen** lid van het CareTeam, dan zou de launch worden afgewezen:
```
❌ Ongeldig: Vriend van Maria is geen lid van een CareTeam voor Maria de Vries
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
  "iss": "https://portal.example.org",
  "aud": "https://vragenlijst-app.example.org",
  "jti": "b2c3d4e5-f6a7-8901-bcde-f23456789012",
  "iat": 1733054400,
  "exp": 1733054700,
  "sub": "Practitioner/zorgondersteuner-klaas",
  "patient": "Patient/jan-jansen",
  "resource": "Task/vragenlijst-afnemen"
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
  "iss": "https://portal.example.org",
  "aud": "https://vragenlijst-app.example.org",
  "jti": "c3d4e5f6-a7b8-9012-cdef-345678901234",
  "iat": 1733054400,
  "exp": 1733054700,
  "sub": "Practitioner/dr-smit",
  "patient": "Patient/jan-jansen",
  "resource": "Task/vragenlijst-afnemen"
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
  "iss": "https://portal.example.org",
  "aud": "https://vragenlijst-app.example.org",
  "jti": "d4e5f6a7-b8c9-0123-def0-456789012345",
  "iat": 1733054400,
  "exp": 1733054700,
  "sub": "Practitioner/verpleegkundige-peters",
  "patient": "Patient/jan-jansen",
  "resource": "Task/vragenlijst-afnemen"
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
❌ Ongeldig: Dr. Anderen is geen lid van een CareTeam voor Jan Jansen

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

### Besluiten en Richtlijnen

De volgende besluiten zijn genomen voor het autorisatiemodel:

1. **CareTeam als Task.owner** ❌
   - Een CareTeam kan **niet** direct Task.owner zijn
   - Tasks worden altijd toegewezen aan individuele Practitioners of RelatedPersons
   - Dit voorkomt onduidelijkheid over verantwoordelijkheid en zorgt voor duidelijke notificaties

2. **Ambiguïteit bij meerdere CareTeams** ✅
   - Een deelnemer kan in meerdere CareTeams voorkomen met verschillende rollen
   - In realiteit heeft een gebruiker dan meerdere rollen
   - Het is aan de applicatie zelf om een strategie te kiezen voor hoe hiermee om te gaan (zie [Basisprincipe 1](#basisprincipes))

3. **Gekozen CareTeam type: Patiënt-specifieke CareTeams (Type 2)** ✅
   - Koppeltaal gebruikt Patiënt-specifieke CareTeams als standaard
   - Meerdere CareTeams per patiënt zijn mogelijk voor verschillende behandeltrajecten
   - Fijnmazige autorisatie wordt bereikt via sub-tasks en SMART on FHIR launches (niet via Task level CareTeams)

4. **Onderscheid CareTeam structuur en autorisatie mechanismen** ✅

   Het CareTeam is één van de autorisatie-mechanismen, maar niet het enige:

   **Autorisatie mechanismen in Koppeltaal:**
   - **CareTeam membership:** Basisautorisatie via lidmaatschap en rol
   - **Sub-tasks:** Taak-specifieke toewijzingen aan individuele personen
   - **SMART on FHIR launches:** Launch-time autorisatiebeslissingen via HTI tokens

   Deze mechanismen kunnen gecombineerd worden. Bijvoorbeeld: een Patiënt-specifiek CareTeam met fijnmazige toegang via sub-tasks en launches.

   **Voorbeeld combinatie:**
   ```
   CareTeam Type 2 (Patiënt-niveau):
   ├── CareTeam voor Jan Jansen
   │   ├── Dr. Smit (behandelaar)
   │   ├── Zorgondersteuner Klaas (zorgondersteuner)
   │   └── Verpleegkundige Peters (zorgondersteuner)
   │
   └── Autorisatie op taak-niveau via:
       ├── Sub-task: "Vragenlijst PHQ-9"
       │   └── Owner: Zorgondersteuner Klaas (specifiek)
       │
       └── Launch: HTI token met sub: Practitioner/zorgondersteuner-klaas
           └── Launch beslissing: toegang tot specifieke sub-task
   ```

### Zie Ook

- [Autorisaties overzicht](autorisaties.html)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)
- [Patient autorisaties](autorisaties-patient.html)
- [Koppeltaal Domeinen - Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden)
