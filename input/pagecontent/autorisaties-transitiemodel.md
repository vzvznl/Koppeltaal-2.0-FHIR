### Changelog

| Datum      | Wijziging       |
|------------|-----------------|
| 2025-12-15 | Initiële versie |

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

Het transitiemodel beschrijft hoe beide autorisatiemodellen worden samengevoegd tot een uniform model.

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
- Modellen worden beproefd en geëvalueerd

##### Transitiefase

In de transitiefase wordt het geharmoniseerde model gefaseerd ingevoerd:

**Model vaststelling:**
- Het autorisatiemodel wordt vastgesteld door de **visiegroep** (leveranciers en zorgaanbieders) en de **tech community** (leveranciers)
- Input wordt geleverd aan het standaardisatieteam

**Model status: INFORMATIEF**
- Het model is overeengekomen maar van **informatieve** aard
- Het model wordt nog niet afgedwongen
- Leveranciers kunnen ervoor kiezen het model te implementeren

**Technische wijzigingen:**
- `NOOP` wordt een **echt access token** dat gebruikersautorisatie representeert
- SMART on FHIR backend services blijven beschikbaar voor leveranciers die (nog) niet met het nieuwe model willen, kunnen of mogen werken
- Bestaande leveranciers kunnen migreren naar het nieuwe model om vooruit te lopen op de toekomst
- Nieuwe leveranciers krijgen het advies om direct met SMART on FHIR app launch te starten

##### Eindfase

In de eindfase is het uniforme autorisatiemodel volledig van kracht:

**Uniform autorisatiemodel:**
- Eén geharmoniseerd model voor zowel Koppeltaal als KoppelMij
- Volledige persoonsgebonden autorisatie

**Technische wijzigingen:**
- SMART on FHIR backend services zijn **niet meer beschikbaar**
- Alle autorisatie verloopt via SMART on FHIR app launch met echte access tokens

> **Let op:** De snelheid waarmee deze eindfase wordt bereikt is afhankelijk van de voortgang in de transitiefase en kan op dit moment niet worden vastgesteld.

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
- [CareTeam en Autorisaties](autorisaties-careteam.html)
- [Patient autorisaties](autorisaties-patient.html)
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)
