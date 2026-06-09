### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.0.1 | 2026-06-08 | Initiële versie |

---

### Opschoning Patient-data

Deze pagina beschrijft de uitgangspunten en oplossingsrichting voor het verwijderen van patiëntdata binnen een Koppeltaal domein. De Koppeltaalvoorziening slaat patiëntgerelateerde FHIR resources op die na verloop van tijd verwijderd moeten worden, conform wettelijke bewaartermijnen (AVG, WGBO, NEN 7510, NEN 7513).


<div style="clear: both; margin: 1em 0;">
{% include opschoning-patient-data-overzicht.svg %}
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

De Koppeltaalvoorziening initieert het verwijderproces. Wanneer de bewaartermijn van 2 jaar — gerekend vanaf de laatste activiteit — is verstreken, start de Koppeltaalvoorziening automatisch de verwijderprocedure (zie [Oplossingsrichting](#oplossingsrichting)). Het ECD (als dossierhouder) en doelapplicaties worden hierover genotificeerd en hebben de mogelijkheid om data veilig te stellen of het proces te blokkeren via de noodrem.

Het ECD heeft op grond van de [WGBO](https://wetten.overheid.nl/BWBR0005290) een eigen wettelijke bewaartermijn van maximaal 20 jaar voor medische gegevens en is verantwoordelijk voor het tijdig veiligstellen van relevante data uit de Koppeltaalvoorziening.

#### Startmoment bewaartermijn moet eenduidig zijn

Per datacategorie moet een eenduidig startmoment voor de bewaartermijn worden vastgesteld. Voor persoonsgegevens geldt de **laatste betrokkenheid van de patiënt** als startmoment — het moment waarop de patiënt voor het laatst aantoonbaar actief was binnen het Koppeltaal-domein.

Dit moment wordt **niet als state opgeslagen** maar op het moment van de [activiteitscheck](#activiteitscheck-vóór-verwijdering) afgeleid uit drie bestaande bronnen, waarvan het maximum wordt genomen:

| Bron | Definitie | Status |
| --- | --- | --- |
| `T_authorize` | Meest recente `AuditEvent` voor de SMART `/authorize`-call van de Koppeltaal-launch, waar de actor de Patient is of een aan deze Patient gekoppelde RelatedPerson (`agent.who`) | Reeds gespecificeerd — type `DCM#110114` / subtype `DCM#110122` (zie `auditevent-launch-example.fsh`) |
| `T_introspect_hti` | Meest recente `AuditEvent` voor de `/introspect`-call **uitsluitend wanneer het geïntrospecteerde token een HTI launch token is**, met dezelfde actor-filtering | **In uitwerking** — voorstel: het bestaande User Authentication AuditEvent (`type DCM#110114`) met een eigen subtype (voorstel `DCM#110143`); te bevestigen in [TOP-KT-021](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27125106). Tot dit is vastgesteld blijft dit pad inactief |
| `T_task_owner` | Meest recente `Task.meta.lastUpdated` voor Tasks waar `Task.owner` direct naar de Patient verwijst | Beschikbaar in het huidige Task-profiel. **Niet** `Task.for` — Tasks die *over* de patiënt gaan tellen niet; alleen Tasks waarvan de patiënt de **uitvoerder** is. De aankondigings-Task (`KT2_DeletePendingTask`, `owner` = `Device`) valt hier per definitie buiten |

`last-patient-engagement = max(T_authorize, T_introspect_hti, T_task_owner)`.

Practitioner-activiteit telt niet mee: behandelaaractiviteit is administratief / zorginhoudelijk en valt onder de bewaartermijn van het EPD (WGBO, 20 jaar). De AVG-bewaartermijn van 2 jaar voor persoonsgegevens is gekoppeld aan betrokkenheid van de patiënt zelf. Door op de actor van het AuditEvent te filteren (`agent.who`) en op `Task.owner`, vallen Practitioner-acties automatisch buiten de berekening.

Activiteit van een aan de Patient gekoppelde RelatedPerson telt **in principe** wél mee — uitgewerkt in zowel de AuditEvent-actorfilter als de `Task.owner`-filter. Zie [overweging "RelatedPerson in de mix"](#relatedperson-in-de-mix) voor de motivatie en implementatie.

Voordelen van de querybenadering: geen state-onderhoud op `Patient.meta`, geen schrijfpaden bij zelf-inloggende applicaties, geen conflictresolutie en geen backfill-migratie. De afleiding gebruikt de resources die al de bron van waarheid zijn — AuditEvents voor activiteit (NEN 7513) en Tasks voor uitvoeringsbetrokkenheid. De controle vindt alleen plaats op het moment van `$purge`; drie tot vijf gerichte queries per kandidaat-Patient zijn acceptabel.

**Edge-case "nooit betrokken".** Is er voor een kandidaat-Patient na 2 jaar geen enkel relevant event (`max(...)` is leeg — bijvoorbeeld een Patient die wel is aangemaakt maar waarvoor nooit een Launch of Task heeft plaatsgevonden), dan start gewoon de reguliere purge-procedure.

#### Dataclassificatie en labeling

Alle data binnen de Koppeltaalvoorziening moet geclassificeerd worden op basis van type, gevoeligheid en bewaartermijn. FHIR security labels worden hiervoor ingezet als classificatiemechanisme. Dit maakt het mogelijk om:

- **Datacategorieën** te onderscheiden (persoonsgegevens, logging, transactiegegevens)
- **Bewaartermijnen** per categorie af te dwingen (2 jaar voor PII, 5 jaar voor logging)
- **Verwijderstatus** vast te leggen op resource-niveau

Door classificatie bij creatie toe te passen, kan de Koppeltaalvoorziening bewaartermijnen geautomatiseerd afdwingen en is het op elk moment duidelijk onder welk regime een resource valt.

#### Opt-in, notificatie en abonnement

De notificatie aan doelapplicaties bij aankomende verwijdering vervult twee rollen:

1. **Informatief**: zij meldt dat de Patient en gerelateerde data uit de Koppeltaalvoorziening gaan verdwijnen.
2. **Signaal tot eigen opschoning** (MAY): deelnemende systemen worden aangemoedigd om hun eigen, lokaal opgeslagen kopie ook op te ruimen, tenzij wettelijke of contractuele bewaarplichten een eigen, andere termijn voorschrijven. Doelapplicaties hanteren hun eigen bewaartermijnen en zijn zelf verantwoordelijk voor de juiste afhandeling.

**Opt-in.** Een doelapplicatie wordt alleen in het opschoningsproces meegenomen — en ontvangt dus alleen aankondigings-Tasks — wanneer zij zich daarvoor heeft aangemeld. Deze opt-in wordt beheerd via de admin console (domeinbeheer) en vastgelegd als property op het `Device`-resource van de applicatie. De Koppeltaalvoorziening leidt de set te notificeren doelapplicaties per Patient af uit deze opt-in.

**Abonnement.** Een opt-in doelapplicatie registreert een Subscription op haar aankondigings-Tasks:

```json
{
  "resourceType": "Subscription",
  "status": "active",
  "criteria": "Task?code=delete-pending&status=requested",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://module.example.com/notifications/delete"
  }
}
```

Het opschoningsproces wordt aangekondigd en gecoördineerd via een **Task** per doelapplicatie (`KT2_DeletePendingTask`), met **AuditEvents** voor de aantoonbaarheid en de definitieve verwijdering via de FHIR `$purge`-operatie.
Via `Task.owner` ziet elke applicatie uitsluitend haar eigen Tasks. Subscriben op AuditEvents is **voor pre-delete signalen geen geldig alternatief**: de Task is de werkbare, muteerbare drager van de aankondiging; de AuditEvent is bewijslog. Voor het **post-delete** signaal ligt dat anders — zie [AuditEvents bij statusovergangen](#auditevents-bij-statusovergangen): de Task valt in het Patient-compartiment en verdwijnt mee in de `$purge`, dus dat signaal landt op de `destroy`-AuditEvent.

**Verzending wordt gelogd; bevestigde ontvangst niet vereist.** Delivery-pogingen worden in AuditEvents vastgelegd zodat aantoonbaar is dat de notificatie is uitgestuurd. Bij opeenvolgende delivery-failures wordt de Subscription op `status=error` gezet en gaat de lifecycle door — de verantwoordelijkheid voor een werkende webhook ligt bij de leverancier.

**Aanbevolen: alerting op gefaalde deliveries.** Leveranciers wordt aangeraden aan eigen zijde alerting in te richten op delivery-failures (`Subscription.status = error`). **Een doodgelopen webhook betekent dat de noodrem niet meer kan worden getrokken; die zichtbaarheid hoort op leveranciersniveau te zijn geborgd.**

Voor scenario's waarin data daadwerkelijk moet worden teruggehaald — zoals het recht om vergeten te worden (AVG art. 17) — gelden aparte routes en mechanismen.

#### Beheersbaarheid en configuratie

Bewaartermijnen en verwijderregels moeten beheerd en aangepast kunnen worden binnen vastgestelde kaders, zodat flexibiliteit behouden blijft bij wijzigingen in wet- en regelgeving of contractuele afspraken.

### Oplossingsrichting

#### Coördinatie via Task (`KT2_DeletePendingTask`)

Het verwijderproces wordt aangekondigd en gecoördineerd via een FHIR `Task` per doelapplicatie, in combinatie met AuditEvents voor de aantoonbaarheid. De Patient zelf wordt daarbij niet aangeraakt.

**Doorslaggevend** voor de keuze van een Task boven een `meta.tag` op de Patient is dat de **status van de opschoningsworkflow én de verslaglegging daarvan per applicatie afzonderlijk kan worden vastgelegd**. Eén tag op de gedeelde Patient-resource representeert maar één toestand voor alle deelnemers tegelijk; een Task per (Patient × doelapplicatie) geeft iedere applicatie een eigen, onafhankelijk bij te werken statusobject met een eigen audit-spoor. Daarmee zijn meerdere gelijktijdige holds, een eigen "groen licht" (`accepted`) en een eigen verslaglegging vanzelfsprekend in plaats van iets dat uit een gedeelde log gereconstrueerd moet worden.

Bijkomende voordelen: de Patient wordt niet gemuteerd (geen `versionId`/`lastUpdated`-bump, geen "herleven" van een dormante Patient, geen vervuiling van het reguliere Patient-abonnement), de AuditEvent blijft zuiver bewijslog, en de noodrem is een native statusovergang op de eigen Task in plaats van een cross-tenant schrijfactie op een gedeelde resource.

**Eén Task per (Patient × doelapplicatie).** Bij het ingaan van de grace period maakt de Koppeltaalvoorziening voor elke opt-in doelapplicatie die data heeft van de betreffende Patient één Task aan. Het profiel `KT2_DeletePendingTask` legt de belangrijkste constraints vast:

| Element | Waarde / constraint | Toelichting |
| --- | --- | --- |
| `code` | `delete-pending` (CodeSystem `koppeltaal-task-code`) | Type van de aankondigings-Task |
| `intent` | `order` | Een vaststaande purge wordt aangekondigd |
| `for` | `Reference(KT2_Patient)` | De Patient die wordt opgeschoond; plaatst de Task in het Patient-compartiment |
| `owner` | `Reference(KT2_Device)` | De opt-in doelapplicatie (altijd een `Device`); **nooit** de Patient/RelatedPerson (zou de bewaartermijn-klok `T_task_owner` resetten) |
| `requester` | `Reference(KT2_Device)` | De Koppeltaalvoorziening |
| `restriction.period.end` | grace-deadline | Geplande `$purge`; de doelapplicatie leest hieruit hoeveel tijd resteert |
| `status` | zie lifecycle hieronder | Native Task-lifecycle; de toestand leeft op de Task, niet op de Patient |

#### Status-lifecycle

De Task doorloopt een native lifecycle. De toestand "Actief" (geen aankondigings-Task) en "Deleted" (Patient bestaat niet meer; HTTP GET levert 404 Not Found) zijn conceptuele eindstaten die niet als Task-status bestaan.

<div style="clear: both; margin: 1em 0;">
{% include opschoning-patient-data-tasklifecycle.svg %}
</div>

| `Task.status` | Wie zet 'm | Betekenis |  |
| --- | --- | --- | --- |
| `requested` | Koppeltaalvoorziening (create) | Aangekondigd; grace period loopt; nog geen reactie |  |
| `on-hold` | Doelapplicatie | Tijdelijke noodrem — nog bezig; `statusReason` bevat de reden. Reversibel; opheffen → `accepted` |  |
| `accepted` | Doelapplicatie | Groen licht: lokale data veiliggesteld / akkoord; telt mee voor fast-track. Ook de bestemming bij het opheffen van een `on-hold` |  |
| `cancelled` | Koppeltaalvoorziening | Afgebroken vanwege hernieuwde patiëntbetrokkenheid |  |
| `completed` | Koppeltaalvoorziening | `$purge` uitgevoerd; de Task verdwijnt daarna mee |  |

**Governance.** De Koppeltaalvoorziening creëert de Task en zet `cancelled` en `completed`. Een doelapplicatie schrijft uitsluitend op haar **eigen** Task en alleen de waarden `on-hold` of `accepted`. Het opheffen van een tijdelijke noodrem gebeurt door de Task van `on-hold` naar `accepted` te zetten.

#### Grace period en noodrem
De `$purge` mag pas plaatsvinden wanneer **geen enkele** `delete-pending`-Task voor deze Patient op `on-hold` staat, **én** ofwel de grace-deadline (`restriction.period.end`) is verstreken, **ofwel** álle relevante doelapplicatie-Tasks staan op `accepted` (fast-track).

Na ontvangst van de aankondiging heeft de doelapplicatie gedurende de grace period (`restriction.period`) de gelegenheid om relevante data op te halen en lokaal veilig te stellen, en — indien nodig — de noodrem te trekken.

- **Tijdelijke noodrem (`on-hold`)**: een doelapplicatie die nog niet klaar is, pauzeert de verwijdering door haar eigen Task op `on-hold` te zetten met een `statusReason`. Omdat elke applicatie een eigen Task heeft, zijn meerdere gelijktijdige noodremmen vanzelf onafhankelijk. Opheffen gebeurt door de Task op `accepted` te zetten (klaar én akkoord).
- **Groen licht (`accepted`)**: een doelapplicatie die klaar is, zet haar Task op `accepted`. Wanneer **alle** relevante doelapplicaties `accepted` hebben gezet, mag de `$purge` **vóór** het verstrijken van de grace-deadline plaatsvinden (fast-track).
- De **noodrem-grace** is voorlopig **oneindig**; een latere time-out (bijvoorbeeld 30 dagen) is een operationele regel die het model niet verandert.

Het model is **opt-out** binnen de grace period: geen actie betekent dat de verwijdering doorgaat zodra de deadline verstrijkt en geen enkele Task `on-hold` staat.

#### AuditEvents bij statusovergangen

Elke statusovergang wordt vastgelegd in een immutable AuditEvent met ISO 21089 lifecycle-codes op `AuditEvent.type` (`http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle`). Dit biedt een aantoonbare audit trail die de `$purge` overleeft:

| Moment | ISO 21089 `type` | Actor | Doel |
| --- | --- | --- | --- |
| Task aangemaakt (`requested`) | `archive` | Koppeltaalvoorziening | Aantoonbaar: verwijdering aangekondigd, grace period begint |
| Noodrem getrokken (`on-hold`) | `hold` | Doelapplicatie | Aantoonbaar: welke applicatie blokkeert en waarom |
| Blokkade opgeheven (`accepted`) | `unhold` | Doelapplicatie | Aantoonbaar: blokkade is opgeheven |
| Afgebroken (`cancelled`) | `reactivate` | Koppeltaalvoorziening | Aantoonbaar: verwijdering afgebroken vanwege hernieuwde betrokkenheid |
| `$purge` uitgevoerd (`completed`) | `destroy` | Koppeltaalvoorziening | Aantoonbaar: data is definitief vernietigd; draagt tevens het **post-delete** signaal |

Een `accepted`-overgang ná een `on-hold` legt een `unhold`-AuditEvent vast; een `accepted` als eerste reactie (zonder voorafgaande noodrem) is een coördinatiesignaal zonder eigen lifecycle-AuditEvent. De destroy-AuditEvent overleeft de $purge en is daarmee de enige bron voor het post-delete signaal — doelapplicaties die het definitieve verwijdermoment willen weten, subscriben op AuditEvent met type = …iso-21089-lifecycle|destroy.

#### Activiteitscheck vóór verwijdering

Voordat de Koppeltaalvoorziening tot `$purge` overgaat, berekent zij `last-patient-engagement` (zoals gedefinieerd onder [Startmoment bewaartermijn](#startmoment-bewaartermijn-moet-eenduidig-zijn)) en vergelijkt het resultaat met het moment waarop de aankondigings-Task is aangemaakt. Wanneer de berekende waarde later ligt — bijvoorbeeld doordat de patiënt of een aan deze patiënt gekoppelde RelatedPerson opnieuw heeft ingelogd, of doordat de patiënt als uitvoerder een Task heeft afgehandeld — wordt de patiënt opnieuw als actief beschouwd en wordt de verwijdering afgebroken:

- De aankondigings-Task(s) worden op `cancelled` gezet
- Een AuditEvent (`reactivate`) wordt aangemaakt met als reden "hernieuwde betrokkenheid"
- De bewaartermijn van 2 jaar begint opnieuw vanaf de berekende `last-patient-engagement`-waarde

De berekening bestaat uit een aantal gerichte FHIR-searches per kandidaat-Patient. Conceptueel ziet dat er als volgt uit (exacte search-parameters volgen het profiel van `KT2_AuditEvent` en `KT2_Task`):

```
# Meest recente patiëntbetrokkenheid via authenticatie (type DCM#110114):
#   /authorize-login (subtype DCM#110122) of /introspect[hti] (subtype TBD, voorstel DCM#110143)
#   — access-/id-token-introspectie valt buiten dit subtype-filter
# ... met de Patient zelf als actor
GET /AuditEvent?agent=Patient/{id}&type=110114&subtype=110122,{hti-introspect-subtype}&_sort=-date&_count=1

# ... met een aan deze Patient gekoppelde RelatedPerson als actor
#     (chained op de agent-referentie; geen aparte RelatedPerson-lookup nodig)
GET /AuditEvent?agent:RelatedPerson.patient=Patient/{id}&type=110114&subtype=110122,{hti-introspect-subtype}&_sort=-date&_count=1

# Meest recente Task met de Patient als uitvoerder
GET /Task?owner=Patient/{id}&_sort=-_lastUpdated&_count=1

# Meest recente Task met een gekoppelde RelatedPerson als uitvoerder (chained op owner)
GET /Task?owner:RelatedPerson.patient=Patient/{id}&_sort=-_lastUpdated&_count=1
```

De Koppeltaalvoorziening neemt max(...) over de gevonden timestamps. Is die later dan het moment waarop de aankondiging is gedaan, dan wordt de verwijdering afgebroken. Door op `agent`/`owner` te chainen naar `RelatedPerson.patient` worden de gekoppelde RelatedPersons in dezelfde query meegenomen — een aparte `GET /RelatedPerson?patient=Patient/{id}` is dus niet nodig. (Wie op de patient-identifier wil matchen in plaats van de logische referentie, gebruikt `…patient:identifier=<system|waarde>`.) De aankondigings-Task zelf (`owner` = `Device`) komt niet in de `owner=Patient`-query voor en beïnvloedt de klok dus niet.

Deze controle voorkomt dat data wordt verwijderd van patiënten die tijdens of vlak na de grace period weer actief worden. De controle wordt op het moment van de geplande $purge uitgevoerd, zodat ook betrokkenheid aan het einde van de grace period wordt meegenomen.

#### Interactiediagram

Het volgende diagram toont de volledige interactie tussen de initiator, de Koppeltaalvoorziening en doelapplicaties, inclusief de noodrem.

<div style="clear: both; margin: 1em 0;">
{% include opschoning-patient-data-interactie.svg %}
</div>

#### Definitieve verwijdering: `$purge`

De overgang naar Deleted wordt technisch uitgevoerd via de FHIR [`$purge` operatie](https://build.fhir.org/patient-operation-purge.html). De `$purge `maakt gebruik van het [FHIR Patient Compartment](https://www.hl7.org/fhir/compartmentdefinition-patient.html) om te bepalen welke resources aan een patiënt gerelateerd zijn. Met de parameter` cascade=true` worden alle resources binnen het Patient Compartment in één operatie verwijderd, inclusief de Patient resource zelf.


De scope van de `$purge` omvat onder andere:

- Patient
- Task (inclusief de aankondigings-Tasks zelf)
- RelatedPerson
- CareTeam

AuditEvent resources overleven de `$purge` — zij bevatten geen persoonsgegevens en vallen onder een langere bewaartermijn.

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

### Alternatieven

Naast de gekozen oplossingsrichting (Task-coördinatie) zijn de volgende alternatieve benaderingen overwogen en afgewezen (of als variant genoteerd):

#### `meta.tag` lifecycle in plaats van Task

Een eerdere oplossingsrichting stuurde het verwijderproces via `meta.tag` op de Patient resource: een tag `DELETE_PENDING` markeerde de aankondiging en een tag `DELETE_HOLD` de noodrem, met FHIR Subscriptions op `Patient?_tag=…`. Deze benadering is afgewezen:

- **Geen per-applicatie status of verslaglegging**: één tag op de gedeelde Patient representeert maar één toestand voor álle deelnemers tegelijk. De individuele workflow-status en verslaglegging per doelapplicatie — en meerdere gelijktijdige holds — moeten dan uit de AuditEvent-log gereconstrueerd worden in plaats van als eersteklas state te bestaan.
- **Mutatie van de Patient**: het zetten van een tag wijzigt `versionId`/`lastUpdated` en kan (server-afhankelijk) een REST-AuditEvent en Patient-subscription-notificatie triggeren. Daardoor "herleeft" een twee jaar dormante Patient als gewijzigd, precies wat we willen vermijden.
- **Cross-tenant schrijven**: de noodrem vereist dat een doelapplicatie op de gedeelde Patient-resource schrijft.

Het `meta.tag`-model is uitgewerkt in onderstaande lifecycle (ter referentie; **niet** de gekozen richting):

| Code | Display | Beschrijving |
| --- | --- | --- |
| `DELETE_PENDING` | Delete Pending | Patient is gemarkeerd voor verwijdering; grace period loopt |
| `DELETE_HOLD` | Delete Hold | Noodrem — een doelapplicatie blokkeert het verwijderproces |

<div style="clear: both; margin: 1em 0;">
{% include opschoning-patient-data-tag-lifecycle.svg %}
</div>

#### FHIR soft delete

Een alternatieve benadering zou zijn om de FHIR soft delete (HTTP DELETE met bewaren van een tombstone) te gebruiken als verwijdersignaal, gevolgd door een definitieve `$purge`. Deze benadering is onderzocht en afgewezen om de volgende redenen:

- **Geen revert bij cascading delete**: bij een cascading soft delete in HAPI FHIR krijgt elke resource een eigen tombstone. Ongedaan maken (noodrem) vereist dat de blokkerende applicatie per resource een VREAD doet op de voorlaatste versie en deze opnieuw PUT — niet werkbaar
- **Geen notificaties bij DELETE**: FHIR R4 stuurt standaard geen Subscription-notificaties bij een DELETE request, waardoor doelapplicaties de verwijdering niet detecteren
- **Onbekende ondersteuning**: het is niet vastgesteld of cascading soft delete wordt ondersteund door alle FHIR-serverimplementaties (bijv. InterSystems)

De Task-benadering is expliciet over de lifecycle en de staat per applicatie, werkt met standaard FHIR Subscriptions, en is niet afhankelijk van serverspecifieke DELETE-functionaliteit.

#### Geen notificatie

In de praktijk geldt dat wanneer een patiënt langere tijd inactief is geweest, er via Koppeltaal geen actieve interactie meer plaatsvindt. Het "verdwijnen" van de data is in dat geval geen functioneel probleem voor de doelapplicatie. De initiator kan in dit scenario direct de `$purge` uitvoeren zonder voorafgaande coördinatie.

Dit is het eenvoudigste model, maar biedt geen mogelijkheid voor doelapplicaties om data veilig te stellen of bezwaar te maken.

#### Two-phase commit via Tasks

De gekozen oplossingsrichting gebruikt een **aankondigings**-Task: een lichte coördinatie waarbij geen actie van de doelapplicatie vereist is (opt-out). Een zwaardere variant is een two-phase commit, waarbij de Koppeltaalvoorziening per doelapplicatie een Task aanmaakt met een expliciete **opdracht** om de lokale patiëntdata te verwijderen, en pas tot `$purge` overgaat wanneer alle Tasks `completed` zijn. Dit biedt maximale coördinatie maar introduceert complexiteit in de vorm van Task-management en -monitoring, en maakt de doelapplicaties blokkerend in plaats van geïnformeerd.

#### Task lifecycle als indicator

Wanneer alle taken van een patiënt de status `completed` hebben, kan men beargumenteren dat alle due diligence is uitgevoerd: de behandelmodules zijn afgerond, de resultaten zijn teruggekoppeld, en er zijn geen openstaande interacties meer. In dat geval kan de initiator er in bepaalde situaties voor kiezen om direct tot verwijdering over te gaan zonder voorafgaande notificatie.

#### Vervallen: meta-extension `last-patient-engagement`


Motivatie: de activiteitscheck vindt alleen plaats op het moment van `$purge`. Een paar gerichte FHIR-searches op dat moment is goedkoper dan permanent state synchroon houden in alle deelnemende systemen. Bovendien zijn AuditEvents (NEN 7513) en Tasks al de canonieke bron van waarheid voor "activiteit" en "uitvoeringsbetrokkenheid" — een aparte meta-state ernaast zou een tweede bron introduceren die in conflict kan raken met die canonieke bronnen.

De afzonderlijke pagina `opschoning-patient-data-startmoment` waarin de meta-extension was uitgewerkt, is met deze beslissing verwijderd.

### Overwegingen

Bij de gekozen oplossingsrichting gelden de volgende aandachtspunten en open punten:

#### RelatedPerson in de mix

In het Koppeltaal-model is een RelatedPerson per definitie gekoppeld aan één specifieke Patient (`RelatedPerson.patient`). Activiteit van die RelatedPerson — een login via `/authorize`, of een Task waarvan de RelatedPerson de uitvoerder is — geldt daarom als betrokkenheid bij die patiënt en telt mee in `last-patient-engagement`.

Praktisch kan de [activiteitscheck](#activiteitscheck-vóór-verwijdering) de gekoppelde RelatedPersons in dezelfde query meenemen via een chained search (`agent:RelatedPerson.patient` resp. `owner:RelatedPerson.patient`), zonder ze eerst apart op te halen. De RelatedPersons zelf worden in de `$purge`-cascade meegenomen (zij vallen binnen het Patient Compartment).

Open vraag voor latere iteratie: willen we deze regel óók expliciet vastleggen in een StructureDefinition-invariant of in het CapabilityStatement, zodat een implementatie de afdwingbaarheid niet zelf hoeft af te leiden uit deze pagina?

#### AuditEvent voor `/introspect[hti]`

`/introspect` werkt in Koppeltaal op meerdere tokentypes: HTI launch tokens, access tokens en id tokens (zie [TOP-KT-021](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27125106)). Alleen introspectie van **HTI launch tokens** mag de bewaartermijn resetten, omdat dat het signaal is dat een doelapplicatie daadwerkelijk een patiëntgerichte launch verwerkt. Introspectie van access- of id-tokens is een technische tokenvalidatie en bewijst geen patiëntinteractie.

Voorstel: hergebruik het bestaande User Authentication AuditEvent (`type DCM#110114`, zie TOP-KT-011) met een eigen subtype (voorstel `DCM#110143`) en de mapping van Patient/RelatedPerson naar `agent.who`. Hiermee is geen nieuw AuditEvent-type nodig. De definitieve subtype-coding wordt bevestigd in een vervolgtraject (relateert aan [TOP-KT-011 - Logging en tracing](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27125090) en TOP-KT-021). Tot die tijd is `T_introspect_hti` inactief en steunt de berekening op `T_authorize` en `T_task_owner`.

In een eerdere iteratie was voorzien dat het startmoment als state werd vastgelegd in een dedicated FHIR-extension onder `Patient.meta` (`KT2_LastPatientEngagement`), bijgewerkt door de Koppeltaalvoorziening bij `/authorize` en `/introspect` en door zelf-inloggende applicaties via directe PATCH met ETag-gebaseerde optimistic locking, plus een eenmalige backfill voor bestaande Patient-resources. Deze aanpak komt te vervallen ten gunste van de querybenadering.
### Referenties

- [FHIR Patient $purge operatie](https://build.fhir.org/patient-operation-purge.html)
- [FHIR R4 Task](https://hl7.org/fhir/R4/task.html) / [TaskStatus](https://hl7.org/fhir/R4/valueset-task-status.html)
- [ISO 21089 lifecycle CodeSystem](https://terminology.hl7.org/7.1.0/en/CodeSystem-iso-21089-lifecycle.html)
- [FHIR Security Labels](https://www.hl7.org/fhir/security-labels.html)
- [NEN 7510 - Informatiebeveiliging in de zorg](https://www.nen.nl/nen-7510-1-2017-nl-245399)
- [NEN 7513 - Logging](https://www.nen.nl/nen-7513-2018-nl-247904)
- [AVG - Algemene verordening gegevensbescherming](https://eur-lex.europa.eu/eli/reg/2016/679/oj)
- [WGBO - Wet op de geneeskundige behandelingsovereenkomst](https://wetten.overheid.nl/BWBR0005290)
