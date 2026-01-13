### Changelog

| Versie | Datum      | Wijziging                                                                  |
|--------|------------|----------------------------------------------------------------------------|
| 0.0.3  | 2026-01-13 | Beslispunt 1: voorkeur gewijzigd naar Optie A (Via CareTeam)               |
| 0.0.2  | 2026-01-13 | Tabelstructuur aangepast: Search Narrowing kolom                           |
| 0.0.2  | 2026-01-13 | Beslispunt 2: voorkeur Optie A - Patient alleen toegang als subject        |
| 0.0.2  | 2026-01-13 | Beslispunt 3 toegevoegd: Zichtbaarheid CareTeam leden                      |
| 0.0.1  | 2025-12-09 | Optie D (Geen toegang) toegevoegd aan Beslispunt 1 RelatedPerson koppeling |
| 0.0.1  | 2025-12-09 | Verduidelijking van self-service en "on behalf of" scenario's              |

---

### Autorisatieregels voor Patient toegang

Deze pagina beschrijft de autorisatieregels voor een Patient rol binnen het KoppelMij/Koppeltaal geharmoniseerde model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

#### Context en Launch types
De onderstaande autorisatieregels gelden voor **alle launch types** waarbij een Patient betrokken is:

1. **Taak context**: Wanneer een taak wordt gelauncht die eigendom is van deze patiënt
2. **Behandelaar context met patient selectie**: Wanneer een behandelaar een taak start voor deze specifieke patiënt

Deze autorisaties worden gebruikt wanneer:
- Een patiënt een KoppelMij launch uitvoert via een PGO (Persoonlijke Gezondheidsomgeving) in de context van een Taak
- Een patiënt een Koppeltaal launch uitvoert via een cliëntportaal in de context van een Taak
- Een patiënt zelfstandig een zelfhulptaak start vanuit een applicatie die self-service functionaliteit aanbiedt
- Een behandelaar namens de patiënt een taak uitvoert ("on behalf of"), bijvoorbeeld wanneer zij samen met de patiënt een taak doorloopt

#### Autorisatieregels

| Entiteit               | Toegang                                                                                                      | CRUD   | Search Narrowing                                                                                             |
|------------------------|--------------------------------------------------------------------------------------------------------------|--------|--------------------------------------------------------------------------------------------------------------|
| **Patient**            | Enkel mijzelf                                                                                                | R      | `Patient?identifier=system\|user_id`                                                                         |
| **Practitioner**       | Via CareTeam, zie [Beslispunt 3](#beslispunt-3-zichtbaarheid-careteam-leden)                                 | R      | `Practitioner?_has:CareTeam:participant:patient=Patient/{id}`                                                |
| **RelatedPerson**      | Zie [Beslispunt 1](#beslispunt-1-relatedperson-koppeling) en [3](#beslispunt-3-zichtbaarheid-careteam-leden) | R      | Zie [Beslispunt 1](#beslispunt-1-relatedperson-koppeling) en [3](#beslispunt-3-zichtbaarheid-careteam-leden) |
| **CareTeam**           | Zie [Beslispunt 2](#beslispunt-2-patient-als-careteam-participant)                                           | R      | Zie [Beslispunt 2](#beslispunt-2-patient-als-careteam-participant)                                           |
| **ActivityDefinition** | Enkel van type zelfhulp*                                                                                     | R      | `ActivityDefinition?topic=self-help`                                                                         |
| **Task**               | Eigen taken                                                                                                  | C*R    | `Task?owner=Patient/{id}`                                                                                    |
| **Task Launch**        | Eigen taken                                                                                                  | Launch | `Task?owner=Patient/{id}`                                                                                    |

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
| **A** | **Via CareTeam (voorstel)**              | RelatedPerson moet lid zijn van een CareTeam waar de Patient subject van is | `RelatedPerson?_has:CareTeam:participant:patient=Patient/{id}` |
| B     | Via RelatedPerson.patient                | Directe koppeling via het `patient` veld van RelatedPerson                  | `RelatedPerson?patient=Patient/{id}`                           |
| C     | Beide methoden                           | Toegang via CareTeam óf via directe `RelatedPerson.patient` koppeling       | Combinatie van A en B                                          |
| D     | Geen toegang                             | Patient heeft geen toegang tot RelatedPerson resources                      | N.v.t.                                                         |

**Overwegingen:**
- **Optie A (CareTeam):** Consistent met hoe Practitioner toegang werkt; alle autorisatie via CareTeam
- **Optie B (RelatedPerson.patient):** Simpeler, directe FHIR relatie; RelatedPerson is per definitie gekoppeld aan een Patient
- **Optie C (Beide):** Maximale flexibiliteit, maar complexer te implementeren en valideren
- **Optie D (Geen):** Meest restrictief; Patient hoeft mogelijk geen inzicht te hebben in welke RelatedPersons aan hen gekoppeld zijn

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

#### Beslispunt 3: Zichtbaarheid CareTeam leden

**Vraag:** Zijn alle leden (Practitioner en RelatedPerson) van het CareTeam zichtbaar voor de Patient, of moet dit op basis van rol worden bepaald?

**Context:** Een Patient heeft via het CareTeam toegang tot Practitioners en RelatedPersons die betrokken zijn bij de zorg. Er zijn echter situaties denkbaar waarin bepaalde rollen niet zichtbaar zouden moeten zijn voor de Patient. Bijvoorbeeld: een Wettelijk vertegenwoordiger die namens de Patient handelt, maar waarvan de Patient (bijvoorbeeld een minderjarige of wilsonbekwame) niet op de hoogte hoeft te zijn.

**Opties:**

| Optie | Beschrijving                        | Implicatie                                                                      |
|-------|-------------------------------------|---------------------------------------------------------------------------------|
| **A** | **Alle leden zichtbaar (voorstel)** | Patient ziet alle Practitioners en RelatedPersons in het CareTeam               |
| B     | Zichtbaarheid op basis van rol      | Bepaalde rollen (bijv. Wettelijk vertegenwoordiger) kunnen onzichtbaar zijn     |

**Overwegingen:**
- **Optie A (Alle leden):** Simpeler te implementeren; transparantie naar de Patient
- **Optie B (Op basis van rol):** Meer complexiteit; vereist rol-gebaseerde filtering in de Search Narrowing query; relevant voor specifieke scenario's (minderjarigen, wilsonbekwaamheid)

**Besluit:** *Nog te bepalen*

