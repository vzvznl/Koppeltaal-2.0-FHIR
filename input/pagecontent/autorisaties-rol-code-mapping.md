### Changelog

| Versie | Datum      | Wijziging                                                              |
|--------|------------|------------------------------------------------------------------------|
| 0.4.0  | 2026-02-17 | Eigen CodeSystem vervangen door SNOMED CT codes (Nictiz review)        |
| 0.3.0  | 2026-02-17 | SNOMED mapping bijgewerkt op basis van Nictiz review (Mirte)           |
| 0.2.0  | 2026-02-12 | SNOMED CT mapping vervangen door eigen Koppeltaal CodeSystem           |
| 0.1.0  | 2026-01-22 | Koppeltaal CodeSystem geïntroduceerd voor autorisatierollen            |
| 0.0.3  | 2026-01-20 | RelatedPerson code mapping toegevoegd                                  |
| 0.0.2  | 2026-01-20 | Codes bijgewerkt op basis van review                                   |
| 0.0.1  | 2026-01-20 | Initiële versie met SNOMED CT code mapping                             |

---

### Rol Code Mapping voor Autorisaties

Deze pagina beschrijft de mapping tussen de functionele rollen zoals gedefinieerd in de autorisatieregels en de bijbehorende SNOMED CT codes. Deze codes worden gebruikt in `CareTeam.participant.role` om de autorisatierol van een deelnemer te identificeren.

De SNOMED CT codes zijn gereviewd door Nictiz (Mirte).

#### Code System

```
CodeSystem: http://snomed.info/sct
```

---

### Practitioner Rollen

De onderstaande SNOMED CT codes zijn beschikbaar voor Practitioners binnen een CareTeam. De permissies per rol zijn beschreven in [Practitioner autorisaties](autorisaties-practitioner.html).

| Rol | SNOMED CT Code | SNOMED CT Term | Permissies |
|:----|:---------------|:---------------|:-----------|
| **Behandelaar** | `405623001` | Assigned practitioner (occupation) | Volledige CRUD rechten op patiënten in CareTeam |
| **Zorgondersteuner** | `224608005` | Administrative healthcare staff (occupation) | Taken klaarzetten, niet starten |
| **Case Manager** | `768821004` | Care team coordinator (occupation) | Leestoegang organisatie-breed, taken starten |
| **Practitioner zonder rol in CareTeam** | - | - | Minimale rechten |
| **Overige rollen** | - | - | Fallback, minimale rechten |

#### ValueSet

```
ValueSet: http://vzvz.nl/fhir/ValueSet/koppeltaal-practitioner-role
```

Deze ValueSet bevat:
- De SNOMED CT autorisatierollen voor Practitioners
- Alle codes uit de [ZorgverlenerRolCodelijst](https://simplifier.net/nictiz-r4-zib2020/2.16.840.1.113883.2.4.3.11.60.40.2.17.1.5--20200901000000) (backwards compatibility)

#### Voorbeeld: Practitioner als Behandelaar

```json
{
  "resourceType": "CareTeam",
  "participant": [
    {
      "role": [
        {
          "coding": [
            {
              "system": "http://snomed.info/sct",
              "code": "405623001",
              "display": "Assigned practitioner (occupation)"
            }
          ]
        }
      ],
      "member": {
        "reference": "Practitioner/123"
      }
    }
  ]
}
```

---

### RelatedPerson Relaties

De onderstaande SNOMED CT codes zijn beschikbaar voor RelatedPersons binnen een CareTeam. De permissies per relatie zijn beschreven in [RelatedPerson autorisaties](autorisaties-relatedperson.html).

| Relatie | SNOMED CT Code | SNOMED CT Term | Permissies |
|:--------|:---------------|:---------------|:-----------|
| **Mantelzorger** | `407542009` | Informal carer (person) | Meekijken, beperkt uitvoeren, leestoegang patiënttaken |
| **Wettelijk vertegenwoordiger** | `310391000146105` | Legal representative (person) | Volledige toegang, namens patiënt handelen bij wilsonbekwaamheid |
| **Naaste** | `125677006` | Relative (person) | Meekijken, ondersteunen, alleen eigen taken |
| **Buddy** | `62071000` | Buddy (person) | Meekijken, ondersteunen, alleen eigen taken |
| **Geen rol in CareTeam** | - | - | Alleen eigen taken |
| **Overige relaties** | - | - | Fallback, minimale rechten |

#### ValueSet

```
ValueSet: http://vzvz.nl/fhir/ValueSet/koppeltaal-relatedperson-role
```

#### Specifieke familierelaties

Voor meer specifieke familierelaties kunnen de volgende SNOMED CT codes worden gebruikt:

| SNOMED CT Code | SNOMED CT Term | Nederlandse term |
|:---------------|:---------------|:-----------------|
| `303071001` | Person in the family (person) | Familielid (algemeen) |
| `40683002` | Parent (person) | Ouder |
| `67822003` | Child (person) | Kind |
| `262043009` | Partner (person) | Partner |
| `375005` | Sibling (person) | Broer/zus |
| `113163005` | Friend (person) | Vriend(in) |

#### Onderscheid RelatedPerson.relationship en CareTeam rol

De `RelatedPerson.relationship` en de `CareTeam.participant.role` leggen twee verschillende dimensies vast:

- **`RelatedPerson.relationship`** beschrijft _wie_ iemand is ten opzichte van de patiënt: de sociale of biologische band (ouder, partner, vriend). Dit gebruikt de standaard FHIR ValueSet [`relatedperson-relationshiptype`](http://hl7.org/fhir/ValueSet/relatedperson-relationshiptype).
- **`CareTeam.participant.role`** beschrijft _welke rol_ iemand vervult in de zorgcontext, en daarmee welke autorisaties gelden (mantelzorger, wettelijk vertegenwoordiger, naaste, buddy).

Deze dimensies zijn niet uitwisselbaar: een ouder (relationship) kan mantelzorger _of_ wettelijk vertegenwoordiger zijn (rol). Een vriend (relationship) kan naaste _of_ buddy zijn (rol). De sociale relatie bepaalt niet automatisch de autorisatierol.

**De CareTeam rol is leidend voor autorisatie.** De `RelatedPerson.relationship` is informatief en kan gebruikt worden om context te bieden (wie is deze persoon voor de patiënt), maar de rechten worden altijd afgeleid van de `CareTeam.participant.role`.

#### Voorbeeld: RelatedPerson als Mantelzorger

```json
{
  "resourceType": "CareTeam",
  "participant": [
    {
      "role": [
        {
          "coding": [
            {
              "system": "http://snomed.info/sct",
              "code": "407542009",
              "display": "Informal carer (person)"
            }
          ]
        }
      ],
      "member": {
        "reference": "RelatedPerson/456"
      }
    }
  ]
}
```

---

### Autorisatielogica

De autorisatielogica werkt als volgt:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  1. Haal CareTeam(s) op waar gebruiker lid van is                       │
│     CareTeam?participant=Practitioner/{id}                              │
│     CareTeam?participant=RelatedPerson/{id}                             │
├─────────────────────────────────────────────────────────────────────────┤
│  2. Bepaal rol binnen elk CareTeam                                      │
│     CareTeam.participant[x].role.coding                                 │
│     system = http://snomed.info/sct                                     │
├─────────────────────────────────────────────────────────────────────────┤
│  3. Leid permissies af van SNOMED code via permissiematrix              │
│     405623001 (behandelaar) → CRUD op CareTeam resources                │
│     224608005 (zorgondersteuner) → CRUD taken, geen launch              │
│     768821004 (case manager) → organisatie-breed lezen, taken starten   │
│     etc.                                                                │
├─────────────────────────────────────────────────────────────────────────┤
│  4. Pas permissies toe bij resource access                              │
│     Search narrowing, CRUD restricties                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### Fallback Gedrag

#### Practitioner zonder autorisatierol

Wanneer een Practitioner wel lid is van een CareTeam maar geen SNOMED autorisatiecode uit de ValueSet heeft (alleen ZorgverlenerRolCodelijst code), gelden de regels van **"Practitioner zonder rol in CareTeam"**:
- Alleen eigen taken en toegewezen resources
- Minimale rechten

#### RelatedPerson zonder rol

Wanneer een RelatedPerson niet is opgenomen in een CareTeam of geen rol heeft, gelden de regels van **"Geen rol in CareTeam"**:
- Alleen eigen taken
- Geen toegang tot patiënttaken

---

### Implementatieoverwegingen

#### Binding Strength

De ValueSet bindings zijn `extensible`:
- SNOMED CT codes MOETEN worden gebruikt voor autorisatie
- Aanvullende codes (zoals ZorgverlenerRolCodelijst) MOGEN worden toegevoegd
- Onbekende codes vallen terug op minimale rechten

#### SNOMED CT Hiërarchie en Subsumptie

SNOMED CT is een hiërarchisch terminologiestelsel. De codes in de Koppeltaal ValueSets bevinden zich op verschillende niveaus in deze hiërarchie. Terminologisch gezien zou een hogere code ook moeten gelden voor alle onderliggende (meer specifieke) codes — dit heet _subsumptie_.

Koppeltaal maakt **vooralsnog geen gebruik van subsumptie**. De gekozen codes worden als discrete codes behandeld: alleen de exact gespecificeerde codes in de ValueSets worden herkend voor autorisatiedoeleinden. Subsumptie kan in de toekomst een rol spelen, maar voor het huidige model houden we de logica eenvoudig en expliciet.

#### Meerdere Rollen

Een participant kan meerdere `role` codings hebben. De autorisatielogica evalueert de **meest specifieke SNOMED CT code** die aanwezig is.

#### Validatie

De FHIR Validator accepteert:
- SNOMED CT codes uit de Koppeltaal ValueSets
- Codes uit de ZorgverlenerRolCodelijst (via include in ValueSet)

---

### Referenties

- [SNOMED CT Browser](https://browser.ihtsdotools.org/)
- [KoppeltaalPractitionerRoleValueSet](ValueSet-koppeltaal-practitioner-role.html)
- [KoppeltaalRelatedPersonRoleValueSet](ValueSet-koppeltaal-relatedperson-role.html)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)
- [CareTeam profiel](StructureDefinition-KT2CareTeam.html)
