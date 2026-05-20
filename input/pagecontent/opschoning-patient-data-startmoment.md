### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.0.1 | 2026-05-19 | Initiële versie: uitgesplitst vanuit [Opschoning Patient-data](opschoning-patient-data.html) (voorheen "Archivering"). Beschrijft het nieuwe meta-veld `last-patient-engagement`, welke events het updaten, hoe de Koppeltaalvoorziening en zelf-inloggende applicaties het bijwerken, conflictresolutie, backfill en de overweging van een AuditEvent-gedreven alternatief. FSH-uitwerking nog niet uitgevoerd — gespecificeerd onder "Geplande FSH-uitwerking" |

---

### Opschoning Patient-data - startmoment

Deze pagina beschrijft hoe het **startmoment van de bewaartermijn** voor patiëntdata binnen Koppeltaal wordt vastgelegd en bijgehouden. Voor de volledige context van het opschoningsproces (statussen, noodrem, `$purge`, rechten van betrokkenen) zie [Opschoning Patient-data](opschoning-patient-data.html).

Het uitgangspunt is dat de bewaartermijn van persoonsgegevens (2 jaar, AVG) start vanaf de **laatste aantoonbare betrokkenheid van de patiënt**. Welk moment dat precies is, wordt op de Patient resource zelf opgeslagen, in een dedicated FHIR extension onder `Patient.meta`. Hieronder volgen de definitie, het updatemechanisme, en de uitwerking voor verschillende applicatiepatronen.

### Het meta-veld: `last-patient-engagement`

Het startmoment wordt opgeslagen als een extension op `Patient.meta`:

```
Patient.meta.extension[
  url = "http://koppeltaal.nl/fhir/StructureDefinition/last-patient-engagement"
].valueInstant = "2026-05-19T14:32:00Z"
```

Eigenschappen:

- **Cardinaliteit**: `0..1` op de Patient resource. Voor nieuw aangemaakte Patient-resources wordt de extension direct gezet bij aanmaak.
- **Datatype**: `instant` (ISO 8601 met tijdzone-aanduiding). Gekozen boven `dateTime` omdat er altijd een exact tijdstip is en geen variabele precisie nodig is.
- **Plaats**: op `meta` en niet als gewone resource-extension. Het veld is een door het systeem beheerde timestamp (vergelijkbaar met `meta.lastUpdated`) en geen inhoudelijk patiëntgegeven; opname onder `meta` houdt deze scheiding zichtbaar.

#### Waarom een meta-extension en niet een afgeleide query

In een eerdere versie van het ontwerp werd "laatste betrokkenheid" telkens afgeleid uit het nieuwste relevante AuditEvent. Deze afleiding is in deze iteratie vervangen door een expliciete state op de Patient. Redenen:

- **Eén resource-read in plaats van een tijdsgebonden search**: voor de [activiteitscheck vóór Deleted](opschoning-patient-data.html#activiteitscheck-vóór-deleted) is één GET op de Patient voldoende.
- **Ondersteuning voor zelf-inloggende applicaties**: applicaties die hun eigen onboarding doen (zie hieronder) hebben geen Koppeltaal-AuditEvent bij elke gebruikersactiviteit; ze kunnen wel direct de meta-extension bijwerken.
- **Eén canonieke bron van waarheid**: het verwijdermoment wordt afgeleid uit één veld, niet uit een (potentieel inconsistente) verzameling AuditEvents.

AuditEvents blijven onverkort de audit trail (NEN 7513) en zijn het bewijs van wat er is gebeurd; de meta-extension is de state-representatie voor het verwijderproces.

### Welke events resetten het veld

Niet elke login binnen de context van een patiënt geldt als hernieuwde betrokkenheid van die patiënt. De bewaartermijn is gekoppeld aan de **betrokkenheid van de patiënt zelf** (of, in zijn rol, een aan deze patiënt gekoppelde RelatedPerson), en niet aan de administratieve of zorginhoudelijke activiteit van behandelaren rond een — mogelijk inactief geworden — patiëntdossier.

| Actor | Reset bewaartermijn Patient? | Toelichting |
| --- | --- | --- |
| Patient | Ja | Directe betrokkenheid van de patiënt zelf |
| RelatedPerson (gekoppeld aan deze Patient) | Ja | Een RelatedPerson is per definitie gekoppeld aan één specifieke patiënt; activiteit van de RelatedPerson telt als betrokkenheid bij die patiënt |
| Practitioner | Nee | Behandelaaractiviteit is niet patiëntgedreven — een behandelaar kan een inactief dossier blijven raadplegen zonder dat dit als hernieuwde patiëntbetrokkenheid mag tellen |

De ratio voor het uitsluiten van Practitioner-activiteit is dat de AVG-bewaartermijn van 2 jaar gekoppeld is aan de betrokkenheid van de betrokkene zelf. Behandelaaractiviteit volgt eigen administratieve en zorginhoudelijke logica en valt onder de bewaartermijn van het EPD (WGBO, 20 jaar). Zou een Practitioner-login wél resetten, dan zou een dossier dat door de patiënt is verlaten alsnog onbeperkt in de Koppeltaalvoorziening kunnen blijven hangen op basis van interne behandelaaractiviteit — precies wat de bewaartermijn moet voorkomen.

### Updaten van het veld

Er zijn twee bronnen die de extension bijwerken: de Koppeltaalvoorziening zelf (voor gebruikers die via de Koppeltaal-launch-flows binnenkomen), en zelf-inloggende applicaties (voor gebruikers die buiten die flows om de applicatie gebruiken).

#### Update door de Koppeltaalvoorziening

De Koppeltaalvoorziening werkt `last-patient-engagement` server-side bij op twee momenten:

- bij de `/authorize`-call van een SMART on FHIR launch (zowel EHR launch als standalone — zie [memo-standalone-smart-launch.html](memo-standalone-smart-launch.html));
- bij de `/introspect`-call op een HTI token, waarbij de doelapplicatie het ontvangen token bij de Koppeltaal authorization server valideert.

In beide gevallen is bekend welke gebruiker inlogt: Patient, RelatedPerson of Practitioner. De Koppeltaalvoorziening werkt de extension alleen bij wanneer de gebruiker een Patient is of een RelatedPerson gekoppeld aan een bepaalde Patient. Practitioner-logins worden genegeerd voor dit veld (maar wel gelogd in de audit trail).

De update is transparant voor de aanroepende client — de client doet niets bijzonders; de Koppeltaalvoorziening regelt de zijdelingse update op de Patient resource.

#### Update door zelf-inloggende applicaties

Sommige applicaties opereren buiten de standaard Koppeltaal-launch-flows. Het primaire voorbeeld zijn applicaties die:

1. een Subscription hebben op nieuwe Patient-resources,
2. bij notificatie de patiënt benaderen via een welkomstmail ("welkom bij onze applicatie, maak hier uw account aan"),
3. waarna de patiënt een eigen account in de applicatie aanmaakt en daarmee inlogt — zonder de Koppeltaal-`/authorize`- of `/introspect`-flow te doorlopen.

Voor deze applicaties bestaat de "User Authentication" niet bij de Koppeltaalvoorziening, en zou de extension dus nooit door de Koppeltaalvoorziening worden bijgewerkt. Deze applicaties zijn daarom zelf verantwoordelijk voor het updaten van `last-patient-engagement` bij elke aantoonbare gebruikersactiviteit door de patiënt of een aan de patiënt gekoppelde RelatedPerson.

**Mechanisme**: een directe update van de Patient resource met de nieuwe extension-waarde, met `If-Match`-header voor optimistic locking. Bijvoorbeeld via een FHIR PATCH:

```
PATCH /Patient/{id} HTTP/1.1
Content-Type: application/json-patch+json
If-Match: W/"42"

[
  {
    "op": "replace",
    "path": "/meta/extension/0/valueInstant",
    "value": "2026-05-19T14:32:00Z"
  }
]
```

(Het exacte JSON-pad hangt af van de aanwezigheid en positie van de extension; de praktische uitvoering kan in plaats hiervan een `add`-operatie zijn op een nog niet bestaand veld, of een PUT van de gehele resource.)

**Verantwoordelijkheden van de applicatie**:

- Alleen updaten bij activiteit van de Patient of een aan de Patient gekoppelde RelatedPerson; nooit op basis van Practitioner-activiteit. Dit wordt door de Koppeltaalvoorziening niet afgedwongen — de applicatie is eigen verantwoordelijk.
- Een geldige `If-Match`-header meesturen. De Koppeltaalvoorziening vereist ETag op alle resource-mutaties.
- Bij `412 Precondition Failed`: refetchen, conflictresolutie toepassen (zie hieronder), en opnieuw proberen.

#### Conflictresolutie

ETag-gebaseerde optimistic locking is verplicht. Bij een `412 Precondition Failed` haalt de schrijver de actuele Patient op en bepaalt de nieuwe extension-waarde als `max(huidige_waarde, eigen_nieuwe_waarde)`. Een latere binnenkomende update mag dus nooit een eerder vastgelegde, latere timestamp overschrijven. Deze regel geldt symmetrisch voor de Koppeltaalvoorziening en voor zelf-inloggende applicaties.

### Backfill bij initiële rollout

Bij introductie van de extension hebben bestaande Patient-resources nog geen `last-patient-engagement`-waarde. Voor een initiële opvulling wordt eenmalig een backfill-script uitgevoerd door de beheerder van de Koppeltaalvoorziening, met de volgende logica per Patient:

- **Primair**: `max(Task.lastUpdated)` over alle Tasks die binnen het Patient Compartment vallen. Dit weerspiegelt de laatste aantoonbare interactie via Koppeltaal voor die patiënt.
- **Fallback** (geen Tasks beschikbaar): `Patient.meta.lastUpdated`. Dit is een conservatieve benadering — beter dan geen waarde, maar minder nauwkeurig dan een Task-gebaseerde afleiding.

De backfill draait éénmalig vóór de eerste activiteitscheck. Voor Patient-resources die ná introductie zijn aangemaakt is geen backfill nodig: zij krijgen de extension via de normale update-paden.

De uitvoering van het backfill-script valt buiten deze IG — het script zelf hoort bij de implementatie van de Koppeltaalvoorziening.

### Geplande FSH-uitwerking

De onderstaande FSH-artefacten worden in een vervolgtraject (feature branch) toegevoegd. Tot die tijd is deze pagina de specificatie waarop de uitwerking gebaseerd wordt.

**Extension: `KT2_LastPatientEngagement`**

- Naam: `KT2_LastPatientEngagement`
- URL: `http://koppeltaal.nl/fhir/StructureDefinition/last-patient-engagement`
- Context: `Patient.meta`
- Cardinaliteit op de context: `0..1`
- Value type: `instant`
- Title: "Last patient engagement"
- Description: "Timestamp of the most recent demonstrable engagement of the patient (or a RelatedPerson linked to the patient) within the Koppeltaal domain. Used as the start moment for the retention period of personal data."

**Profile-aanpassing: `KT2_Patient`**

- Aansluiting op de nieuwe extension via `* meta.extension contains KT2_LastPatientEngagement named lastPatientEngagement 0..1`
- Geen wijziging in cardinaliteit van bestaande velden.

**Documentatie van de FSH-wijziging**

- Entry in `CHANGELOG.md` en `input/pagecontent/changes.md` (Nederlands, micro-versie-bump op feature branch).
- Eventuele voorbeeld-instances onder `input/fsh/examples` die `Patient.meta.lastPatientEngagement` demonstreren.

### Overwegingen

#### AuditEvent-gedreven update (afgewezen voor nu)

Een architectonisch schonere route is `[trigger] → AuditEvent → Koppeltaalvoorziening detecteert AuditEvent → werkt extension bij`. Voordelen:

- Eén canonieke weg waarlangs het veld wordt bijgewerkt — geen aparte schrijfpaden voor "Koppeltaal-flow" en "zelf-inloggende app".
- Audit-by-design: elke update van de extension heeft per definitie een corresponderend AuditEvent, zonder dat applicaties dat afzonderlijk hoeven te organiseren.
- Loose coupling: applicaties hoeven niet de exacte structuur van `Patient.meta` te kennen — ze schrijven een AuditEvent, en het centrale mechanisme zorgt voor de meta-update.

Voor deze iteratie afgewezen omdat:

- **Grotere impact**: alle apps zouden AuditEvents moeten gaan schrijven die ze nu nog niet schrijven. Voor zelf-inloggende apps — die buiten de Koppeltaal-flows opereren — is dat een grotere stap dan een directe meta-update.
- **Niet backwards-compatible**: bestaande implementaties die nu al rondom Patient-mutaties opereren zouden moeten worden aangepast.

Wij houden deze route open als toekomstige evolutie wanneer een breder AuditEvent-mechanisme voor applicatie-gegenereerde events operationeel is. In dat geval kan de directe meta-update worden uitgefaseerd ten gunste van de AuditEvent-gedreven route, zonder dat het concept van de meta-extension verandert.

#### AuditEvent vereisen bij meta-update door applicaties (open)

Een tussenvariant is dat zelf-inloggende applicaties wél direct de meta-extension bijwerken (zoals nu), maar daarnaast verplicht een corresponderend AuditEvent moeten schrijven voor audit-completeness. De Koppeltaalvoorziening zou dat dan ofwel kunnen valideren (afdwingen) ofwel als best practice kunnen vastleggen. Deze keuze valt buiten de scope van het huidige voorstel maar is een logisch volgend discussiepunt, met name in relatie tot [TOP-KT-011 - Logging en tracing](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27125090).

### Referenties

- [Opschoning Patient-data](opschoning-patient-data.html) — overkoepelende pagina over het verwijderproces
- [TOP-KT-011 - Logging en tracing](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27125090)
- [memo-standalone-smart-launch.html](memo-standalone-smart-launch.html) — context over de standalone SMART on FHIR launch
- [FHIR R4 — Patient resource](https://www.hl7.org/fhir/patient.html)
- [FHIR R4 — Meta type](https://www.hl7.org/fhir/resource.html#Meta)
- [RFC 7232 — HTTP Conditional Requests (ETag, If-Match)](https://datatracker.ietf.org/doc/html/rfc7232)
