### Changelog

| Datum      | Wijziging                                                                 |
|------------|---------------------------------------------------------------------------|
| 2026-01-16 | Initiële versie: Care Services Directory als alternatief voor Organisatie CareTeams |

---

Deze pagina beschrijft hoe de **Care Services Directory** kan worden gebruikt als alternatief voor [Organisatie CareTeams](autorisaties-careteam.html#1-organisatie-careteams) voor organisatie-brede autorisatie binnen Koppeltaal.

De Care Services Directory is onderdeel van de [Generieke Functies](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/branches/user-authn/care-services.html), een landelijk initiatief voor het standaardiseren van zorgdiensten en adresgegevens. Door aan te sluiten bij deze standaard wordt interoperabiliteit met andere zorgsystemen mogelijk en wordt voorgesorteerd op toekomstige landelijke ontwikkelingen rondom het delen van organisatie- en medewerkersgegevens.

### Care Services Directory en Autorisatie: de relatie

De Care Services Directory is een mechanisme voor het publiceren van het **adresboek** van een organisatie: welke medewerkers er zijn, welke rollen zij vervullen, en binnen welke afdelingen of locaties zij werkzaam zijn. Dit concept is functioneel equivalent aan het publiceren van een Organisatie CareTeam, maar maakt gebruik van de standaard FHIR resources voor zorgdiensten.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CARE SERVICES DIRECTORY                              │
│                                                                         │
│  ┌─────────────────┐                                                    │
│  │  Organization   │  De zorgorganisatie                                │
│  │                 │  • Naam, adres, contactgegevens                    │
│  │                 │  • Afdelingen (partOf)                             │
│  │                 │  • Endpoints                                       │
│  └────────┬────────┘                                                    │
│           │                                                             │
│           ▼                                                             │
│  ┌─────────────────┐                                                    │
│  │ Healthcare-     │  Zorgdienst aangeboden door organisatie:           │
│  │ Service         │  • Type dienst (specialty)                         │
│  │                 │  • Locatie(s) waar dienst wordt aangeboden         │
│  │                 │  • Endpoints voor deze dienst                      │
│  └────────┬────────┘                                                    │
│           │                                                             │
│           ▼                                                             │
│  ┌─────────────────┐                                                    │
│  │ PractitionerRole│  Rol van medewerker in organisatie:                │
│  │                 │  • Koppeling Practitioner ↔ Organization           │
│  │                 │  • Rol/specialisme (code)                          │
│  │                 │  • Koppeling naar HealthcareService                │
│  └────────┬────────┘                                                    │
│           │                                                             │
│           ▼                                                             │
│  ┌─────────────────┐                                                    │
│  │ Autorisatie-    │  Bepaalt rechten op basis van:                     │
│  │ matrix          │  • Rol in PractitionerRole                         │
│  │                 │  • HealthcareService / specialty                   │
│  │                 │  • Afdeling/Organization                           │
│  └────────┬────────┘                                                    │
│           │                                                             │
│           ▼                                                             │
│  ┌─────────────────┐                                                    │
│  │ FHIR Resources  │  Toegang tot resources zoals:                      │
│  │                 │  • Patient, Task, CareTeam                         │
│  │                 │  • ActivityDefinition, etc.                        │
│  └─────────────────┘                                                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Samengevat:**
- **Organization** = de zorgorganisatie en haar afdelingen
- **HealthcareService** = de zorgdiensten die de organisatie aanbiedt
- **PractitionerRole** = de rol van een medewerker binnen de organisatie, gekoppeld aan een HealthcareService
- **Autorisatiematrix** = rechten per rol/dienst (wat mag iemand doen)
- **FHIR Resources** = de resources waartoe toegang wordt verleend

### HealthcareService als centraal ijkpunt

De HealthcareService is het centrale ijkpunt in de Care Services Directory structuur. Dit resource beschrijft welke zorgdiensten een organisatie aanbiedt en vormt de verbinding tussen organisatie, locatie, medewerkers en endpoints.

**Relaties vanuit HealthcareService:**
- `providedBy` → Organization (0..1, aanbevolen verplicht)
- `location` → Location (0..*)
- `endpoint` → Endpoint (0..*)
- PractitionerRole → HealthcareService (inbound, via `healthcareService`)

**FHIR voorbeeld - HealthcareService (gebaseerd op [GFA voorbeelden](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/branches/user-authn/care-services.html)):**
```json
{
  "resourceType": "HealthcareService",
  "id": "depressie-behandeling",
  "active": true,
  "providedBy": {
    "reference": "Organization/afdeling-depressie"
  },
  "name": "Behandeling Depressie",
  "type": [{
    "coding": [{
      "system": "http://snomed.info/sct",
      "code": "11429006",
      "display": "Consultation"
    }]
  }],
  "specialty": [{
    "coding": [{
      "system": "urn:oid:2.16.840.1.113883.2.4.6.7",
      "code": "0329",
      "display": "Medisch specialisten, psychiatrie"
    }]
  }],
  "location": [{
    "reference": "Location/locatie-hoofdgebouw"
  }]
}
```

**Voordelen van HealthcareService als ijkpunt:**
1. **Eenduidige routing:** Door endpoints direct aan de HealthcareService te koppelen, wordt het opzoeken van het juiste endpoint triviaal
2. **Flexibele locaties:** Een HealthcareService kan op meerdere locaties worden aangeboden
3. **Koppeling met medewerkers:** PractitionerRole resources kunnen via `healthcareService` aan specifieke diensten worden gekoppeld

### Vergelijking met Organisatie CareTeams

| Aspect | Organisatie CareTeam | Care Services Directory |
|--------|---------------------|------------------------|
| **Primaire resource** | CareTeam | HealthcareService + PractitionerRole + Organization |
| **Scope** | Specifiek voor Koppeltaal | Standaard FHIR, breder toepasbaar |
| **Structuur** | Platte lijst van participants | Hiërarchische organisatiestructuur |
| **Roldefinitie** | `CareTeam.participant.role` | `PractitionerRole.code` |
| **Zorgdiensten** | Niet expliciet gemodelleerd | Via `HealthcareService` |
| **Afdelingen** | Via meerdere CareTeams | Via `Organization.partOf` |
| **Locaties** | Niet expliciet gemodelleerd | Via `Location` gekoppeld aan HealthcareService |
| **Interoperabiliteit** | Koppeltaal-specifiek | Compatibel met [GFA](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/branches/user-authn/care-services.html) |

**Organisatie CareTeam voorbeeld:**
```
CareTeam voor Afdeling Depressie
├── Patient: (niet gezet)
├── Participants:
│   ├── Practitioner: Dr. Smit (rol: behandelaar)
│   ├── Practitioner: Dr. Jansen (rol: behandelaar)
│   └── Practitioner: Zorgondersteuner Klaas (rol: zorgondersteuner)
```

**Care Services Directory equivalent:**

De Care Services Directory modelleert dezelfde informatie via Organization, HealthcareService, PractitionerRole en Practitioner resources:

```
GGZ Instelling (Organization)
│
├── Afdeling Depressie (Organization, partOf: GGZ Instelling)
│   │
│   └── Behandeling Depressie (HealthcareService, providedBy: Afdeling Depressie)
│       ├── specialty: Psychiatrie
│       └── location: Hoofdgebouw
│
├── Dr. Smit (Practitioner)
│   └── PractitionerRole: GZ-psycholoog
│       ├── organization: Afdeling Depressie
│       └── healthcareService: Behandeling Depressie
│
├── Dr. Jansen (Practitioner)
│   └── PractitionerRole: GZ-psycholoog
│       ├── organization: Afdeling Depressie
│       └── healthcareService: Behandeling Depressie
│
└── Klaas (Practitioner)
    └── PractitionerRole: Verpleegkundige
        ├── organization: Afdeling Depressie
        └── healthcareService: Behandeling Depressie
```

**FHIR resources (gebaseerd op [GFA voorbeelden](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/branches/user-authn/care-services.html)):**

*Organization - Hoofdorganisatie:*
```json
{
  "resourceType": "Organization",
  "id": "ggz-instelling",
  "identifier": [{
    "system": "http://fhir.nl/fhir/NamingSystem/ura",
    "value": "12345678"
  }],
  "name": "GGZ Instelling",
  "type": [{
    "coding": [{
      "system": "http://nictiz.nl/fhir/NamingSystem/organization-type",
      "code": "G2",
      "display": "Instelling voor geestelijke gezondheidszorg"
    }]
  }]
}
```

*Organization - Afdeling (met partOf):*
```json
{
  "resourceType": "Organization",
  "id": "afdeling-depressie",
  "name": "Afdeling Depressie",
  "type": [{
    "coding": [{
      "system": "http://nictiz.nl/fhir/NamingSystem/organization-type",
      "code": "G2",
      "display": "Instelling voor geestelijke gezondheidszorg"
    }]
  }],
  "partOf": {
    "reference": "Organization/ggz-instelling"
  }
}
```

*Practitioner:*
```json
{
  "resourceType": "Practitioner",
  "id": "dr-smit",
  "identifier": [{
    "system": "http://fhir.nl/fhir/NamingSystem/uzi",
    "value": "UZI-12345"
  }],
  "name": [{
    "use": "official",
    "family": "Smit",
    "given": ["Jan"],
    "prefix": ["Dr."]
  }]
}
```

*PractitionerRole - koppeling medewerker aan organisatie met rol:*
```json
{
  "resourceType": "PractitionerRole",
  "id": "dr-smit-depressie",
  "practitioner": {
    "reference": "Practitioner/dr-smit"
  },
  "organization": {
    "reference": "Organization/afdeling-depressie"
  },
  "code": [{
    "coding": [{
      "system": "urn:oid:2.16.840.1.113883.2.4.15.111",
      "code": "01.062",
      "display": "GZ-psycholoog"
    }]
  }],
  "specialty": [{
    "coding": [{
      "system": "urn:oid:2.16.840.1.113883.2.4.6.7",
      "code": "0329",
      "display": "Medisch specialisten, psychiatrie"
    }]
  }],
  "telecom": [{
    "system": "email",
    "value": "j.smit@ggz-instelling.nl"
  }]
}
```

### PractitionerRole als startpunt voor autorisatie

Net als bij het CareTeam vormt de **rol** van de medewerker het startpunt voor autorisatie. Het verschil is dat bij de Care Services Directory de rol wordt vastgelegd in `PractitionerRole.code` in plaats van `CareTeam.participant.role`.

#### Autorisatie-scenario 1: Rol-gebaseerd organisatie-breed

In dit scenario worden rechten toegekend op basis van de rol van de medewerker, ongeacht de specifieke afdeling.

**Voorbeeld regel:** *"Alle behandelaars mogen alle patiënten binnen de organisatie inzien"*

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ROL-GEBASEERDE AUTORISATIE                           │
│                                                                         │
│  Query: Geef alle patiënten voor gebruiker X                            │
│                                                                         │
│  1. Bepaal PractitionerRole(s) van gebruiker X                          │
│     └── PractitionerRole.practitioner = Practitioner/X                  │
│                                                                         │
│  2. Bepaal rol(len) uit PractitionerRole.code                           │
│     └── code = "behandelaar"                                            │
│                                                                         │
│  3. Raadpleeg autorisatiematrix voor rol "behandelaar"                  │
│     └── Patient: READ (alle patiënten binnen organisatie)               │
│                                                                         │
│  4. Retourneer alle Patient resources binnen de organisatie             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**FHIR voorbeeld - PractitionerRole met UZI-rolcode:**
```json
{
  "resourceType": "PractitionerRole",
  "id": "dr-smit-ggz",
  "practitioner": {
    "reference": "Practitioner/dr-smit"
  },
  "organization": {
    "reference": "Organization/ggz-instelling"
  },
  "code": [{
    "coding": [{
      "system": "urn:oid:2.16.840.1.113883.2.4.15.111",
      "code": "01.062",
      "display": "GZ-psycholoog"
    }]
  }],
  "specialty": [{
    "coding": [{
      "system": "urn:oid:2.16.840.1.113883.2.4.6.7",
      "code": "0329",
      "display": "Medisch specialisten, psychiatrie"
    }]
  }]
}
```

**Autorisatieregel:**
```
ALS PractitionerRole.code IN ["01.062" (GZ-psycholoog), "01.055" (Psychiater), ...]
EN PractitionerRole.organization = Organization/ggz-instelling (of child organization)
DAN toegang tot ALLE Patient resources binnen Organization/ggz-instelling
```

#### Autorisatie-scenario 2: Afdeling-gebaseerd

In dit scenario worden rechten toegekend op basis van de afdeling waar de medewerker werkzaam is.

**Voorbeeld regel:** *"Medewerkers van Afdeling Depressie hebben alleen toegang tot patiënten die bij die afdeling in behandeling zijn"*

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    AFDELING-GEBASEERDE AUTORISATIE                      │
│                                                                         │
│  Query: Geef alle patiënten voor gebruiker X                            │
│                                                                         │
│  1. Bepaal PractitionerRole(s) van gebruiker X                          │
│     └── PractitionerRole.practitioner = Practitioner/X                  │
│                                                                         │
│  2. Bepaal afdeling(en) uit PractitionerRole.organization               │
│     └── organization = Organization/afdeling-depressie                  │
│                                                                         │
│  3. Zoek patiënten gekoppeld aan deze afdeling                          │
│     └── Via CareTeam.managingOrganization of EpisodeOfCare              │
│                                                                         │
│  4. Retourneer alleen patiënten van Afdeling Depressie                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**FHIR voorbeeld - Afdeling als Organization (met partOf hiërarchie):**
```json
{
  "resourceType": "Organization",
  "id": "afdeling-depressie",
  "name": "Afdeling Depressie",
  "type": [{
    "coding": [{
      "system": "http://nictiz.nl/fhir/NamingSystem/organization-type",
      "code": "G2",
      "display": "Instelling voor geestelijke gezondheidszorg"
    }]
  }],
  "partOf": {
    "reference": "Organization/ggz-instelling"
  }
}
```

**FHIR voorbeeld - PractitionerRole met afdeling en UZI-rolcode:**
```json
{
  "resourceType": "PractitionerRole",
  "id": "dr-smit-depressie",
  "practitioner": {
    "reference": "Practitioner/dr-smit"
  },
  "organization": {
    "reference": "Organization/afdeling-depressie"
  },
  "code": [{
    "coding": [{
      "system": "urn:oid:2.16.840.1.113883.2.4.15.111",
      "code": "01.062",
      "display": "GZ-psycholoog"
    }]
  }],
  "specialty": [{
    "coding": [{
      "system": "urn:oid:2.16.840.1.113883.2.4.6.7",
      "code": "0329",
      "display": "Medisch specialisten, psychiatrie"
    }]
  }],
  "telecom": [{
    "system": "email",
    "value": "j.smit@ggz-instelling.nl"
  }]
}
```

**Autorisatieregel:**
```
ALS PractitionerRole.organization = Organization/afdeling-depressie
DAN toegang tot Patient resources
  WAAR Patient is gekoppeld aan Organization/afdeling-depressie
  (via CareTeam.managingOrganization of EpisodeOfCare.managingOrganization)
```

### Combinatie van scenario's

In de praktijk kunnen beide scenario's worden gecombineerd:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    GECOMBINEERDE AUTORISATIE                            │
│                                                                         │
│  Voorbeeld autorisatieregels:                                           │
│                                                                         │
│  1. Behandelaars (rol-gebaseerd):                                       │
│     └── Toegang tot alle patiënten binnen hun afdeling                  │
│                                                                         │
│  2. Hoofdbehandelaars (rol + organisatie-breed):                        │
│     └── Toegang tot alle patiënten binnen de gehele organisatie         │
│                                                                         │
│  3. Zorgondersteuners (rol + afdeling-gebaseerd):                       │
│     └── Alleen toegang tot patiënten waarvoor een Task bestaat          │
│         binnen hun afdeling                                             │
│                                                                         │
│  4. Administratie (rol-gebaseerd):                                      │
│     └── Alleen demografische gegevens, geen klinische data              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Verantwoordelijkheid van de zorgorganisatie

Bij het gebruik van de Care Services Directory ligt de verantwoordelijkheid voor het correct vullen en bijhouden van het adresboek bij de **zorgorganisatie (het domein)** zelf. Dit omvat:

1. **Organisatiestructuur:** Het publiceren van de organisatie en haar afdelingen via `Organization` resources met correcte `partOf` relaties
2. **Zorgdiensten:** Het definiëren van de aangeboden zorgdiensten via `HealthcareService` resources met de juiste specialismen en locaties
3. **Medewerkers:** Het registreren van medewerkers als `Practitioner` resources
4. **Rollen:** Het koppelen van medewerkers aan de organisatie en zorgdiensten via `PractitionerRole` resources met de correcte UZI-rolcodes

Deze informatie vormt de basis voor autorisatiebeslissingen binnen het Koppeltaal domein. Een correct gevulde Care Services Directory zorgt ervoor dat:
- Medewerkers de juiste toegangsrechten krijgen op basis van hun rol
- Zorgdiensten vindbaar zijn voor andere partijen
- Endpoints correct kunnen worden gerouteerd

> **Let op:** De kwaliteit van de autorisatiebeslissingen is direct afhankelijk van de kwaliteit van de data in de Care Services Directory. Het is daarom essentieel dat de zorgorganisatie deze informatie actueel houdt.

### Voordelen van Care Services Directory

1. **Standaard FHIR:** Maakt gebruik van standaard FHIR resources (Organization, HealthcareService, PractitionerRole) zonder Koppeltaal-specifieke extensies

2. **Hiërarchische structuur:** Organisaties en afdelingen kunnen via `Organization.partOf` in een hiërarchie worden gemodelleerd

3. **Interoperabiliteit:** Compatibel met andere initiatieven zoals [Generic Function Addressing (GFA)](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/branches/user-authn/care-services.html)

4. **Schaalbaarheid:** Geschikt voor grote organisaties met veel medewerkers en afdelingen

5. **Meerdere rollen:** Een Practitioner kan meerdere PractitionerRole resources hebben voor verschillende rollen/afdelingen

### Implementatie overwegingen

#### Wanneer Care Services Directory gebruiken?

- **Organisatie-brede autorisatie:** Wanneer rechten worden bepaald door de rol binnen de organisatie, niet door betrokkenheid bij een specifieke patiënt
- **Grote organisaties:** Wanneer het niet praktisch is om alle medewerkers in Organisatie CareTeams te beheren
- **Interoperabiliteit:** Wanneer integratie met andere systemen via standaard FHIR gewenst is

#### Wanneer (Patiënt-specifieke) CareTeams gebruiken?

- **Patiënt-specifieke autorisatie:** Wanneer rechten worden bepaald door directe betrokkenheid bij een specifieke patiënt
- **Dynamische teams:** Wanneer de samenstelling van zorgteams per patiënt verschilt
- **Fijnmazige controle:** Wanneer per patiënt moet worden bepaald wie toegang heeft

#### Combinatie van beide benaderingen

In de praktijk kunnen beide benaderingen worden gecombineerd:

```
Care Services Directory (organisatie-niveau):
├── Bepaalt: Wie mag in principe patiënten zien (rol-gebaseerd)
└── Voorbeeld: Alle behandelaars van GGZ Instelling

Patiënt-specifieke CareTeams (patiënt-niveau):
├── Bepaalt: Wie is daadwerkelijk betrokken bij deze specifieke patiënt
└── Voorbeeld: Dr. Smit en Zorgondersteuner Klaas voor Jan Jansen
```

### Zie ook

- [Autorisaties overzicht](autorisaties.html)
- [CareTeam autorisaties](autorisaties-careteam.html)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [Generic Function Addressing (GFA) - Care Services](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/branches/user-authn/care-services.html)
