### Changelog

| Versie | Datum      | Wijziging                                      |
|--------|------------|------------------------------------------------|
| 0.0.3  | 2026-01-20 | RelatedPerson code mapping toegevoegd          |
| 0.0.2  | 2026-01-20 | Codes bijgewerkt op basis van review           |
| 0.0.1  | 2026-01-20 | Initiële versie met SNOMED CT code mapping     |

---

### Rol Code Mapping voor Autorisaties

Deze pagina beschrijft de mapping tussen de functionele rollen zoals gedefinieerd in de autorisatieregels en de bijbehorende SNOMED CT codes. Deze codes kunnen worden gebruikt voor:
- Het `PractitionerRole.code` element om de rol van een Practitioner te identificeren
- Het `RelatedPerson.relationship` element om de relatie van een RelatedPerson te identificeren

#### Practitioner Code Mapping

| Situatie                                  | SNOMED CT Code | SNOMED CT Term                               | Omschrijving                                      |
|:------------------------------------------|:---------------|:---------------------------------------------|:--------------------------------------------------|
| **Behandelaar in CareTeam**               | `405623001`    | Assigned practitioner (occupation)           | Toegewezen zorgverlener met volledige toegang     |
| **Zorgondersteuner/Administratief mdw**   | `224609002`    | Administrative healthcare staff (occupation) | Ondersteunende rol, taken klaarzetten             |
| **Case Manager**                          | `224608005`    | Case manager (occupation)                    | Organisatie-breed overzicht en coördinatie        |
| **Practitioner zonder rol in CareTeam**   | `223366009`    | Healthcare professional (occupation)         | Geen specifieke CareTeam rol                      |
| **Overige rollen**                        | -              | -                                            | Fallback voor onbekende UZI/BIG rollen            |

#### Code System

De codes komen uit het SNOMED CT code system:

```
CodeSystem: http://snomed.info/sct
```

#### Detailbeschrijving per code

##### 405623001 - Assigned practitioner (occupation)

Deze code wordt gebruikt voor toegewezen zorgverleners (behandelaars) die actief betrokken zijn bij de behandeling van een patiënt. In het autorisatiemodel wordt deze code gebruikt voor:
- Behandelaars in een CareTeam
- Zorgverleners met volledige CRUD rechten op patiëntgegevens binnen hun CareTeams

##### 224609002 - Administrative healthcare staff (occupation)

Deze code is bedoeld voor medewerkers met een administratieve of ondersteunende rol binnen de zorgorganisatie. In het autorisatiemodel wordt deze code gebruikt voor:
- Zorgondersteuners
- Secretariaatsmedewerkers
- Administratief medewerkers
- Medewerkers die taken kunnen klaarzetten maar niet zelf kunnen starten

##### 224608005 - Case manager (occupation)

De Case manager code wordt gebruikt voor medewerkers met een coördinerende rol. In het autorisatiemodel is dit de Case Manager die:
- Organisatie-breed overzicht heeft
- Taken van alle patiënten binnen de organisatie kan inzien
- Taken kan starten voor patiënten binnen de organisatie

##### 223366009 - Healthcare professional (occupation)

Dit is de algemene parent categorie voor alle zorgverleners in SNOMED CT. Deze code wordt gebruikt als fallback voor:
- Practitioners zonder specifieke rol in een CareTeam
- Situaties waarin geen specifiekere code beschikbaar is

De SNOMED CT hiërarchie onder deze code bevat circa 500 subcategorieën voor meer specifieke rollen zoals artsen, verpleegkundigen en paramedici.

#### Alternatieve Practitioner codes

Afhankelijk van de specifieke context kunnen de volgende alternatieve codes worden overwogen:

| SNOMED CT Code | SNOMED CT Term                    | Mogelijk gebruik                                |
|:---------------|:----------------------------------|:------------------------------------------------|
| `223366009`    | Healthcare professional           | Generieke zorgverlener (parent categorie)       |
| `768820003`    | Care coordinator (occupation)     | Alternatief voor Case Manager                   |
| `224577009`    | Healthcare assistant (occupation) | Zorgondersteuner met direct patiëntcontact      |
| `394618009`    | Medical secretary (occupation)    | Specifiek voor medisch secretariaat             |

---

#### RelatedPerson Code Mapping

De onderstaande tabel toont de mapping voor RelatedPerson relaties zoals gedefinieerd in de [RelatedPerson autorisaties](autorisaties-relatedperson.html).

| Relatie                         | SNOMED CT Code | SNOMED CT Term                    | Omschrijving                                |
|:--------------------------------|:---------------|:----------------------------------|:--------------------------------------------|
| **Mantelzorger**                | `224610006`    | Carer (person)                    | Structurele informele zorgverlener          |
| **Wettelijk vertegenwoordiger** | `419358007`    | Legal guardian (person)           | Juridisch gemachtigd persoon                |
| **Naaste**                      | `133932002`    | Caregiver (person)                | Algemene naaste/verwant                     |
| **Buddy**                       | `125680007`    | Friend (person)                   | Ervaringsdeskundige begeleider              |
| **Geen rol in CareTeam**        | -              | -                                 | Niet opgenomen in CareTeam                  |
| **Overige relaties**            | -              | -                                 | Fallback voor onbekende relaties            |

#### Specifieke familierelaties

Voor meer specifieke familierelaties kunnen de volgende codes worden gebruikt:

| SNOMED CT Code | SNOMED CT Term           | Nederlandse term         |
|:---------------|:-------------------------|:-------------------------|
| `133932002`    | Caregiver (person)       | Familielid (algemeen)    |
| `125677006`    | Relative (person)        | Ouder                    |
| `125676002`    | Person (person)          | Kind                     |
| `125678001`    | Family member (person)   | Echtgenoot/echtgenote    |
| `125679009`    | Sibling (person)         | Broer/zus                |
| `125680007`    | Friend (person)          | Vriend(in)               |

#### Detailbeschrijving RelatedPerson codes

##### 224610006 - Carer (person)

Deze code wordt gebruikt voor mantelzorgers - personen die structureel informele zorg verlenen aan een patiënt. In het autorisatiemodel heeft de mantelzorger:
- Leestoegang tot taken van de patiënt
- Kan eigen taken uitvoeren
- Beperkte uitvoeringsrechten namens de patiënt

##### 419358007 - Legal guardian (person)

Deze code wordt gebruikt voor wettelijk vertegenwoordigers - personen die juridisch gemachtigd zijn om namens de patiënt te handelen. In het autorisatiemodel heeft de wettelijk vertegenwoordiger:
- Volledige toegang tot taken van de patiënt
- Kan taken van de patiënt starten
- Mag namens de patiënt handelen

##### 133932002 - Caregiver (person)

Deze code wordt gebruikt voor naasten - algemene verwanten of familieleden die betrokken zijn bij de zorg. In het autorisatiemodel heeft de naaste:
- Leestoegang tot CareTeam informatie
- Kan eigen taken uitvoeren
- Ondersteunende en communicerende rol

##### 125680007 - Friend (person)

Deze code wordt gebruikt voor buddies en vrienden - personen met een niet-familiale relatie. In het autorisatiemodel heeft de buddy:
- Vergelijkbare rechten als de naaste
- Ondersteunende rol vanuit ervaringsdeskundigheid

---

#### Mapping naar UZI/BIG rollen

De mapping van UZI (Unieke Zorgverlener Identificatie) en BIG (Beroepen in de Individuele Gezondheidszorg) rollen naar de bovenstaande SNOMED CT codes dient nog nader te worden uitgewerkt. Hierbij zijn de volgende overwegingen van belang:

1. **UZI rol-codes**: Het UZI-register kent eigen rol-codes die mogelijk niet 1-op-1 mappen naar SNOMED CT
2. **BIG beroepen**: De BIG-registratie kent specifieke beroepscategorieën die vertaald moeten worden
3. **Fallback strategie**: Wanneer een UZI/BIG code niet kan worden gemapped, valt de Practitioner terug op de "Overige rollen" categorie met minimale rechten

#### Implementatieoverwegingen

##### PractitionerRole resource

De rol-code wordt vastgelegd in het `PractitionerRole.code` element:

```json
{
  "resourceType": "PractitionerRole",
  "code": [
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": "405623001",
          "display": "Assigned practitioner (occupation)"
        }
      ]
    }
  ]
}
```

##### CareTeam.participant.role

Voor het vastleggen van de rol binnen een CareTeam wordt het `CareTeam.participant.role` element gebruikt:

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
        "reference": "Practitioner/example"
      }
    }
  ]
}
```

##### RelatedPerson.relationship

Voor het vastleggen van de relatie van een RelatedPerson wordt het `RelatedPerson.relationship` element gebruikt:

```json
{
  "resourceType": "RelatedPerson",
  "patient": {
    "reference": "Patient/example"
  },
  "relationship": [
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": "224610006",
          "display": "Carer (person)"
        }
      ]
    }
  ]
}
```

#### Referenties

- [SNOMED CT Browser](https://browser.ihtsdotools.org/)
- [FHIR R4 PractitionerRole ValueSet](https://www.hl7.org/fhir/R4/valueset-practitioner-role.html)
- [FHIR R4 RelatedPerson Relationship ValueSet](https://www.hl7.org/fhir/R4/valueset-relatedperson-relationshiptype.html)
- [Nictiz SNOMED CT](https://nictiz.nl/standaarden/overzicht-van-standaarden/snomed-ct/)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)

#### Open vragen

1. **Nederlandse extensie**: Zijn er specifieke SNOMED CT codes in de Nederlandse extensie die beter passen bij de gedefinieerde rollen?
2. **UZI/BIG mapping**: Hoe wordt de vertaling van UZI/BIG codes naar SNOMED CT geïmplementeerd?
3. **Granulariteit**: Is de huidige set codes voldoende specifiek, of zijn meer gedetailleerde codes nodig voor bepaalde use cases?
