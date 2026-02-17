### Changelog

| Versie | Datum      | Wijziging                                                              |
|--------|------------|------------------------------------------------------------------------|
| 0.3.0  | 2026-02-17 | SNOMED mapping bijgewerkt op basis van Nictiz review (Mirte)           |
| 0.2.0  | 2026-02-12 | SNOMED CT mapping vervangen door eigen Koppeltaal CodeSystem           |
| 0.1.0  | 2026-01-22 | Koppeltaal CodeSystem geïntroduceerd voor autorisatierollen            |
| 0.0.3  | 2026-01-20 | RelatedPerson code mapping toegevoegd                                  |
| 0.0.2  | 2026-01-20 | Codes bijgewerkt op basis van review                                   |
| 0.0.1  | 2026-01-20 | Initiële versie met SNOMED CT code mapping                             |

---

### Autorisatierollen CodeSystem

Koppeltaal 2.0 definieert een eigen CodeSystem voor autorisatierollen binnen CareTeams. Deze rollen bepalen welke permissies een deelnemer heeft binnen de context van een specifiek CareTeam.

#### Waarom een eigen CodeSystem?

De Nederlandse FHIR-standaarden (zibs) gebruiken voor CareTeam-rollen de [ZorgverlenerRolCodelijst](https://simplifier.net/nictiz-r4-zib2020/2.16.840.1.113883.2.4.3.11.60.40.2.17.1.5--20200901000000), die voornamelijk HL7v3 ParticipationType codes bevat (ATND, RESP, REF, etc.) en één SNOMED code (768832004 = Case manager). Deze codes beschrijven klinische participatietypen, geen autorisatieniveaus. Koppeltaal heeft behoefte aan codes die direct gekoppeld zijn aan permissies. Dit is een functionele uitbreiding op de bestaande zibs.

De keuze voor een eigen CodeSystem in plaats van SNOMED:

1. **Expliciete autorisatie**: Codes uit het Koppeltaal CodeSystem kunnen alleen bewust zijn toegekend. Bij hergebruik van bestaande codes (SNOMED, HL7v3) bestaat het risico dat codes die in een andere context zijn toegevoegd onbedoeld permissies triggeren wanneer een resource Koppeltaal binnenkomt.
2. **Geen meerwaarde van SNOMED**: Elke uitbreiding op de zib — of het nu SNOMED of custom is — is niet herkenbaar in andere standaarden. SNOMED voegt hier geen interoperabiliteit toe omdat het gaat om Koppeltaal-specifieke autorisatierollen die in andere contexten niet bestaan.
3. **Eenvoudig**: Directe mapping tussen code en permissiematrix, geen terminologieserver nodig.
4. **Stabiel**: Koppeltaal heeft volledige controle over de codes en hun betekenis. Geen risico op wijzigingen door externe partijen.
5. **Backwards compatible**: De ValueSets breiden de bestaande ZorgverlenerRolCodelijst uit.

#### CodeSystem

```
CodeSystem: http://vzvz.nl/fhir/CodeSystem/koppeltaal-careteam-role
```

---

### Practitioner Rollen

De onderstaande rollen zijn beschikbaar voor Practitioners binnen een CareTeam. De permissies per rol zijn beschreven in [Practitioner autorisaties](autorisaties-practitioner.html).

| Code | Display | Omschrijving | Permissies |
|:-----|:--------|:-------------|:-----------|
| `behandelaar` | Behandelaar | Behandelend zorgverlener | Volledige CRUD rechten op patiënten in CareTeam |
| `zorgondersteuner` | Zorgondersteuner | Ondersteunende rol (incl. administratief) | Taken klaarzetten, niet starten |
| `case-manager` | Case Manager | Organisatie-brede coördinatie | Leestoegang organisatie-breed, taken starten |

#### ValueSet

```
ValueSet: http://vzvz.nl/fhir/ValueSet/koppeltaal-practitioner-role
```

Deze ValueSet bevat:
- Alle codes uit de [ZorgverlenerRolCodelijst](https://simplifier.net/nictiz-r4-zib2020/2.16.840.1.113883.2.4.3.11.60.40.2.17.1.5--20200901000000) (backwards compatibility)
- De Koppeltaal-specifieke autorisatierollen

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
              "system": "http://vzvz.nl/fhir/CodeSystem/koppeltaal-careteam-role",
              "code": "behandelaar",
              "display": "Behandelaar"
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

De onderstaande relaties zijn beschikbaar voor RelatedPersons binnen een CareTeam. De permissies per relatie zijn beschreven in [RelatedPerson autorisaties](autorisaties-relatedperson.html).

| Code | Display | Omschrijving | Permissies |
|:-----|:--------|:-------------|:-----------|
| `naaste` | Naaste | Algemene naaste/verwant | Meekijken, ondersteunen, alleen eigen taken |
| `mantelzorger` | Mantelzorger | Structurele informele zorgverlener | Meekijken, beperkt uitvoeren, leestoegang patiënttaken |
| `wettelijk-vertegenwoordiger` | Wettelijk vertegenwoordiger | Juridisch gemachtigd persoon bij wilsonbekwaamheid | Volledige toegang, namens patiënt handelen |
| `buddy` | Buddy | Ervaringsdeskundige begeleider | Meekijken, ondersteunen, alleen eigen taken |

#### ValueSet

```
ValueSet: http://vzvz.nl/fhir/ValueSet/koppeltaal-relatedperson-role
```

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
              "system": "http://vzvz.nl/fhir/CodeSystem/koppeltaal-careteam-role",
              "code": "mantelzorger",
              "display": "Mantelzorger"
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
│     CareTeam.participant[x].role.coding.code                            │
├─────────────────────────────────────────────────────────────────────────┤
│  3. Leid permissies af van rol via permissiematrix                      │
│     behandelaar → CRUD op CareTeam resources                            │
│     zorgondersteuner → CRUD taken, geen launch                          │
│     etc.                                                                │
├─────────────────────────────────────────────────────────────────────────┤
│  4. Pas permissies toe bij resource access                              │
│     Search narrowing, CRUD restricties                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### Fallback Gedrag

#### Practitioner zonder Koppeltaal rol

Wanneer een Practitioner wel lid is van een CareTeam maar geen Koppeltaal-specifieke rol heeft (alleen ZorgverlenerRolCodelijst code), gelden de regels van **"Practitioner zonder rol in CareTeam"**:
- Alleen eigen taken en toegewezen resources
- Minimale rechten

#### RelatedPerson zonder rol

Wanneer een RelatedPerson niet is opgenomen in een CareTeam of geen rol heeft, gelden de regels van **"Geen rol in CareTeam"**:
- Alleen eigen taken
- Geen toegang tot patiënttaken

---

### SNOMED CT Mapping (informatief)

De onderstaande tabellen tonen de mapping van Koppeltaal autorisatierollen naar SNOMED CT codes. Deze mapping is informatief en is gereviewd door Nictiz (Mirte). De SNOMED codes worden **niet** gebruikt voor autorisatie binnen Koppeltaal, maar kunnen nuttig zijn voor interoperabiliteit met andere systemen.

#### Practitioner SNOMED Mapping

| Koppeltaal Code | SNOMED CT Code | SNOMED CT Term |
|:----------------|:---------------|:---------------|
| `behandelaar` | `405623001` | Assigned practitioner (occupation) |
| `zorgondersteuner` | `224608005` | Administrative healthcare staff (occupation) |
| `case-manager` | `768821004` | Care team coordinator (occupation) |

#### RelatedPerson SNOMED Mapping

| Koppeltaal Code | SNOMED CT Code | SNOMED CT Term |
|:----------------|:---------------|:---------------|
| `mantelzorger` | `407542009` | Informal carer (person) |
| `wettelijk-vertegenwoordiger` | `310391000146105` | Legal representative (person) |
| `naaste` | `125677006` | Relative (person) |
| `buddy` | `62071000` | Buddy (person) |

#### Specifieke familierelaties (SNOMED)

| SNOMED CT Code | SNOMED CT Term | Nederlandse term |
|:---------------|:---------------|:-----------------|
| `303071001` | Person in the family (person) | Familielid (algemeen) |
| `40683002` | Parent (person) | Ouder |
| `67822003` | Child (person) | Kind |
| `262043009` | Partner (person) | Partner |
| `375005` | Sibling (person) | Broer/zus |
| `113163005` | Friend (person) | Vriend(in) |

---

### Implementatieoverwegingen

#### Binding Strength

De ValueSet bindings zijn `extensible`:
- Koppeltaal codes MOETEN worden gebruikt voor autorisatie
- Aanvullende codes (zoals ZorgverlenerRolCodelijst) MOGEN worden toegevoegd
- Onbekende codes vallen terug op minimale rechten

#### Meerdere Rollen

Een participant kan meerdere `role` codings hebben. De autorisatielogica evalueert de **meest specifieke Koppeltaal code** die aanwezig is.

#### Validatie

De FHIR Validator accepteert:
- Koppeltaal codes uit het eigen CodeSystem
- Codes uit de ZorgverlenerRolCodelijst (via include in ValueSet)

---

### Referenties

- [KoppeltaalCareTeamRole CodeSystem](CodeSystem-koppeltaal-careteam-role.html)
- [KoppeltaalPractitionerRoleValueSet](ValueSet-koppeltaal-practitioner-role.html)
- [KoppeltaalRelatedPersonRoleValueSet](ValueSet-koppeltaal-relatedperson-role.html)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)
- [CareTeam profiel](StructureDefinition-KT2CareTeam.html)
