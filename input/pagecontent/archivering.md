### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.0.1 | 2026-03-24 | Initiële versie: uitgangspunten en oplossingsrichting |
| 0.0.2 | 2026-04-13 | Notificatiemechanisme via `meta.tag` lifecycle toegevoegd |
| 0.0.3 | 2026-04-13 | Drie niveaus van notificatie uitgewerkt; task lifecycle als overweging |
| 0.0.4 | 2026-04-13 | Dataclassificatie, toegankelijkheid archiefdata, rechten betrokkenen en contractbeëindiging toegevoegd |
| 0.0.5 | 2026-04-15 | PlantUML diagrammen toegevoegd (overzicht en tag lifecycle) |
| 0.0.6 | 2026-04-29 | Verifieerbare notificatie, beveiliging en beheersbaarheid toegevoegd; discussiepunt initiëring archivering |
| 0.0.7 | 2026-04-29 | Focus op meta.tag lifecycle als primaire oplossingsrichting; noodrem en AuditEvents uitgewerkt; interactiediagram toegevoegd |
| 0.0.8 | 2026-05-04 | KT-dienst als initiator vastgelegd; laatste activiteit als startmoment; recht om vergeten te worden als aparte UC; datum in tags |
| 0.0.9 | 2026-05-05 | Technische onderbouwing meta.tags vs. soft delete toegevoegd |
| 0.0.10 | 2026-05-11 | Statusmodel vereenvoudigd: `ARCHIVE_*` / `PURGE_*` vervangen door `DELETE_PENDING` / `DELETE_HOLD` / `DELETED`; activiteitscheck vóór `DELETED` toegevoegd; concept "archiefdata" en security labels-mechanisme verwijderd; rechten van betrokkenen herschreven |
| 0.0.11 | 2026-05-12 | Startmoment bewaartermijn geabstraheerd naar "laatste betrokkenheid" (User Authentication AuditEvent als kandidaat onder discussie); diagrammen: hernieuwde betrokkenheid laat de bewaartermijn herstarten |
| 0.0.12 | 2026-05-12 | Tag-lifecycle-diagram: HTTP-status na `$purge` gecorrigeerd van 410 Gone naar 404 Not Found (geen tombstone bij hard delete) |
| 0.0.13 | 2026-05-13 | DELETED geschrapt als tag (kan na `$purge` niet meer bestaan); Actief en DELETED expliciet als conceptuele eindstaten benoemd; `Patient.meta.tag = DELETED`-stap uit overzicht- en interactiediagram verwijderd ([#58](https://github.com/vzvznl/Koppeltaal-2.0-FHIR/issues/58)) |
| 0.0.14 | 2026-05-19 | Naamgeving van de conceptuele eindstaat "Deleted" geüniformeerd: in tekst en tag-lifecycle-diagram niet langer in caps (`DELETED`) of met code-styling, maar als gewoon woord parallel aan "Actief" — `DELETE_PENDING` en `DELETE_HOLD` blijven als echte tag-waarden wél in caps |

---

### Archivering

Deze pagina beschrijft de uitgangspunten en oplossingsrichting voor het verwijderen van patiëntdata binnen een Koppeltaal domein. De Koppeltaalvoorziening slaat patiëntgerelateerde FHIR resources op die na verloop van tijd verwijderd moeten worden, conform wettelijke bewaartermijnen (AVG, WGBO, NEN 7510, NEN 7513).

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

#### De Koppeltaalvoorziening initieert verwijdering

De Koppeltaalvoorziening initieert het verwijderproces. Wanneer de bewaartermijn van 2 jaar — gerekend vanaf de laatste activiteit — is verstreken, start de Koppeltaalvoorziening automatisch de verwijderprocedure (zie meta.tag lifecycle). Het ECD (als dossierhouder) en doelapplicaties worden hierover genotificeerd en hebben de mogelijkheid om data veilig te stellen of het proces te blokkeren via de noodrem.

Het ECD heeft op grond van de [WGBO](https://wetten.overheid.nl/BWBR0005290) een eigen wettelijke bewaartermijn van maximaal 20 jaar voor medische gegevens en is verantwoordelijk voor het tijdig veiligstellen van relevante data uit de Koppeltaalvoorziening.

#### Startmoment bewaartermijn moet eenduidig zijn

Per datacategorie moet een eenduidig startmoment voor de bewaartermijn worden vastgesteld. Voor persoonsgegevens geldt de **laatste betrokkenheid van de patiënt** als startmoment — het moment waarop de patiënt voor het laatst aantoonbaar actief was binnen het Koppeltaal-domein.

Welk signaal in de Koppeltaalvoorziening die laatste betrokkenheid het beste vertegenwoordigt, is nog onderwerp van discussie. Een kansrijke kandidaat is het User Authentication AuditEvent (zie [TOP-KT-011 - Logging en tracing](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27125090)), omdat dit het enige AuditEvent is waarbij `entity.what` direct naar de gebruiker (Patient of RelatedPerson) verwijst. Aandachtspunt is dat niet elke applicatie momenteel via een User Authentication-event inlogt; voor die gevallen moet een aanvullend of vervangend signaal worden afgesproken (bijvoorbeeld via de standalone SMART on FHIR launch — zie [memo-standalone-smart-launch.html](./memo-standalone-smart-launch.html)).

Voorbeelden per datacategorie:

- Patiëntdata: datum van de laatste aantoonbare betrokkenheid van de patiënt
- AuditEvents: datum van creatie
- Tasks: datum van afsluiting

#### Dataclassificatie en labeling

Alle data binnen de Koppeltaalvoorziening moet geclassificeerd worden op basis van type, gevoeligheid en bewaartermijn. FHIR security labels worden hiervoor ingezet als classificatiemechanisme. Dit maakt het mogelijk om:

- **Datacategorieën** te onderscheiden (persoonsgegevens, logging, transactiegegevens)
- **Bewaartermijnen** per categorie af te dwingen (2 jaar voor PII, 5 jaar voor logging)
- **Verwijderstatus** vast te leggen op resource-niveau

Door classificatie bij creatie toe te passen, kan de Koppeltaalvoorziening bewaartermijnen geautomatiseerd afdwingen en is het op elk moment duidelijk onder welk regime een resource valt.

#### Verifieerbare notificatie

Wanneer doelapplicaties genotificeerd worden over aankomende verwijdering, moet aantoonbaar zijn dat notificaties succesvol zijn verzonden én ontvangen. De Koppeltaalvoorziening is verantwoordelijk voor het verzenden en het vastleggen van verzending en ontvangst — niet voor het daadwerkelijk ophalen of veiligstellen van data door zorginstellingen.

#### Beheersbaarheid en configuratie

Bewaartermijnen en verwijderregels moeten beheerd en aangepast kunnen worden binnen vastgestelde kaders, zodat flexibiliteit behouden blijft bij wijzigingen in wet- en regelgeving of contractuele afspraken.

### Oplossingsrichting

#### Verwijdering via meta.tag lifecycle

Het verwijderproces wordt gestuurd via FHIR `meta.tag` op de Patient resource, in combinatie met AuditEvents voor aantoonbaarheid. Dit mechanisme biedt een gecontroleerde, transparante en auditeerbare flow waarbij doelapplicaties de mogelijkheid hebben om het proces te volgen en indien nodig te blokkeren.

##### Tag lifecycle

De Patient resource doorloopt een aantal staten. **Actief** en **Deleted** zijn conceptuele eindstaten en worden niet door een tag op de Patient resource gerepresenteerd: een actieve resource bestaat zonder verwijdertag, een Deleted-resource bestaat helemaal niet meer (HTTP GET levert 404 Not Found). De tussenliggende staten worden wél via `meta.tag` vastgelegd, in een dedicated CodeSystem:

| Code | Display | Beschrijving |
| --- | --- | --- |
| `DELETE_PENDING` | Delete Pending | Patient is gemarkeerd voor verwijdering; grace period loopt |
| `DELETE_HOLD` | Delete Hold | Noodrem — een doelapplicatie blokkeert het verwijder­proces |

De lifecycle verloopt als volgt:

<div style="clear: both; margin: 1em 0;">
{% include archivering-tag-lifecycle.svg %}
</div>

##### AuditEvents bij statusovergangen

Elke statusovergang wordt vastgelegd in een immutable AuditEvent. Dit biedt een aantoonbare audit trail die de `$purge` overleeft:

| Moment | AuditEvent type | Actor | Doel |
| --- | --- | --- | --- |
| Tag → `DELETE_PENDING` | delete-initiated | Koppeltaalvoorziening | Aantoonbaar: verwijdering is gestart, grace period begint |
| Noodrem getrokken | delete-hold | Doelapplicatie | Aantoonbaar: welke applicatie blokkeert en waarom |
| Noodrem opgeheven | delete-hold-released | Doelapplicatie | Aantoonbaar: blokkade is opgeheven |
| Hernieuwde betrokkenheid gedetecteerd | delete-aborted | Koppeltaalvoorziening | Aantoonbaar: verwijdering afgebroken vanwege hernieuwde patiëntbetrokkenheid |
| `$purge` uitgevoerd | delete-completed | Koppeltaalvoorziening | Aantoonbaar: data is definitief vernietigd; Patient bestaat niet meer |

De combinatie van tags en AuditEvents scheidt **state** (huidige toestand van de Patient) van **events** (geschiedenis van wat er is gebeurd). Tags zijn muteerbaar en representeren de actuele status; AuditEvents zijn immutable en vormen het bewijs.

##### Datum in tags

Bij het zetten van een tag wordt een **datum** opgenomen die aangeeft wanneer de tag is gezet en — bij `DELETE_PENDING` — wanneer de grace period afloopt. Dit maakt het voor doelapplicaties mogelijk om te bepalen hoeveel tijd er resteert, en voor de Koppeltaalvoorziening om de overgang naar de volgende status te automatiseren. De datum wordt vastgelegd als onderdeel van de tag (bijv. via de `extension` op `meta.tag` of via een aparte `meta.tag` met een datumcodering).

##### Interactie met doelapplicaties

Doelapplicaties detecteren verwijdergerelateerde statusovergangen via FHIR Subscriptions op het `_tag` zoekcriterium:

```json
{
  "resourceType": "Subscription",
  "status": "active",
  "criteria": "Patient?_tag=DELETE_PENDING",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://module.example.com/notifications/delete"
  }
}
```

Na ontvangst van de notificatie heeft de doelapplicatie gedurende de grace period de gelegenheid om:

- Relevante data op te halen en lokaal veilig te stellen
- Indien nodig de noodrem te trekken (zie hieronder)

Het model is **opt-out**: geen actie binnen de grace period betekent akkoord. De doelapplicatie hoeft niet expliciet te bevestigen dat data is veiliggesteld.

##### Noodrem (`DELETE_HOLD`)

Een doelapplicatie die nog niet klaar is — bijvoorbeeld omdat data nog niet is veiliggesteld of er nog een actieve behandelrelatie bestaat — kan het verwijderproces blokkeren door de tag `DELETE_HOLD` toe te voegen aan de Patient resource:

- **Wie mag blokkeren**: elke doelapplicatie die data heeft van de betreffende patiënt
- **Hoe**: de doelapplicatie voegt `DELETE_HOLD` toe aan `Patient.meta.tag`
- **Effect**: het verwijderproces pauzeert zolang `DELETE_HOLD` actief is; de overgang naar Deleted wordt geblokkeerd
- **Vastlegging**: een AuditEvent (type `delete-hold`) wordt aangemaakt met de reden van de blokkade en de identiteit van de blokkerende applicatie
- **Opheffing**: de doelapplicatie verwijdert de `DELETE_HOLD` tag wanneer de blokkade is opgelost; een AuditEvent (type `delete-hold-released`) wordt aangemaakt
- **Na opheffing**: de grace period herstart of het proces gaat direct verder (configureerbaar)

##### Activiteitscheck vóór Deleted

Voordat de Koppeltaalvoorziening de overgang van `DELETE_PENDING` naar Deleted uitvoert, controleert zij of er sinds het zetten van `DELETE_PENDING` opnieuw aantoonbare betrokkenheid van de patiënt (of een aan deze patiënt gekoppelde RelatedPerson) is geregistreerd, op basis van het afgesproken signaal voor "laatste betrokkenheid" (zie [Startmoment bewaartermijn](#startmoment-bewaartermijn-moet-eenduidig-zijn)). Indien dit het geval is, wordt de patiënt opnieuw als actief beschouwd en wordt de verwijdering afgebroken:

- De `DELETE_PENDING` tag wordt verwijderd
- Een AuditEvent (type `delete-aborted`) wordt aangemaakt met als reden "hernieuwde betrokkenheid" en een verwijzing naar het bepalende activiteitssignaal
- De bewaartermijn van 2 jaar begint opnieuw vanaf de datum van de nieuwe betrokkenheid

Deze controle voorkomt dat data wordt verwijderd van patiënten die tijdens of vlak na de grace period weer actief worden — bijvoorbeeld doordat zij na een lange inactieve periode opnieuw inloggen via een doelapplicatie. De controle wordt op het moment van de geplande `$purge` uitgevoerd, zodat ook betrokkenheid aan het einde van de grace period wordt meegenomen.

##### Interactiediagram

Het volgende diagram toont de volledige interactie tussen de initiator, de Koppeltaalvoorziening en doelapplicaties, inclusief de noodrem:

<div style="clear: both; margin: 1em 0;">
{% include archivering-interactie.svg %}
</div>

#### Definitieve verwijdering: `$purge`

De overgang naar Deleted wordt technisch uitgevoerd via de FHIR [`$purge` operatie](https://build.fhir.org/patient-operation-purge.html). De `$purge` maakt gebruik van het [FHIR Patient Compartment](https://www.hl7.org/fhir/compartmentdefinition-patient.html) om te bepalen welke resources aan een patiënt gerelateerd zijn. Met de parameter `cascade=true` worden alle resources binnen het Patient Compartment in één operatie verwijderd, inclusief de Patient resource zelf.

De scope van de `$purge` omvat onder andere:

- Patient
- Task
- RelatedPerson
- CareTeam

AuditEvent resources overleven de `$purge` — zij bevatten geen persoonsgegevens en vallen onder een langere bewaartermijn.

#### Waarom meta.tags en niet FHIR soft delete?

Een alternatieve benadering zou zijn om de FHIR soft delete (HTTP DELETE met bewaren van een tombstone) te gebruiken als verwijdersignaal, gevolgd door een definitieve `$purge`. Deze benadering is onderzocht en afgewezen om de volgende redenen:

- **Geen revert bij cascading delete**: bij een cascading soft delete in HAPI FHIR krijgt elke resource een eigen tombstone. Ongedaan maken (noodrem) vereist dat de blokkerende applicatie per resource een VREAD doet op de voorlaatste versie en deze opnieuw PUT — niet werkbaar
- **Geen notificaties bij DELETE**: FHIR R4 stuurt standaard geen Subscription-notificaties bij een DELETE request, waardoor doelapplicaties de verwijdering niet detecteren
- **Onbekende ondersteuning**: het is niet vastgesteld of cascading soft delete wordt ondersteund door alle FHIR-serverimplementaties (bijv. InterSystems)

De `meta.tag` benadering is expliciet over de lifecycle en de staat van de resource, werkt met standaard FHIR Subscriptions, en is niet afhankelijk van serverspecifieke DELETE-functionaliteit. Dit maakt het de meest robuuste en draagbare oplossing.

#### Rechten van betrokkenen

De AVG (artikel 15) geeft betrokkenen het recht op inzage in hun persoonsgegevens. Zolang patiëntdata in de Koppeltaalvoorziening aanwezig is — dus vóór de overgang naar Deleted — moet de Koppeltaalvoorziening inzageverzoeken kunnen faciliteren zonder dat dit in conflict komt met bewaartermijnen. Inzage is immers geen wijziging en herstart de bewaartermijn niet.

In de praktijk wordt een inzageverzoek via het EPD (als verwerkingsverantwoordelijke) afgehandeld. De Koppeltaalvoorziening dient de data technisch beschikbaar te stellen aan het EPD. Na Deleted resteren binnen de Koppeltaalvoorziening alleen AuditEvents; de inhoudelijke persoonsgegevens zijn dan via het ECD/EPD te raadplegen op grond van de daar geldende bewaartermijn.

Het **recht om vergeten te worden** (AVG artikel 17) is een aparte use case die losstaat van de reguliere verwijderprocedure. Een verzoek tot verwijdering kan op elk moment worden ingediend en vereist een eigen procedure, inclusief toetsing aan uitzonderingsgronden (bijv. WGBO-bewaartermijn). De uitwerking hiervan valt buiten de scope van deze pagina.

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

Voor situaties waarin coördinatie met doelapplicaties vereist is — bijvoorbeeld wanneer een module nog niet-overgedragen data bevat die eerst naar het EPD moet worden gestuurd — kan een two-phase commit model worden ingezet.

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
