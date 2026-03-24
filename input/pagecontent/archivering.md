### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-03-24 | Initiële versie: uitgangspunten en oplossingsrichting |

---

### Archivering

Deze pagina beschrijft de uitgangspunten en oplossingsrichting voor het archiveren en verwijderen van patiëntdata binnen een Koppeltaal domein. De Koppeltaalvoorziening slaat patiëntgerelateerde FHIR resources op die na verloop van tijd gearchiveerd of verwijderd moeten worden, conform wettelijke bewaartermijnen (AVG, NEN 7510, NEN 7513).

### Uitgangspunten

#### Verwijderen gebeurt op patiëntniveau

FHIR resources zijn onderling referentieel verbonden (Patient, Task, RelatedPerson, CareTeam, etc.). Het individueel verwijderen van resources is vrijwel onmogelijk zonder integriteitsproblemen. Daarom vindt verwijdering altijd plaats op patiëntniveau: alle resources die aan een patiënt gerelateerd zijn, worden als geheel verwijderd.

**Belangrijk**: Practitioner resources vallen buiten de scope van patiëntverwijdering. Een Practitioner is niet patiënt-specifiek en kan betrokken zijn bij meerdere patiënten. RelatedPerson resources zijn daarentegen altijd gekoppeld aan één specifieke patiënt en vallen wel binnen de scope.

#### Logging en persoonsgegevens zijn gescheiden

AuditEvent resources (NEN 7513 audit trail) en persoonsgegevens (PII) hebben verschillende bewaartermijnen:

- **Persoonsgegevens (PII)**: maximaal 2 jaar
- **AuditEvents (logging)**: minimaal 5 jaar

AuditEvents zijn immutable en worden centraal verzameld. Om de verschillende bewaartermijnen te ondersteunen, mogen AuditEvents geen directe persoonsgegevens bevatten — alleen verwijzingen via technische identifiers. Na verwijdering van de patiëntdata zijn deze identifiers effectief geanonimiseerd binnen de Koppeltaalvoorziening.

#### Het EPD/de dossierhouder initieert verwijdering

De Koppeltaalvoorziening is *verwerker* in de zin van de AVG en mag niet op eigen initiatief patiëntdata verwijderen. Het EPD (of bronsysteem) is de dossierhouder en heeft een wettelijke bewaartermijn van maximaal 20 jaar voor medische gegevens.

Het EPD is verantwoordelijk voor:

1. Het verzamelen en veiligstellen van alle relevante gegevens uit de Koppeltaalvoorziening
2. Het verkrijgen van eventueel benodigd akkoord (bijv. van de behandelaar)
3. Het geven van de opdracht tot verwijdering aan de Koppeltaalvoorziening

#### Startmoment bewaartermijn moet eenduidig zijn

Per datacategorie moet een eenduidig startmoment voor de bewaartermijn worden vastgesteld. Voorbeelden:

- Patiëntdata: laatste mutatie of laatste gebruik
- AuditEvents: datum van creatie
- Tasks: datum van afsluiting

### Oplossingsrichting

#### Definitieve verwijdering: $purge

Voor het definitief verwijderen van alle patiëntdata wordt de FHIR [`$purge` operatie](https://build.fhir.org/patient-operation-purge.html) gehanteerd. Deze operatie verwijdert alle resources die aan een specifieke patiënt gerelateerd zijn.

De scope van de `$purge` omvat onder andere:

- Patient
- Task
- RelatedPerson
- CareTeam

AuditEvent resources overleven de `$purge` — zij bevatten geen persoonsgegevens en vallen onder een langere bewaartermijn.

#### Tussentijds archiveren: security labels

Voor situaties waarin resources tussentijds onzichtbaar moeten worden gemaakt zonder ze fysiek te verwijderen, kunnen FHIR security labels worden ingezet. Dit biedt een "soft-delete" mechanisme waarbij:

- Resources worden voorzien van een security label dat aangeeft dat ze gearchiveerd zijn
- De FHIR server filtert deze resources uit zoekresultaten
- De resources blijven technisch bestaan tot de definitieve `$purge`

Dit mechanisme is bijvoorbeeld toepasbaar op Tasks die "verjaard" zijn: de behandeling is afgerond en de gegevens hoeven niet meer zichtbaar te zijn voor gebruikers, maar het EPD heeft de definitieve verwijdering nog niet geïnitieerd.

**Opmerking**: Security labels als archiveringmechanisme zijn een methodiek die ingezet kan worden als de behoefte zich voordoet. Het is mogelijk dat in de praktijk de `$purge` als enige verwijdermechanisme volstaat.

### Overwegingen

#### Notificatie naar doelapplicaties

Bij verwijdering van patiëntdata kan de vraag ontstaan of doelapplicaties (modules, portalen) hierover geïnformeerd moeten worden. In de praktijk geldt dat wanneer een patiënt langere tijd inactief is geweest, er via Koppeltaal geen actieve interactie meer plaatsvindt. Het "verdwijnen" van de data is in dat geval geen functioneel probleem voor de doelapplicatie.

Een mogelijke uitbreiding is een pre-notificatie voorafgaand aan de `$purge`, met de opdracht aan doelapplicaties om eventuele lokale kopieën van de patiëntdata te verwijderen. Dit is echter geen harde eis en dient per domein te worden afgewogen.

### Referenties

- [FHIR Patient $purge operatie](https://build.fhir.org/patient-operation-purge.html)
- [FHIR Security Labels](https://www.hl7.org/fhir/security-labels.html)
- [NEN 7510 - Informatiebeveiliging in de zorg](https://www.nen.nl/nen-7510-1-2017-nl-245399)
- [NEN 7513 - Logging](https://www.nen.nl/nen-7513-2018-nl-247904)
- [AVG - Algemene verordening gegevensbescherming](https://eur-lex.europa.eu/eli/reg/2016/679/oj)
