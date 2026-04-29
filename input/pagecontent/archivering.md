### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-03-24 | Initiële versie: uitgangspunten en oplossingsrichting |
| 0.0.2  | 2026-04-13 | Notificatiemechanisme via `meta.tag` lifecycle toegevoegd |
| 0.0.3  | 2026-04-13 | Drie niveaus van notificatie uitgewerkt; task lifecycle als overweging |
| 0.0.4  | 2026-04-13 | Dataclassificatie, toegankelijkheid archiefdata, rechten betrokkenen en contractbeëindiging toegevoegd |
| 0.0.5  | 2026-04-15 | PlantUML diagrammen toegevoegd (overzicht en tag lifecycle) |
| 0.0.6  | 2026-04-29 | Verifieerbare notificatie, beveiliging en beheersbaarheid toegevoegd; discussiepunt initiëring archivering |
| 0.0.7  | 2026-04-29 | Focus op meta.tag lifecycle als primaire oplossingsrichting; noodrem en AuditEvents uitgewerkt; interactiediagram toegevoegd |

---

### Archivering

Deze pagina beschrijft de uitgangspunten en oplossingsrichting voor het archiveren en verwijderen van patiëntdata binnen een Koppeltaal domein. De Koppeltaalvoorziening slaat patiëntgerelateerde FHIR resources op die na verloop van tijd gearchiveerd of verwijderd moeten worden, conform wettelijke bewaartermijnen (AVG, WGBO, NEN 7510, NEN 7513).

<div style="clear: both; margin: 1em 0;">
{% include archivering-overzicht.svg %}
</div>

### Uitgangspunten

#### Verwijderen gebeurt op patiëntniveau

FHIR resources zijn onderling referentieel verbonden (Patient, Task, RelatedPerson, CareTeam, etc.). Het individueel verwijderen van resources is vrijwel onmogelijk zonder integriteitsproblemen. Daarom vindt verwijdering altijd plaats op patiëntniveau: alle resources die aan een patiënt gerelateerd zijn, worden als geheel verwijderd.

**Belangrijk**: Practitioner resources vallen buiten de scope van patiëntverwijdering. Een Practitioner is niet patiënt-specifiek en kan betrokken zijn bij meerdere patiënten. RelatedPerson resources zijn daarentegen altijd gekoppeld aan één specifieke patiënt en vallen wel binnen de scope.

#### Logging en persoonsgegevens zijn gescheiden

AuditEvent resources (NEN 7513 audit trail) en persoonsgegevens (PII) hebben verschillende bewaartermijnen:

- **Persoonsgegevens (PII)**: maximaal 2 jaar
- **AuditEvents (logging)**: minimaal 5 jaar

AuditEvents zijn immutable en worden centraal verzameld. Om de verschillende bewaartermijnen te ondersteunen, mogen AuditEvents geen directe persoonsgegevens bevatten — alleen verwijzingen via technische identifiers. Na verwijdering van de patiëntdata zijn deze identifiers effectief geanonimiseerd binnen de Koppeltaalvoorziening.

#### Wie initieert verwijdering?

De Koppeltaalvoorziening is *verwerker* in de zin van de AVG en mag niet op eigen initiatief patiëntdata verwijderen. Het EPD (of bronsysteem) is de dossierhouder en heeft op grond van de [WGBO](https://wetten.overheid.nl/BWBR0005290) een wettelijke bewaartermijn van maximaal 20 jaar voor medische gegevens.

In het huidige model is het EPD verantwoordelijk voor:

1. Het verzamelen en veiligstellen van alle relevante gegevens uit de Koppeltaalvoorziening
2. Het verkrijgen van eventueel benodigd akkoord (bijv. van de behandelaar)
3. Het geven van de opdracht tot verwijdering aan de Koppeltaalvoorziening

**Discussiepunt**: er is een alternatief model in overweging waarbij de Koppeltaalvoorziening zelf automatisch archiveert na het verstrijken van de contractuele bewaartermijn (2 jaar), eventueel voorafgegaan door een notificatie- en grace period. In dit model verschuift de verantwoordelijkheid voor het *initiëren* van archivering naar de Koppeltaalvoorziening, terwijl het EPD verantwoordelijk blijft voor het tijdig veiligstellen van data. De keuze tussen beide modellen is nog in bespreking.

#### Startmoment bewaartermijn moet eenduidig zijn

Per datacategorie moet een eenduidig startmoment voor de bewaartermijn worden vastgesteld. Voorbeelden:

- Patiëntdata: laatste mutatie of laatste gebruik
- AuditEvents: datum van creatie
- Tasks: datum van afsluiting

#### Dataclassificatie en labeling

Alle data binnen de Koppeltaalvoorziening moet geclassificeerd worden op basis van type, gevoeligheid en bewaartermijn. FHIR security labels worden hiervoor ingezet als classificatiemechanisme. Dit maakt het mogelijk om:

- **Datacategorieën** te onderscheiden (persoonsgegevens, logging, transactiegegevens)
- **Bewaartermijnen** per categorie af te dwingen (2 jaar voor PII, 5 jaar voor logging)
- **Archiveringsstatus** vast te leggen op resource-niveau

Door classificatie bij creatie toe te passen, kan de Koppeltaalvoorziening bewaartermijnen geautomatiseerd afdwingen en is het op elk moment duidelijk onder welk regime een resource valt.

#### Verifieerbare notificatie

Wanneer doelapplicaties genotificeerd worden over aankomende verwijdering, moet aantoonbaar zijn dat notificaties succesvol zijn verzonden én ontvangen. De Koppeltaalvoorziening is verantwoordelijk voor het verzenden en het vastleggen van verzending en ontvangst — niet voor het daadwerkelijk ophalen of veiligstellen van data door zorginstellingen.

#### Beveiliging van archiefdata

Archiefdata moet beschermd zijn tegen ongeautoriseerde toegang, verlies en manipulatie, conform NEN 7510. Dit geldt zowel voor data in de actieve omgeving als voor data die als gearchiveerd is gemarkeerd.

#### Beheersbaarheid en configuratie

Bewaartermijnen en archiveringsregels moeten beheerd en aangepast kunnen worden binnen vastgestelde kaders, zodat flexibiliteit behouden blijft bij wijzigingen in wet- en regelgeving of contractuele afspraken.

### Oplossingsrichting

#### Archivering en verwijdering via meta.tag lifecycle

Het archiverings- en verwijderproces wordt gestuurd via FHIR `meta.tag` op de Patient resource, in combinatie met AuditEvents voor aantoonbaarheid. Dit mechanisme biedt een gecontroleerde, transparante en auditeerbare flow waarbij doelapplicaties de mogelijkheid hebben om het proces te volgen en indien nodig te blokkeren.

##### Tag lifecycle

De Patient resource doorloopt de volgende staten, vastgelegd in een dedicated CodeSystem:

| Code | Display | Beschrijving |
|------|---------|--------------|
| `ARCHIVE_PENDING` | Archive Pending | Patient is gemarkeerd voor archivering; grace period loopt |
| `ARCHIVE_HOLD` | Archive Hold | Noodrem — een doelapplicatie blokkeert het archiverings­proces |
| `ARCHIVED` | Archived | Patient is gearchiveerd; data is read-only en niet in reguliere zoekresultaten |
| `PURGE_PENDING` | Purge Pending | Patient is gemarkeerd voor definitieve verwijdering |
| `PURGED` | Purged | Patient is logisch verwijderd; hard delete volgt |

De lifecycle verloopt als volgt:

<div style="clear: both; margin: 1em 0;">
{% include archivering-tag-lifecycle.svg %}
</div>

##### AuditEvents bij statusovergangen

Elke statusovergang wordt vastgelegd in een immutable AuditEvent. Dit biedt een aantoonbare audit trail die de `$purge` overleeft:

| Moment | AuditEvent type | Actor | Doel |
|--------|-----------------|-------|------|
| Tag → `ARCHIVE_PENDING` | archive-initiated | Initiator | Aantoonbaar: archivering is gestart, grace period begint |
| Noodrem getrokken | archive-hold | Doelapplicatie | Aantoonbaar: welke applicatie blokkeert en waarom |
| Noodrem opgeheven | archive-hold-released | Doelapplicatie | Aantoonbaar: blokkade is opgeheven |
| Tag → `ARCHIVED` | archive-completed | Koppeltaalvoorziening | Aantoonbaar: archivering is voltooid |
| Tag → `PURGE_PENDING` | purge-initiated | Initiator | Aantoonbaar: verwijdering is geautoriseerd |
| `$purge` uitgevoerd | purge-completed | Koppeltaalvoorziening | Aantoonbaar: data is definitief vernietigd |

De combinatie van tags en AuditEvents scheidt **state** (huidige toestand van de Patient) van **events** (geschiedenis van wat er is gebeurd). Tags zijn muteerbaar en representeren de actuele status; AuditEvents zijn immutable en vormen het bewijs.

##### Interactie met doelapplicaties

Doelapplicaties detecteren archiveringsgerelateerde statusovergangen via FHIR Subscriptions op het `_tag` zoekcriterium:

```json
{
  "resourceType": "Subscription",
  "status": "active",
  "criteria": "Patient?_tag=ARCHIVE_PENDING",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://module.example.com/notifications/archive"
  }
}
```

Na ontvangst van de notificatie heeft de doelapplicatie gedurende de grace period de gelegenheid om:

- Relevante data op te halen en lokaal veilig te stellen
- Indien nodig de noodrem te trekken (zie hieronder)

Het model is **opt-out**: geen actie binnen de grace period betekent akkoord. De doelapplicatie hoeft niet expliciet te bevestigen dat data is veiliggesteld.

##### Noodrem (ARCHIVE_HOLD)

Een doelapplicatie die nog niet klaar is — bijvoorbeeld omdat data nog niet is veiliggesteld of er nog een actieve behandelrelatie bestaat — kan het archiveringsproces blokkeren door de tag `ARCHIVE_HOLD` toe te voegen aan de Patient resource:

- **Wie mag blokkeren**: elke doelapplicatie die data heeft van de betreffende patiënt
- **Hoe**: de doelapplicatie voegt `ARCHIVE_HOLD` toe aan `Patient.meta.tag`
- **Effect**: het archiveringsproces pauzeert zolang `ARCHIVE_HOLD` actief is; de overgang naar `ARCHIVED` wordt geblokkeerd
- **Vastlegging**: een AuditEvent (type `archive-hold`) wordt aangemaakt met de reden van de blokkade en de identiteit van de blokkerende applicatie
- **Opheffing**: de doelapplicatie verwijdert de `ARCHIVE_HOLD` tag wanneer de blokkade is opgelost; een AuditEvent (type `archive-hold-released`) wordt aangemaakt
- **Na opheffing**: de grace period herstart of het proces gaat direct verder (configureerbaar)

##### Interactiediagram

Het volgende diagram toont de volledige interactie tussen de initiator, de Koppeltaalvoorziening en doelapplicaties, inclusief de noodrem:

<div style="clear: both; margin: 1em 0;">
{% include archivering-interactie.svg %}
</div>

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

#### Toegankelijkheid van archiefdata

Gearchiveerde data moet raadpleegbaar blijven voor geautoriseerde gebruikers (zoals zorgaanbieders en beheerders). Hierbij gelden de volgende principes:

- Gearchiveerde data is **alleen-lezen**: wijzigingen zijn niet toegestaan na archivering
- De data blijft doorzoekbaar op relevante attributen
- Toegang is beperkt tot geautoriseerde rollen, in lijn met NEN 7510

Dit waarborgt zowel de operationele behoefte aan historische data als de integriteit van gearchiveerde gegevens.

#### Rechten van betrokkenen

De AVG (artikel 15) geeft betrokkenen het recht op inzage in hun persoonsgegevens. Dit recht geldt ook voor gearchiveerde data. De Koppeltaalvoorziening moet inzageverzoeken kunnen faciliteren zonder dat dit in conflict komt met bewaartermijnen — inzage is immers geen wijziging.

In de praktijk wordt een inzageverzoek via het EPD (als verwerkingsverantwoordelijke) afgehandeld. De Koppeltaalvoorziening dient de data technisch beschikbaar te stellen aan het EPD, ook wanneer deze gearchiveerd is.

#### Contractbeëindiging

Bij beëindiging van een verwerkersovereenkomst is de Koppeltaalvoorziening verplicht om persoonsgegevens te verwijderen of te retourneren aan de verwerkingsverantwoordelijke (het EPD). Dit omvat:

- Het retourneren of exporteren van alle persoonsgegevens aan het EPD
- Het definitief verwijderen van de persoonsgegevens uit de Koppeltaalvoorziening
- Het aantoonbaar vastleggen van de verwijdering via AuditEvents

De `$purge` operatie kan hiervoor worden ingezet, waarbij de AuditEvents als bewijs van verwijdering dienen.

### Overwegingen

Naast de gekozen oplossingsrichting (meta.tag lifecycle) zijn de volgende alternatieve benaderingen overwogen:

#### Geen notificatie

In de praktijk geldt dat wanneer een patiënt langere tijd inactief is geweest, er via Koppeltaal geen actieve interactie meer plaatsvindt. Het "verdwijnen" van de data is in dat geval geen functioneel probleem voor de doelapplicatie. De initiator kan in dit scenario direct de `$purge` uitvoeren zonder voorafgaande coördinatie.

Dit is het eenvoudigste model, maar biedt geen mogelijkheid voor doelapplicaties om data veilig te stellen of bezwaar te maken.

#### Two-phase commit via Tasks

Voor situaties waarin coördinatie met doelapplicaties vereist is — bijvoorbeeld wanneer een module nog niet-gearchiveerde data bevat die eerst naar het EPD moet worden overgedragen — kan een two-phase commit model worden ingezet.

De initiator maakt voor elke doelapplicatie die data heeft van de betreffende patiënt een Task aan met een opdracht om de lokale patiëntdata te verwijderen. De doelapplicatie kan vervolgens:

- De Task op `completed` zetten als de data succesvol is verwijderd
- De Task op `failed` zetten met een reden als de data nog niet verwijderd kan worden

Pas wanneer alle Tasks zijn afgerond, voert de initiator de definitieve `$purge` uit.

Dit model biedt maximale coördinatie maar introduceert complexiteit in de vorm van Task-management en -monitoring.

#### Task lifecycle als indicator

Wanneer alle taken van een patiënt de status `completed` hebben, kan men beargumenteren dat alle due diligence is uitgevoerd: de behandelmodules zijn afgerond, de resultaten zijn teruggekoppeld, en er zijn geen openstaande interacties meer. In dat geval kan de initiator er in bepaalde situaties voor kiezen om direct tot verwijdering over te gaan zonder voorafgaande notificatie.

### Referenties

- [FHIR Patient $purge operatie](https://build.fhir.org/patient-operation-purge.html)
- [FHIR Security Labels](https://www.hl7.org/fhir/security-labels.html)
- [NEN 7510 - Informatiebeveiliging in de zorg](https://www.nen.nl/nen-7510-1-2017-nl-245399)
- [NEN 7513 - Logging](https://www.nen.nl/nen-7513-2018-nl-247904)
- [AVG - Algemene verordening gegevensbescherming](https://eur-lex.europa.eu/eli/reg/2016/679/oj)
- [WGBO - Wet op de geneeskundige behandelingsovereenkomst](https://wetten.overheid.nl/BWBR0005290)
