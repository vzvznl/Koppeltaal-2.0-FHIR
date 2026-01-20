### Changelog

| Versie | Datum      | Wijziging                                      |
|--------|------------|------------------------------------------------|
| 0.0.1  | 2026-01-20 | Initiële versie: overzichtspagina Zorgcontext  |

---

### Zorgcontext

Deze sectie beschrijft hoe de **zorgcontext** wordt gemodelleerd binnen het KoppelMij/Koppeltaal geharmoniseerde model. De zorgcontext beschrijft wie betrokken is bij de zorg voor een patiënt en in welke rol.

### Overzicht

De zorgcontext vormt de basis voor het [autorisatiemodel](autorisaties.html). Op basis van de zorgcontext wordt bepaald welke personen toegang hebben tot welke FHIR resources.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ZORGCONTEXT                                     │
│                                                                         │
│  ┌─────────────────┐                                                    │
│  │    CareTeam     │                                                    │
│  ├─────────────────┤                           ┌─────────────────┐      │
│  │ Beschrijft wie  │                           │ Autorisatie-    │      │
│  │ betrokken is    │ ─────────────────────────►│ model           │      │
│  │ bij de zorg     │                           ├─────────────────┤      │
│  └─────────────────┘                           │ Bepaalt rechten │      │
│                                                │ op basis van    │      │
│  ┌─────────────────┐                           │ context en rol  │      │
│  │ Care Services   │                           │                 │      │
│  │ Directory       │ ─────────────────────────►│                 │      │
│  ├─────────────────┤                           └─────────────────┘      │
│  │ Beschrijft      │                                                    │
│  │ organisatie-    │                                                    │
│  │ structuur       │                                                    │
│  └─────────────────┘                                                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Componenten

De zorgcontext bestaat uit de volgende componenten:

#### [CareTeam](care-context-careteam.html)

Het CareTeam beschrijft de zorgcontext van een patiënt: welke Practitioners en RelatedPersons betrokken zijn en in welke rol. Er worden drie types onderscheiden:

1. **Organisatie CareTeams**: Teams zonder specifieke patiënt (afdeling/team)
2. **Patiënt-specifieke CareTeams**: Teams gekoppeld aan een specifieke patiënt
3. **Task level CareTeams**: Teams gebonden aan een specifieke taak

Zie ook: [CareTeam Q&A](care-context-careteam-q-n-a.html)

#### [Care Services Directory](care-context-care-service-directory.html)

De Care Services Directory is een alternatief voor Organisatie CareTeams en maakt gebruik van standaard FHIR resources:

- **Organization**: De zorgorganisatie en haar afdelingen
- **HealthcareService**: De zorgdiensten die de organisatie aanbiedt
- **PractitionerRole**: De rol van een medewerker binnen de organisatie

### Relatie met Autorisaties

De zorgcontext vormt het startpunt voor het autorisatiemodel. De rollen van betrokkenen in de zorgcontext bepalen welke rechten zij hebben:

- [Autorisaties overzicht](autorisaties.html)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)
- [Patient autorisaties](autorisaties-patient.html)
- [Rol Code Mapping](autorisaties-rol-code-mapping.html)

### Zie ook

- [Transitiemodel autorisatie](autorisaties-transitiemodel.html)
- [Koppeltaal Domeinen - Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden)
