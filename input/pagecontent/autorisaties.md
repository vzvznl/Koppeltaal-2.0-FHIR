### Changelog

| Datum      | Wijziging                                                |
|------------|----------------------------------------------------------|
| 2026-01-08 | Sectie toegevoegd: huidig autorisatiemodel Koppeltaal (applicatieniveau, gebruikersniveau, launch nadelen) |
| 2026-01-08 | Sectie toegevoegd: granulariteit van autorisatie (CRUDS, security labels als toekomstige optie) |

---

Deze sectie beschrijft de autorisatieregels voor het geharmoniseerde KoppelMij/Koppeltaal model zoals uitgewerkt in [Optie 3](https://koppelmij.github.io/koppelmij-designs/koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

### Huidig autorisatiemodel Koppeltaal

Het huidige Koppeltaal autorisatiemodel is **gelaagd** opgebouwd en werkt op twee niveaus:

#### 1. Applicatieniveau (Koppeltaal)

In Koppeltaal worden **applicaties** geautoriseerd, niet individuele personen. Dit is een bewuste keuze:

- Applicaties hebben reeds een eigen toegangsmodel voor hun gebruikers
- Het toevoegen van persoonsautorisatie op Koppeltaal-niveau zou onnodige complexiteit introduceren
- Applicatie-instanties krijgen rechten via [SMART Backend Services](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27123707/TOP-KT-005a+-+Rollen+en+rechten+voor+applicatie-instanties)

Zie ook: [TOP-KT-008 - Beveiliging aspecten / Vertrouwensmodel](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/139493890/TOP-KT-008+-+Beveiliging+aspecten+Vertrouwensmodel+van+Koppeltaal)

#### 2. Gebruikersniveau (Applicatie)

De **verantwoordelijkheid voor gebruikersautorisatie** ligt bij de individuele applicaties:

- EPD's, platformen en modules zijn zelf verantwoordelijk voor de autorisatie van hun gebruikers
- Koppeltaal neemt het autorisatiemodel van de applicatie als uitgangspunt
- Wat een gebruiker mag doen en inzien wordt bepaald door de applicatie, niet door de Koppeltaal autorisatieservice

#### De launch als uitzondering

Een uitzondering op dit model is de **launch**. Bij een launch (via SMART on FHIR App Launch + HTI) geeft de lancerende applicatie (bijv. een portaal) informatie mee over:
- De gebruiker (Patient, Practitioner of RelatedPerson)
- Beperkte context over de relatie (bijv. voor welke patiënt de launch is)

De ontvangende module applicatie **moet deze informatie als waar beschouwen**. Dit heeft nadelen:

- **Snapshot-karakter**: De launch geeft een momentopname van relaties en rollen
- **Geen synchronisatie**: Wijzigingen kunnen zonder nieuwe launch niet worden uitgewisseld
- **Verdwijnende relaties**: Vooral problematisch wanneer relaties eindigen
- **Toegang buiten launch**: In de praktijk geven module applicaties ook buiten de launch om toegang, waardoor verouderde informatie kan leiden tot onterechte toegang

Deze nadelen zijn vooral relevant voor RelatedPersons, waarbij relaties gevoelig zijn en over tijd wijzigen. Zie ook de [CareTeam en Autorisatie](autorisaties-careteam.html#careteam-en-autorisatie-de-relatie) sectie voor hoe het CareTeam als zorgcontext deze problematiek kan adresseren.

### Overzicht

> **Transitiemodel:** Het autorisatiemodel van Koppeltaal en KoppelMij wordt geharmoniseerd. Zie [Transitiemodel autorisatie](autorisaties-transitiemodel.html) voor het fasering en de impact op leveranciers.

Het autorisatiemodel definieert wie toegang heeft tot welke FHIR resources onder welke omstandigheden. Dit model is essentieel voor:
- Het waarborgen van privacy en security
- Het mogelijk maken van veilige samenwerking tussen zorgverleners
- Het geven van controle aan patiënten over hun eigen gegevens

### Autorisatie contexten

Er worden drie hoofdcontexten onderscheiden:

1. **Taak context**: Specifieke toegang tot resources gerelateerd aan een taak
2. **Patiënt/RelatedPerson context**: Persoonlijke toegang voor patiënten en hun vertegenwoordigers
3. **Behandelaar context**: Professionele toegang voor zorgverleners

### Gebruikersrollen

Het model kent drie hoofdrollen met elk hun eigen autorisatieregels:

#### [Patient](authorization-patient.html)
Patiënten hebben toegang tot hun eigen gegevens en kunnen:
- Eigen taken beheren
- Zelfhulp modules starten
- Hun zorgteam inzien

#### [Practitioner](authorization-practitioner.html)
Behandelaars hebben verschillende autorisatieniveaus:
- **Zonder CareTeam rol**: Toegang via taken
- **Behandelaar in CareTeam**: Volledige toegang tot teampatïenten
- **Zorgondersteuner**: Read-only toegang met taakbeheer
- **Case Manager**: Organisatie-brede toegang

#### [RelatedPerson](authorization-relatedperson.html)
Mantelzorgers en vertegenwoordigers met verschillende typen:
- **Gemachtigd**: Volledige toegang namens patiënt
- **Samenwerker**: Beperkte toegang als teamlid
- **Monitor**: Alleen leesrechten

### Belangrijke overwegingen

> ⚠️ **CareTeam gebruik in de praktijk**
>
> Het autorisatiemodel maakt intensief gebruik van CareTeam structuren, terwijl in de huidige Koppeltaal praktijk geen gebruik wordt gemaakt van CareTeam. Dit vraagt om:
> - Nadere uitwerking van CareTeam-gebaseerde autorisatie als alternatief voor het huidige Task-gebaseerde model
> - Een transitiepad voor bestaande implementaties
> - Besluitvorming over minimale structuren voor veilige autorisatie

#### Granulariteit van autorisatie

Het voorgestelde autorisatiemodel werkt op **resource type niveau** met CRUDS-rechten:
- **C**reate - aanmaken van resources
- **R**ead - lezen van resources
- **U**pdate - wijzigen van resources
- **D**elete - verwijderen van resources
- **S**earch - zoeken naar resources (FHIR-specifiek)

**Scope en beperking:**

De huidige scope beperkt zich tot autorisatie op resource type niveau. Dit betekent dat een rol toegang krijgt tot alle resources van een bepaald type (bijv. alle Tasks, alle DocumentReferences), of geen toegang.

In de praktijk kan het wenselijk zijn om autorisatie op **individueel resource niveau** te kunnen specificeren. Voorbeelden:
- Een specifieke DocumentReference met gevoelige informatie die niet voor alle CareTeam-leden zichtbaar mag zijn
- Een Task voor een naaste (bijv. een docent) die niet zichtbaar mag zijn voor de patiënt zelf

**Toekomstige mogelijkheid: Security Labels**

FHIR biedt hiervoor [Security Labels](https://build.fhir.org/valueset-security-labels.html) waarmee het mogelijk is om op resource niveau toegangsbeperkingen aan te geven. Met security labels kan per resource worden gespecificeerd welke vertrouwelijkheidsniveau van toepassing is.

> **Huidige status:** Resource-niveau autorisatie via security labels valt buiten de huidige scope. Leveranciers hebben aangegeven dit vooralsnog niet te implementeren. Deze overweging is hier beschreven om de scope van het autorisatiemodel te verduidelijken en richting te geven aan toekomstige uitbreidingen.

