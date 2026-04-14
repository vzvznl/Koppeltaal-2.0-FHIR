### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-03-24 | Initiële versie: uitgangspunten en oplossingsrichting |
| 0.0.2  | 2026-04-13 | Notificatiemechanisme via `meta.tag` lifecycle toegevoegd |

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

##### Lifecycle via `meta.tag`

Om doelapplicaties gecontroleerd te informeren over archivering en verwijdering, wordt een lifecycle mechanisme op basis van FHIR `meta.tag` voorgesteld. In plaats van een directe hard delete doorloopt een resource een aantal expliciet gedefinieerde staten, vastgelegd in een dedicated CodeSystem:

| Code | Display | Beschrijving |
|------|---------|--------------|
| `ARCHIVE_PENDING` | Archive Pending | Resource is gemarkeerd voor archivering; wacht op bevestiging |
| `ARCHIVED` | Archived | Resource is gearchiveerd naar langetermijnopslag |
| `PURGE_PENDING` | Purge Pending | Resource is gemarkeerd voor definitieve verwijdering; wacht op autorisatie |
| `PURGED` | Purged | Resource is logisch verwijderd; hard delete volgt |

De lifecycle verloopt als volgt:

```
[Actieve Resource]
       │
       │ (retentiebeleid geactiveerd)
       ▼
[ARCHIVE_PENDING]
       │
       │ (archivering bevestigd)
       ▼
  [ARCHIVED]
       │
       │ (verwijdering geautoriseerd)
       ▼
[PURGE_PENDING]
       │
       │ (hard delete uitgevoerd)
       ▼
   [PURGED] → HTTP DELETE → 410 Gone
```

Elke statusovergang wordt uitgevoerd via een `PUT` of `PATCH` op de resource. Hierdoor wordt `meta.versionId` en `meta.lastUpdated` automatisch bijgewerkt, wat een ingebouwde audit trail oplevert via het `_history` endpoint.

##### Notificatie via Subscriptions

Doelapplicaties kunnen zich abonneren op specifieke statusovergangen via FHIR Subscriptions. Hiervoor wordt het `_tag` zoekcriterium gebruikt:

```json
{
  "resourceType": "Subscription",
  "status": "active",
  "criteria": "Patient?_tag=PURGE_PENDING",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://module.example.com/notifications/purge"
  }
}
```

Op deze manier ontvangt een doelapplicatie een notificatie wanneer een patiënt gemarkeerd is voor verwijdering. De applicatie kan dan:

1. Eventuele lokale kopieën van patiëntdata verwijderen
2. Lopende sessies of taken afsluiten
3. Bevestigen dat de verwijdering vanuit hun perspectief kan doorgaan

##### Verhouding tot `$purge` en security labels

Het `meta.tag` lifecycle mechanisme is complementair aan de eerder beschreven mechanismen:

- **Security labels** maken resources onzichtbaar in zoekresultaten (soft-delete)
- **`meta.tag` lifecycle** coördineert het archiveringsproces en informeert doelapplicaties
- **`$purge`** voert de definitieve verwijdering uit als laatste stap

De combinatie biedt een gecontroleerd, auditeerbaar en subscription-vriendelijk archiveringsproces zonder bespoke API's.

### Referenties

- [FHIR Patient $purge operatie](https://build.fhir.org/patient-operation-purge.html)
- [FHIR Security Labels](https://www.hl7.org/fhir/security-labels.html)
- [NEN 7510 - Informatiebeveiliging in de zorg](https://www.nen.nl/nen-7510-1-2017-nl-245399)
- [NEN 7513 - Logging](https://www.nen.nl/nen-7513-2018-nl-247904)
- [AVG - Algemene verordening gegevensbescherming](https://eur-lex.europa.eu/eli/reg/2016/679/oj)
