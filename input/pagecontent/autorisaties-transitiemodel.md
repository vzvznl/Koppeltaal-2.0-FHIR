### Changelog

| Versie | Datum      | Wijziging                                                                          |
|--------|------------|------------------------------------------------------------------------------------|
| 0.0.4  | 2026-01-06 | Verduidelijking transitiefase: twee parallelle paden (legacy/nieuw) met coëxistentie |
| 0.0.3  | 2026-01-06 | Uitbreiding eindfase: uitfasering backend services en verplichte migratie          |
| 0.0.2  | 2025-12-16 | Verduidelijking: alleen Patient model beproefd bij KoppelMij                       |
| 0.0.1  | 2025-12-15 | Initiële versie                                                                    |

---

### Transitiemodel autorisatie

Deze pagina beschrijft het transitieproces van de autorisatiemodellen van Koppeltaal en KoppelMij naar een geharmoniseerd model, zoals beschreven in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

### Huidige situatie

#### Koppeltaal

Koppeltaal maakt gebruik van **application level autorisatie** via SMART on FHIR backend services:

- **Applicaties** krijgen toegang tot FHIR resources, niet individuele gebruikers
- De autorisatie van gebruikers binnen de applicatie wordt door de applicatie zelf afgehandeld
- Bij SMART on FHIR app launch wordt een `access_token` meegegeven, maar deze heeft momenteel de waarde `NOOP` (no operation)
- Dit is een bewuste afwijking: het token is verplicht volgens de specificatie, maar geeft geen daadwerkelijke toegang

#### KoppelMij

KoppelMij maakt gebruik van **user level autorisatie** via SMART on FHIR app launch:

- **Gebruikers** (personen) krijgen direct toegang tot FHIR resources
- Persoonsgebonden autorisatie: de identiteit en rechten van de gebruiker bepalen de toegang
- Het `access_token` representeert daadwerkelijk de autorisatie van de gebruiker

### Transitiemodel

Het transitiemodel beschrijft hoe beide autorisatiodellen worden samengevoegd tot een uniform model.

<div style="clear: both;">
<img src="transitiemodel-autorisatie.png" alt="Transitiemodel autorisatie Koppeltaal/KoppelMij" style="display: block; max-width: 100%; height: auto; margin: 1em 0;" />
</div>

#### Drie fasen

Het transitieproces bestaat uit drie fasen. Let op: de eindfase wordt mogelijk niet bereikt.

##### Ontwerpfase

In de ontwerpfase worden de autorisatiemodellen ontworpen en gevalideerd:

**Modellen vaststellen:**
- Patient model
- Practitioner model
- Related person model

**Koppeltaal:**
- Application level autorisatie (SMART on FHIR backend services) blijft van kracht
- `access_token` heeft waarde `NOOP`

**KoppelMij:**
- User level autorisatie (SMART on FHIR app launch) is actief
- Het Patient model wordt beproefd en geëvalueerd

##### Transitiefase

In de transitiefase wordt het geharmoniseerde model gefaseerd ingevoerd. Twee autorisatiemechanismen coëxisteren:

**Model vaststelling:**
- Het autorisatiemodel wordt vastgesteld door de **visiegroep** (leveranciers en zorgaanbieders) en de **tech community** (leveranciers)
- Input wordt geleverd aan het standaardisatieteam

**Twee parallelle paden:**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         TRANSITIEFASE                                   │
│                                                                         │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐    │
│  │  SMART on FHIR Backend      │     │  SMART on FHIR App Launch   │    │
│  │  Services (Legacy)          │     │  (Nieuw)                    │    │
│  ├─────────────────────────────┤     ├─────────────────────────────┤    │
│  │ • Application level         │     │ • User level autorisatie    │    │
│  │   autorisatie               │     │ • Echt access token         │    │
│  │ • Datamodel is INFORMATIEF  │     │ • Persoonsgebonden toegang  │    │
│  │ • Applicatie leidt zelf     │     │ • Autorisatie wordt         │    │
│  │   autorisaties af op basis  │     │   afgedwongen via token     │    │
│  │   van context (CareTeam,    │     │                             │    │
│  │   rollen, etc.)             │     │                             │    │
│  └─────────────────────────────┘     └─────────────────────────────┘    │
│                                                                         │
│  Beide paden zijn geldig - leveranciers kiezen zelf                     │
└─────────────────────────────────────────────────────────────────────────┘
```

**Pad 1: SMART on FHIR Backend Services (Legacy)**
- Application level autorisatie blijft beschikbaar
- Het datamodel (CareTeam, rollen) én het autorisatiemodel zijn **INFORMATIEF**
- Applicaties zijn zelf verantwoordelijk voor de implementatie van de autorisatie en kunnen ervoor kiezen om hiervan af te wijken
- De autorisaties zijn afspraken, maar worden niet door de FHIR dienst afgedwongen

**Pad 2: SMART on FHIR App Launch (Nieuw)**
- `NOOP` wordt een **echt access token** dat gebruikersautorisatie representeert
- User level autorisatie: het token representeert de rechten van de gebruiker
- Applicaties die dit token gebruiken, maken gebruik van het nieuwe geharmoniseerde model

**Coëxistentie en keuzevrijheid:**
- De keuze voor het autorisatiemechanisme bepaalt welk model van toepassing is
- Leveranciers kunnen vrij kiezen welk pad zij volgen
- Beide paden zijn gedurende de transitiefase volledig ondersteund

**Aanbeveling richting eindfase:**
- **Nieuwe leveranciers** worden aangemoedigd om direct met SMART on FHIR app launch te starten
- **Bestaande leveranciers** worden geadviseerd om te migreren naar app launch
- Hoewel de keuze vrij is, ligt het pad voorwaarts richting de eindfase waarin alleen app launch beschikbaar is

##### Eindfase

In de eindfase is het uniforme autorisatiemodel volledig van kracht:

**Uniform autorisatiemodel:**
- Eén geharmoniseerd model voor zowel Koppeltaal als KoppelMij
- Volledige persoonsgebonden autorisatie

**Uitfasering SMART on FHIR Backend Services:**

In de eindfase worden SMART on FHIR backend services **uitgezet**. Dit betekent:

- Application level autorisatie is niet meer mogelijk
- Applicaties kunnen niet langer zelfstandig autorisaties afleiden op basis van het datamodel
- Het legacy pad uit de transitiefase komt te vervallen

**Waarom deze uitfasering?**
- **Uniformiteit:** Eén autorisatiemodel voor het gehele ecosysteem vereenvoudigt beheer en compliance
- **Veiligheid:** Persoonsgebonden autorisatie via tokens biedt betere controle en audit-mogelijkheden
- **Standaardisatie:** Volledige alignment met SMART on FHIR standaarden

**Verplichte migratie:**
- Alle applicaties moeten vóór de eindfase gemigreerd zijn naar SMART on FHIR app launch
- Applicaties die nog gebruik maken van backend services zullen niet meer kunnen verbinden
- Het access token representeert de autorisatie van de gebruiker en wordt afgedwongen door het platform

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           EINDFASE                                      │
│                                                                         │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐    │
│  │  SMART on FHIR Backend      │     │  SMART on FHIR App Launch   │    │
│  │  Services                   │     │                             │    │
│  ├─────────────────────────────┤     ├─────────────────────────────┤    │
│  │                             │     │ • User level autorisatie    │    │
│  │      ❌ UITGEZET            │     │ • Echt access token         │    │
│  │                             │     │ • Persoonsgebonden toegang  │    │
│  │                             │     │ • ✅ VERPLICHT              │    │
│  └─────────────────────────────┘     └─────────────────────────────┘    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

> **Let op:** De snelheid waarmee deze eindfase wordt bereikt is afhankelijk van de voortgang in de transitiefase en kan op dit moment niet worden vastgesteld. Leveranciers worden tijdig geïnformeerd over de planning zodra deze bekend is.

### Wat betekent dit voor leveranciers?

#### Huidige situatie (Ontwerpfase)
- Geen actie vereist
- SMART on FHIR backend services blijven werken zoals voorheen
- U kunt het informatieve model alvast bestuderen

#### Transitiefase
- Het model is informatief; implementatie is optioneel
- U kunt ervoor kiezen om SMART on FHIR app launch te implementeren
- Backend services blijven beschikbaar

#### Eindfase (indien bereikt)
- SMART on FHIR app launch wordt verplicht
- Backend services verdwijnen
- Volledige migratie naar persoonsgebonden autorisatie

### Zie ook

- [Autorisaties overzicht](autorisaties.html)
- [CareTeam en Autorisaties](care-context-careteam.html)
- [Patient autorisaties](autorisaties-patient.html)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)
