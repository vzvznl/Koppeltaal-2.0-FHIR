# TOP-KT-027 - Zorgteams

| Versie | Datum       | Status  | Wijzigingen    |
|--------|-------------|---------|----------------|
| 0.1.0  | 23 Feb 2026 | Concept | Eerste concept |

## Beschrijving

Het CareTeam representeert de **zorgcontext** binnen Koppeltaal: welke personen (Practitioners en RelatedPersons) betrokken zijn bij de zorg voor een patiënt, en in welke rol. Het CareTeam is **niet** het autorisatiemodel zelf, maar beschrijft de context die als startpunt dient voor autorisatie.

Het gebruik van CareTeam is **optioneel**. Dit is een systeembrede keuze die a-priori wordt gemaakt door de partijen in een domein. Wie de resource niet gebruikt, wordt niet geraakt. Dit is geen optionele uitbreiding in de zin van [Topic 25](TOP-KT-025-optionele-uitbreiding-van-de-koppeltaal-standaard.md) (dat is modulegebonden via UseContext/ActivityDefinition), maar een domeinbrede keuze.

## Overwegingen

### Waarom een zorgteam?

In het zorgproces is het essentieel om vast te leggen wie betrokken is bij de zorg voor een patiënt. Het CareTeam biedt hiervoor een gestandaardiseerde FHIR-resource die:

- Vastlegt welke Practitioners en RelatedPersons betrokken zijn bij de zorg voor een specifieke patiënt
- De rollen van deze betrokkenen expliciet maakt (behandelaar, zorgondersteuner, mantelzorger, etc.)
- Als basis dient voor een toekomstig autorisatiemodel dat rechten koppelt aan rollen
- Interoperabiliteit bevordert: andere partijen in het domein kunnen zien wie betrokken is

### CareTeam is niet het autorisatiemodel

Het onderscheid tussen zorgcontext en autorisatie is bewust gemaakt om de complexiteit te scheiden:

- **CareTeam** = zorgcontext (wie is betrokken, in welke rol)
- **Autorisatiematrix** = rechten per rol (wat mag iemand doen)
- **FHIR Resources** = de resources waartoe toegang wordt verleend

Het CareTeam is één van de entiteiten betrokken in het autorisatiemodel, maar niet de enige. Door het CareTeam te scheiden van de autorisatiematrix kunnen beide onafhankelijk van elkaar evolueren.

### Optionaliteit: systeembrede keuze

CareTeam is optioneel; partijen die het niet gebruiken worden niet geraakt. Dit is niet te verwarren met [Topic 25](TOP-KT-025-optionele-uitbreiding-van-de-koppeltaal-standaard.md) (optionele uitbreidingen per module):

- Topic 25 regelt **modulegebonden** optionaliteit via `UseContext` op `ActivityDefinition`
- CareTeam is een **systeembrede** keuze die a-priori en domeinbreed wordt gemaakt
- Het heeft geen zin om op ActivityDefinition-niveau vast te leggen of CareTeam gebruikt wordt, omdat dit niet per digitale interventie verschilt maar een domeinbrede afspraak is

Zonder CareTeam valt men terug op het huidige model: relaties tussen betrokkenen en patiënt worden enkel impliciet gelegd via de Task — in `Task.owner`, `Task.for` (patiënt) en `Task.requester` (Practitioner). Het CareTeam maakt deze relaties expliciet en voegt daar rollen aan toe.

### Types CareTeams

Er zijn drie denkbare typen CareTeams: organisatie-CareTeams (zonder patiënt), patiënt-specifieke CareTeams en Task-level CareTeams (gebonden aan een specifieke taak).

Task-level CareTeams zijn overwogen maar niet gekozen vanwege:

- **Synchronisatie-overhead:** Bij wijzigingen in de samenstelling van een zorgteam moeten alle Task-level CareTeams van alle lopende taken worden geüpdatet
- **Inconsistentierisico:** Verhoogde kans op fouten waarbij sommige Task CareTeams niet correct gesynchroniseerd worden
- **Operationele complexiteit:** Aanzienlijke overhead bij frequente teamwijzigingen

### Rollen: waarom een transitiemodel?

De rollen in het CareTeam resulteren in rechten, maar het technisch afdwingen hiervan vraagt een volwassen autorisatiemodel dat nog in ontwikkeling is. Daarom is gekozen voor een transitiemodel: de rollen worden vastgelegd en zijn als afspraak tussen partijen leidend, maar worden (nog) niet technisch afgedwongen door de FHIR Resource Service.

Er is gekozen voor SNOMED CT codes (gereviewd door Nictiz) in plaats van een eigen CodeSystem, omdat standaard terminologie interoperabiliteit bevordert en een eigen CodeSystem onnodige complexiteit introduceert.

### Task betrokkenen en CareTeam

De `Task.owner` moet lid zijn van het CareTeam, maar de `Task.requester` niet (tenzij deze de taak ook wil starten). De onderbouwing: de requester is degene die de taak aanmaakt (bijv. een administratieve medewerker of zorgondersteuner), maar hoeft niet per se deel te nemen aan de uitvoering. De owner is degene die de taak daadwerkelijk uitvoert en moet daarom als betrokkene in de zorgcontext staan.

### Fijnmazige autorisatie

Voor situaties waar meer granulaire autorisatie nodig is, zijn sub-tasks en SMART on FHIR launches overwogen als alternatief voor Task-level CareTeams. Deze aanpak is eenvoudiger en vereist minder synchronisatie:

- **Sub-tasks:** Fijnmazige toegang via FHIR-native toewijzingen aan individuele personen, zonder extra CareTeam-overhead
- **SMART on FHIR launches:** Launch-time autorisatiebeslissingen via HTI tokens, waarbij CareTeam-lidmaatschap en rol als basis dienen

## Toepassing en restricties

### Type CareTeam

Koppeltaal gebruikt **patiënt-specifieke CareTeams** als standaard. Dit zijn CareTeams gekoppeld aan een specifieke patiënt via `CareTeam.subject`, die alle betrokken Practitioners en RelatedPersons voor deze patiënt bevatten.

Meerdere CareTeams per patiënt zijn mogelijk, bijvoorbeeld bij parallelle behandeltrajecten of verschillende zorgprogramma's. Een deelnemer kan in meerdere CareTeams voorkomen met verschillende rollen. Het is aan de applicatie om te bepalen hoe met deze ambiguïteit wordt omgegaan.

Fijnmazige autorisatie wordt bereikt via sub-tasks en SMART on FHIR launches, niet via Task-level CareTeams.

### Transitiemodel

De rollen in het CareTeam bepalen de rechten, maar worden vooralsnog **niet technisch afgedwongen** door de FHIR Resource Service. De rollen zijn een afspraak tussen partijen. Dit transitiemodel betekent dat:

- Partijen onderling afspraken maken over welke rechten bij welke rol horen
- De autorisatiematrix de verwachte rechten per rol beschrijft
- Technische handhaving in een latere fase wordt ingevoerd

### Rollen

De rollen zijn gecodeerd met SNOMED CT codes (gereviewd door Nictiz). De rollen zijn in ontwikkeling en kunnen wijzigen.

**Practitioner rollen:**

| SNOMED CT code | Display | Koppeltaal rol |
|----------------|---------|----------------|
| `405623001` | Assigned practitioner | Behandelaar |
| `224608005` | Administrative healthcare staff | Zorgondersteuner |
| `768821004` | Care team coordinator | Case Manager |

**RelatedPerson rollen:**

| SNOMED CT code | Display | Koppeltaal rol |
|----------------|---------|----------------|
| `407542009` | Informal carer | Mantelzorger |
| `310391000146105` | Legal representative | Wettelijk vertegenwoordiger |
| `125677006` | Relative | Naaste |
| `62071000` | Buddy | Buddy |

> **Let op:** Deze rollen en de bijbehorende autorisatiemodellen worden in de toekomst verder uitgewerkt en verfijnd op basis van praktijkervaring en feedback van leveranciers.

### Task betrokkenen

- `Task.owner` **moet** lid zijn van minimaal één CareTeam voor de betreffende patiënt (dit kan een Practitioner, RelatedPerson of CareTeam zijn)
- `Task.requester` hoeft **niet** lid te zijn van een CareTeam voor de betreffende patiënt. Alleen wanneer de requester de taak ook daadwerkelijk wil starten, moet deze lid zijn van minimaal één CareTeam
- De patiënt waarvoor de Task is (`Task.for`) moet de patiënt zijn waarvoor het CareTeam is opgezet

### FHIR profiel en terminologie

Het CareTeam wordt gerepresenteerd als een FHIR R4 CareTeam resource, geprofileerd als `KT2_CareTeam` (gebaseerd op het nl-core CareTeam profiel).

| Aspect | Waarde |
|--------|--------|
| **Profiel** | [KT2_CareTeam](https://simplifier.net/koppeltaalv2.0) (`http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam`) |
| **CodeSystem** | `http://snomed.info/sct` (SNOMED CT) |
| **ValueSet Practitioner** | `koppeltaal-practitioner-role` (`http://vzvz.nl/fhir/ValueSet/koppeltaal-practitioner-role`) |
| **ValueSet RelatedPerson** | `koppeltaal-relatedperson-role` (`http://vzvz.nl/fhir/ValueSet/koppeltaal-relatedperson-role`) |
| **Binding** | `extensible` op `CareTeam.participant.role` |

De Practitioner ValueSet bevat naast de SNOMED CT codes ook de ZorgverlenerRolCodelijst voor backwards compatibility.

## Eisen

[ZTM - Eisen (en aanbevelingen) voor zorgteams](ZTM)

## Voorbeelden

Een patiënt-specifiek CareTeam met een behandelaar en een naaste:

```json
{
  "resourceType": "CareTeam",
  "id": "example-careteam",
  "meta": {
    "profile": [
      "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
    ]
  },
  "identifier": [
    {
      "system": "http://example.org/careteam-ids",
      "value": "ct-jan-jansen-001"
    }
  ],
  "status": "active",
  "subject": {
    "reference": "Patient/jan-jansen",
    "display": "Jan Jansen"
  },
  "participant": [
    {
      "role": [
        {
          "coding": [
            {
              "system": "http://snomed.info/sct",
              "code": "405623001",
              "display": "Assigned practitioner"
            }
          ]
        }
      ],
      "member": {
        "reference": "Practitioner/dr-smit",
        "display": "Dr. Smit"
      }
    },
    {
      "role": [
        {
          "coding": [
            {
              "system": "http://snomed.info/sct",
              "code": "125677006",
              "display": "Relative"
            }
          ]
        }
      ],
      "member": {
        "reference": "RelatedPerson/partner-jan",
        "display": "Partner van Jan"
      }
    }
  ],
  "managingOrganization": {
    "reference": "Organization/example-org"
  }
}
```

## Links naar gerelateerde onderwerpen

| Topic | Beschrijving van relatie met dit onderwerp |
|-------|--------------------------------------------|
| [TOP-KT-005 - Toegangsbeheersing](TOP-KT-005-toegangsbeheersing.md) | CareTeam rollen vormen het startpunt voor het autorisatiemodel. De rechten per rol worden bepaald door de autorisatiematrix. |
| [TOP-KT-009 - Overzicht gebruikte FHIR Resources](TOP-KT-009-overzicht-gebruikte-fhir-resources.md) | Het CareTeam is opgenomen als FHIR resource in het Koppeltaal datamodel. |
| [TOP-KT-013 - Levenscyclus van een FHIR Resource](TOP-KT-013-levenscyclus-van-een-fhir-resource.md) | De levenscyclus van het CareTeam (aanmaken, wijzigen, inactiveren) volgt de algemene FHIR resource levenscyclus. |
| [TOP-KT-025 - Optionele uitbreidingen](TOP-KT-025-optionele-uitbreiding-van-de-koppeltaal-standaard.md) | CareTeam valt **niet** onder het mechanisme van Topic 25. CareTeam is een systeembrede keuze, niet een per-ActivityDefinition uitbreiding via UseContext. |
| [TOP-KT-026 - Rol van de naaste](TOP-KT-026-uitbreiding-rol-van-de-naaste.md) | RelatedPersons (naasten) nemen deel aan het CareTeam met een specifieke rol die hun autorisaties bepaalt. |
