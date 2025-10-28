# Autorisaties in KoppelMij/Koppeltaal

Deze sectie beschrijft de autorisatieregels voor het geharmoniseerde KoppelMij/Koppeltaal model zoals uitgewerkt in [Optie 3](koppeltaal_domeinen.html#optie-3-harmonisatie-van-autorisatie-authenticatie-en-standaarden) van de Koppeltaal Domeinen documentatie.

## Overzicht

Het autorisatiemodel definieert wie toegang heeft tot welke FHIR resources onder welke omstandigheden. Dit model is essentieel voor:
- Het waarborgen van privacy en security
- Het mogelijk maken van veilige samenwerking tussen zorgverleners
- Het geven van controle aan patiënten over hun eigen gegevens

## Autorisatie contexten

Er worden drie hoofdcontexten onderscheiden:

1. **Taak context**: Specifieke toegang tot resources gerelateerd aan een taak
2. **Patiënt/RelatedPerson context**: Persoonlijke toegang voor patiënten en hun vertegenwoordigers
3. **Behandelaar context**: Professionele toegang voor zorgverleners

## Gebruikersrollen

Het model kent drie hoofdrollen met elk hun eigen autorisatieregels:

### [Patient](authorization-patient.html)
Patiënten hebben toegang tot hun eigen gegevens en kunnen:
- Eigen taken beheren
- Zelfhulp modules starten
- Hun zorgteam inzien

### [Practitioner](authorization-practitioner.html)
Behandelaars hebben verschillende autorisatieniveaus:
- **Zonder CareTeam rol**: Toegang via taken
- **Behandelaar in CareTeam**: Volledige toegang tot teampatïenten
- **Zorgondersteuner**: Read-only toegang met taakbeheer
- **Case Manager**: Organisatie-brede toegang

### [RelatedPerson](authorization-relatedperson.html)
Mantelzorgers en vertegenwoordigers met verschillende typen:
- **Gemachtigd**: Volledige toegang namens patiënt
- **Samenwerker**: Beperkte toegang als teamlid
- **Monitor**: Alleen leesrechten

## Belangrijke overwegingen

> ⚠️ **CareTeam gebruik in de praktijk**
>
> Het autorisatiemodel maakt intensief gebruik van CareTeam structuren, terwijl in de huidige Koppeltaal praktijk bijna geen gebruik wordt gemaakt van CareTeam. Dit vraagt om:
> - Nadere uitwerking van task-gebaseerde autorisatie als alternatief
> - Een transitiepad voor bestaande implementaties
> - Besluitvorming over minimale structuren voor veilige autorisatie

## Launch types en autorisaties

De autorisatieregels gelden voor alle launch types:
- Directe portaal toegang
- Task-specifieke launches
- Cross-context launches (bijv. behandelaar start module voor patiënt)

De specifieke context bepaalt welke resources toegankelijk zijn, maar de autorisatieregels blijven consistent.