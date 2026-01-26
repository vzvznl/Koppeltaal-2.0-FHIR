### Executive Summary

Dit document analyseert KPTSTD-879 en formuleert **drie voorstellen** voor aanpassingen in TOP-KT-011:

| # | Voorstel | Status |
|---|----------|--------|
| 1 | **X-Correlation-Id volgt causaliteit** - Verwijst naar direct triggerende request, niet naar "root trigger" | Te accorderen |
| 2 | **X-Trace-Id fallback verwijderen** - Niet vullen met X-Request-Id, maar leeg laten of nieuwe waarde | Te accorderen |
| 3 | **Nieuw sequence diagram** - Vervangt huidige onduidelijke diagrammen | Te accorderen |

**Aanleiding:** Bevinding van Jan-Wijbrand Kolman (Minddistrict) dat de huidige diagrammen "onjuist of onduidelijk" zijn.

---

### Issue Overzicht

**Issue:** KPTSTD-879
**Titel:** Topic 11: Bevinding: Documentatie Sequence Diagram gebruik Trace Headers
**Topic:** TOP-KT-011 - Logging en tracering
**Huidige versie TOP-KT-011:** 1.3.0 (Draft, 10 sept 2025)

**Status:** Design Backlog
**Reporter:** Kees Graveland
**Assignee:** Roland Groen
**Parent:** KPTSTD-926 (TOPIC-11: Feedback en verbeteringen doorvoeren)
**Kind van:** KPTSTD-954

### Achtergrond

Dit issue komt voort uit een bevinding gerapporteerd door **Jan-Wijbrand Kolman** (Minddistrict) tijdens een TC-meeting.

#### Oorspronkelijke Feedback (Jan-Wijbrand Kolman)

> "Bij deze een markdown file met daarin een sequence diagram in Mermaid-syntax. Dit diagram is dus een weerslag van mijn begrip, aangevuld door Joris, van de bedoeling van de trace headers in Koppeltaal.
>
> Als mijn begrip juist is, mag wat mij betreft het diagram toegevoegd aan de spec. Ik denk dat de twee huidige sequence diagrammen op [deze pagina](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27095009/TOP-KT-011+-+Logging+en+tracing#Tracing-en-ketenlogging) **onjuist of in elk geval onduidelijk** zijn."

#### Referentie naar VZVZ Standaard

De VZVZ/Koppeltaal standaard is beschreven in:
- **Officiële URL:** [TOP-KT-011 - Logging en tracing](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27095009/TOP-KT-011+-+Logging+en+tracing)

De specificatie bevat op **pagina 5** twee sequence diagrammen voor "Tracing en ketenlogging". Deze diagrammen zijn de "onduidelijke" diagrammen waar Jan-Wijbrand over klaagt.

#### Analyse Huidige Diagrammen

De huidige spec bevat twee diagrammen die de header propagatie tonen. Problemen:

1. **Onduidelijke kleuren/labels** - Headers worden met kleurcodes aangeduid (A, B, G, Z) zonder duidelijke legenda
2. **Inconsistente X-Trace-Id** - In het tweede diagram verandert X-Trace-id naar "A" i.p.v. "Z" te behouden
3. **Geen causaliteitsketen zichtbaar** - Het is onduidelijk welk request welk ander request triggert

### Huidige Situatie in TOP-KT-011

Volgens de huidige specificatie gebruikt Koppeltaal drie headers voor ketenlogging:

| Header | Doel |
|--------|------|
| `X-Request-Id` | Unieke identifier per individueel request |
| `X-Trace-Id` | Identifier die constant blijft door de hele trace-keten |
| `X-Correlation-Id` | Verwijst naar de X-Request-Id van het voorgaande request in de keten |

Deze headers worden vastgelegd in AuditEvents en maken tracering mogelijk.

### Voorgesteld Diagram

Het voorgestelde sequence diagram toont de header propagatie in een typisch scenario:

#### Actoren
- **EPD** (EPD Supplier)
- **FHIR Store** (Koppeltaal-2)
- **kt2implementation** (Platform Supplier - Koppeltaal implementatie)
- **platform** (Platform Supplier - Interne platform)

#### Flow Samenvatting

1. **EPD -> FHIR Store:** Create Task
   - `X-Request-Id: epd100`

2. **FHIR Store -> EPD:** Response
   - `X-Request-Id: epd100`
   - `X-Trace-Id: trace123` (FHIR store start nieuwe trace context)

3. **FHIR Store -> kt2implementation:** Subscription Notification
   - `X-Request-Id: fhir200` (nieuw request)
   - `X-Correlation-Id: epd100` (verwijst naar origineel)
   - `X-Trace-Id: trace123` (behouden)

4. **Vervolgverzoeken (kt2implementation):**
   - Alle gebruiken `X-Correlation-Id: fhir200` (verwijst naar de notification)
   - Alle behouden `X-Trace-Id: trace123`
   - Elk krijgt eigen `X-Request-Id` (md300, md301, md302, md303)

#### Belangrijke Observaties uit het Originele Diagram

1. **X-Trace-Id blijft constant** door de hele keten (trace123)
2. **X-Correlation-Id verwijst steeds naar de notification** - In het diagram hebben alle vervolgverzoeken `X-Correlation-Id: fhir200`. Dit is de X-Request-Id van de notification, niet van het direct triggerende request.
3. **X-Request-Id is uniek per request**
4. **FHIR Store start de trace context** (genereert X-Trace-Id)

**Probleem:** Door alle X-Correlation-Ids naar dezelfde notification te laten verwijzen (fhir200), gaat de causale/volgordelijke relatie verloren. Op basis van de AuditEvents kan dan niet gereconstrueerd worden welk request welk ander request heeft getriggerd.

### Review Punten

#### Vastgestelde Uitgangspunten

- [x] **X-Correlation-Id volgt causaliteit:** Verwijst naar het *direct* triggerende request. Komt een request voort uit de notificatie, gebruik notificatie request-id. Komt het voort uit de taak, gebruik taak request-id.
- [x] **X-Trace-Id generatie:** MAG nieuwe waarde genereren indien ontbreekt (zie Voorstel 2)
- [x] **X-Request-Id in response:** Zelfde als in request, tenzij deze ontbreekt, dan nieuwe waarde genereren
- [x] **Nieuwe trace starten:** Als een systeem zelf een trace start (bijv. batch processing), is dat een eigen trace met nieuwe X-Trace-Id en geen X-Correlation-Id (er is geen bovenliggend request)

#### Mogelijke Inconsistenties

1. In stap 3 krijgt kt2implementation de notification met `X-Correlation-Id: epd100`, maar in stap 4+ gebruikt kt2implementation `X-Correlation-Id: fhir200`. Dit suggereert dat de Correlation-Id altijd verwijst naar het *direct* triggerende request.

2. De responses bevatten geen X-Correlation-Id (alleen X-Request-Id en X-Trace-Id). Dit lijkt correct - Correlation-Id is alleen relevant voor uitgaande requests.

#### Feedback op Diagram (Review Roland)

**Fout in X-Correlation-Id voor stappen 7 en 11:**

Als de regel is dat X-Correlation-Id verwijst naar het *direct* triggerende request, dan:

| Stap | Actie | In diagram | Zou moeten zijn |
|------|-------|------------|-----------------|
| 5 | Request Task details | `fhir200` | `fhir200` (getriggerd door notification) |
| 7 | Forward Task data | `fhir200` | `md300` (getriggerd door stap 5) |
| 9 | Request Patient details | `fhir200` | `fhir200` (getriggerd door notification) |
| 11 | Forward Patient data | `fhir200` | `md302` (getriggerd door stap 9) |

**Conclusie:** De forward-acties (7, 11) zouden de X-Request-Id van hun direct triggerende request (5, 9) als X-Correlation-Id moeten gebruiken.

#### Fundamentele Vraag: Causaliteit

De juiste X-Correlation-Id hangt af van de causaliteitsketen. Er zijn twee mogelijke interpretaties:

**Scenario A: Parallelle triggering door notification**
```
Notification (3)
    |-- triggert direct -> Task ophalen (5)
    +-- triggert direct -> Patient ophalen (9)
```
Dan is `X-Correlation-Id: fhir200` voor stappen 5 en 9 correct

**Scenario B: Sequentiële/causale triggering**
```
Notification (3)
    +-- triggert -> Task ophalen (5)
                       +-- Task bevat Patient referentie
                           +-- triggert -> Patient ophalen (9)
```
Dan zou stap 9 `X-Correlation-Id: md300` moeten hebben (de Task request, niet de notification)

**Analyse:** In de praktijk is scenario B waarschijnlijker: je weet pas *welke* Patient je moet ophalen nadat je de Task hebt ontvangen (de Patient referentie zit in de Task). Dit betekent dat de causaliteit sequentieel is, niet parallel.

**Aanbeveling:** Het diagram moet expliciet maken wat de causaliteitsketen is, en de X-Correlation-Id moet deze causaliteit correct reflecteren.

### Gecorrigeerd Diagram (Scenario B: Sequentiële Causaliteit)

Het onderstaande diagram kan gerenderd worden met een [Mermaid viewer](https://mermaid.live/).

```
sequenceDiagram
    autonumber
    box EPD Supplier
        participant EPD as EPD
    end
    box Koppeltaal-2
        participant FHIRStore as FHIR store
    end
    box Platform Supplier
        participant kt2implementation as PlatformKT2Implementation
        participant platform as Platform
    end

    Note over EPD,platform: Initial request chain

    EPD->>FHIRStore: Create Task resource<br/>X-Request-Id: epd100

    FHIRStore-->>EPD: Task created response<br/>X-Request-Id: epd100<br/>X-Trace-Id: trace123

    Note over FHIRStore: Process subscription<br/>FHIR store started a new trace context

    FHIRStore->>kt2implementation: Notification about Task<br/>X-Request-Id: fhir200<br/>X-Correlation-Id: epd100<br/>X-Trace-Id: trace123

    Note over kt2implementation: Save incoming headers

    kt2implementation-->>FHIRStore: Notification received response<br/>Background processing started<br/>X-Request-Id: fhir200<br/>X-Trace-Id: trace123

    rect rgba(100, 100, 200, .1)
    Note over kt2implementation: Sequential resource fetching<br/>based on causal chain

    kt2implementation->>FHIRStore: Request Task details<br/>X-Request-Id: md300<br/>X-Correlation-Id: fhir200<br/>X-Trace-Id: trace123
    FHIRStore-->>kt2implementation: Task resource response<br/>X-Request-Id: md300<br/>X-Trace-Id: trace123

    kt2implementation->>platform: Forward Task data<br/>X-Request-Id: md301<br/>X-Correlation-Id: md300<br/>X-Trace-Id: trace123
    platform-->>kt2implementation: Task processed response<br/>X-Request-Id: md301<br/>X-Trace-Id: trace123

    Note over kt2implementation: Task contains Patient reference<br/>triggers Patient fetch

    kt2implementation->>FHIRStore: Request Patient details<br/>X-Request-Id: md302<br/>X-Correlation-Id: md300<br/>X-Trace-Id: trace123
    FHIRStore-->>kt2implementation: Patient resource response<br/>X-Request-Id: md302<br/>X-Trace-Id: trace123

    kt2implementation->>platform: Forward Patient data<br/>X-Request-Id: md303<br/>X-Correlation-Id: md302<br/>X-Trace-Id: trace123
    platform-->>kt2implementation: Patient processed response<br/>X-Request-Id: md303<br/>X-Trace-Id: trace123
    end

    Note over kt2implementation: X-Correlation-Id follows causal chain:<br/>notification → task fetch → patient fetch → forward
```

#### Wijzigingen t.o.v. Origineel

| Stap | Actie | Origineel | Gecorrigeerd | Reden |
|------|-------|-----------|--------------|-------|
| 7 | Forward Task data | `X-Correlation-Id: fhir200` | `X-Correlation-Id: md300` | Getriggerd door Task fetch (5) |
| 9 | Request Patient | `X-Correlation-Id: fhir200` | `X-Correlation-Id: md300` | Patient ref zit in Task response (6) |
| 11 | Forward Patient data | `X-Correlation-Id: fhir200` | `X-Correlation-Id: md302` | Getriggerd door Patient fetch (9) |

#### Causaliteitsketen

```
epd100 (EPD request)
    +-- fhir200 (Notification)
            +-- md300 (Task fetch)
                    |-- md301 (Forward Task)
                    +-- md302 (Patient fetch, want Patient ref in Task)
                            +-- md303 (Forward Patient)
```

---

### Voorstellen voor Aanpassingen TOP-KT-011

Op basis van de analyse van het voorgestelde diagram (KPTSTD-879) en de huidige spec worden de volgende aanpassingen voorgesteld.

---

#### Voorstel 1: X-Correlation-Id Volgt Causaliteit

**Uitgangspunt:** X-Correlation-Id verwijst naar het **direct triggerende request** (causale keten), niet naar de "root trigger" of het originele EPD request.

**Waarom causaliteit?**
De X-Correlation-Id wordt gebruikt om de sequentie te volgen. Door te verwijzen naar het direct triggerende request (in plaats van een vaste "root") kan op basis van de AuditEvents de volgorde in de tijd correct gereconstrueerd worden. Elk AuditEvent bevat:
- Zijn eigen X-Request-Id
- De X-Correlation-Id die verwijst naar het voorgaande request

Door deze keten te volgen kan de volledige causale flow worden afgeleid.

**Regel:**
- Komt een request voort uit de **notificatie**, gebruik notificatie X-Request-Id
- Komt een request voort uit de **taak** (die voortkomt uit de notificatie), gebruik taak X-Request-Id
- Komt een request voort uit een **resource fetch**, gebruik die fetch X-Request-Id

**Impact op diagram:**

| Stap | Actie | Scenario A (parallel) | Scenario B (causaal) |
|------|-------|----------------------|----------------------|
| 7 | Forward Task data | `fhir200` | `md300` |
| 9 | Request Patient | `fhir200` | `md300` |
| 11 | Forward Patient | `fhir200` | `md302` |

##### Huidige tekst X-Correlation-Id

```
De waarde van dit veld is globaal uniek en heeft een string waarde. Om globaal
uniek te zijn wordt aangeraden een uuid v4 te gebruiken.

Deze waarde is typisch het X-Request-Id van het originele request indien er
sprake is van een asynchroon request of notificatie. Verder niet gevuld.

Indien ontbreekt: leeg laten

Implementatie uitvoerder: leeg laten indien er geen bovenliggend request is,
vullen met X-Request-Id van het bovenliggend request.

Implementatie ontvanger: loggen in het AuditEvent indien van toepassing,
teruggeven in het HTTP response indien de X-Request-Id gevuld is met aan
andere waarde dan in het request is meegegeven.

Mapping op AuditEvent: extension.correlation-id
```

##### Voorgestelde tekst X-Correlation-Id

```
De waarde van dit veld is globaal uniek en heeft een string waarde. Om globaal
uniek te zijn wordt aangeraden een uuid v4 te gebruiken.

De X-Correlation-Id verwijst naar de X-Request-Id van het **direct triggerende
request**. Dit is het request dat causaal verantwoordelijk is voor het huidige
request. Voorbeelden:

- Een request dat voortkomt uit een **notification** gebruikt de X-Request-Id
  van die notification als X-Correlation-Id
- Een request dat voortkomt uit de **verwerking van een resource** (bijv. een
  Patient ophalen omdat de Task een Patient referentie bevat) gebruikt de
  X-Request-Id van het resource-fetch request als X-Correlation-Id
- Een request dat voortkomt uit de **response van een ander request** gebruikt
  de X-Request-Id van dat request als X-Correlation-Id

Indien ontbreekt: leeg laten

Implementatie uitvoerder: leeg laten indien er geen bovenliggend request is,
vullen met X-Request-Id van het **direct triggerende** request.

Implementatie ontvanger: loggen in het AuditEvent indien van toepassing,
teruggeven in het HTTP response indien de X-Request-Id gevuld is met een
andere waarde dan in het request is meegegeven.

Mapping op AuditEvent: extension.correlation-id
```

##### Verschil

| Aspect | Huidige tekst | Voorgestelde tekst |
|--------|---------------|-------------------|
| Definitie | "originele request" (onduidelijk) | "direct triggerende request" (causaal) |
| Voorbeelden | Geen | Drie concrete voorbeelden |
| Uitvoerder | "bovenliggend request" | "**direct triggerende** request" |

---

#### Voorstel 2: X-Trace-Id Fallback Verwijderen

**Probleem:** Het gebruiken van X-Request-Id als fallback voor X-Trace-Id is onlogisch:
- X-Request-Id is uniek per request
- X-Trace-Id identificeert een keten van gerelateerde requests
- Door X-Request-Id te hergebruiken vervaagt het onderscheid

**Voorstel:**
- X-Trace-Id MAG leeg zijn
- X-Trace-Id MAG ingevuld worden met een **nieuwe waarde** indien deze ontbreekt (nieuwe trace starten)
- X-Trace-Id wordt NIET gevuld met de X-Request-Id

##### Huidige tekst X-Trace-Id

```
De waarde van dit veld is globaal uniek en heeft een string waarde. Om globaal
uniek te zijn wordt aangeraden een uuid v4 te gebruiken.

De X-Trace-Id kan in verschillende requests met dezelfde waarde voorkomen om
aan te geven dat deze requests aan elkaar gerelateerd zijn.

Indien de waarde ontbreekt: in het request mag de ontvangende partij deze
vullen met de waarde van de X-Request-Id van het bovenliggende request. Het
veld mag ook leeg gelaten worden.

Implementatie uitvoerder: vullen met de X-Trace-Id waarde van het
bovenliggende request, of eventueel met de waarde van de X-Request-Id als het
bovenliggende request geen waarde voor de X-Trace-Id heeft ingevuld.

Implementatie ontvanger: opslaan indien er andere requests uit voorkomen,
vullen met X-Request-Id indien de X-Trace-Id ontbreekt of leeglaten. Loggen
in het AuditEvent indien van toepassing.

Mapping op AuditEvent: extension.trace-id
```

##### Voorgestelde tekst X-Trace-Id

```
De waarde van dit veld is globaal uniek en heeft een string waarde. Om globaal
uniek te zijn wordt aangeraden een uuid v4 te gebruiken.

De X-Trace-Id kan in verschillende requests met dezelfde waarde voorkomen om
aan te geven dat deze requests aan elkaar gerelateerd zijn.

Indien de waarde ontbreekt: de ontvangende partij MAG een nieuwe X-Trace-Id
genereren om een nieuwe trace context te starten. Het veld MAG ook leeg
gelaten worden.

Implementatie uitvoerder: vullen met de X-Trace-Id waarde van het
bovenliggende request indien aanwezig, anders leeg laten.

Implementatie ontvanger: opslaan indien er andere requests uit voorkomen.
Indien de X-Trace-Id ontbreekt MAG een nieuwe waarde gegenereerd worden of
leeg gelaten worden. Loggen in het AuditEvent indien van toepassing.

Mapping op AuditEvent: extension.trace-id
```

##### Verschil

| Aspect | Huidige tekst | Voorgestelde tekst |
|--------|---------------|-------------------|
| Fallback indien ontbreekt | "vullen met X-Request-Id" | "nieuwe waarde genereren OF leeg laten" |
| Uitvoerder fallback | "met waarde van X-Request-Id" | "leeg laten" |
| Ontvanger fallback | "vullen met X-Request-Id" | "nieuwe waarde OF leeg laten" |

---

#### Voorstel 3: Sequence Diagram Toevoegen aan Spec

**Voorstel:** Het sequence diagram (Scenario B - Causale keten) toevoegen aan de TOP-KT-011 Confluence pagina ter **vervanging** van de huidige onduidelijke diagrammen.

**Huidige situatie:**
- Twee diagrammen met kleurcodes (A, B, G, Z) zonder duidelijke legenda
- Inconsistente X-Trace-Id propagatie
- Geen zichtbare causaliteitsketen

**Na aanpassing:**
- Een helder sequence diagram met Mermaid syntax
- Expliciete header waarden per request
- Zichtbare causaliteitsketen in de notities
- Vergelijkingstabel (optioneel: beide scenario's tonen)

---

### Vergelijkingstabel: Huidige vs. Voorgestelde Spec

| Header | Aspect | Huidige Spec | Voorstel |
|--------|--------|--------------|----------|
| **X-Correlation-Id** | Verwijzing | "originele request" (vaag) | "direct triggerende request" (causaal) |
| **X-Correlation-Id** | Voorbeelden | Geen | 3 concrete voorbeelden |
| **X-Trace-Id** | Fallback | Vullen met X-Request-Id | Nieuwe waarde OF leeg |
| **Diagrammen** | Formaat | Kleurcodes, onduidelijk | Mermaid, expliciet |

---

### Te Updaten Secties in TOP-KT-011

1. **Sectie "Ketenlogging" (pagina 4-5):**
   - Vervangen van de twee onduidelijke diagrammen door het nieuwe sequence diagram
   - Toevoegen van de vergelijkingstabel voor Scenario A vs. B (ter verduidelijking)

2. **Sectie "X-Correlation-Id" (pagina 5-6):**
   - Toevoegen van definitie "direct triggerende request"
   - Toevoegen van drie concrete voorbeelden
   - Aanpassen van "Implementatie uitvoerder" tekst

3. **Sectie "X-Trace-Id" (pagina 6):**
   - Verwijderen van "vullen met X-Request-Id" fallback
   - Aanpassen naar "nieuwe waarde OF leeg laten"

---

### Volgende Stappen

| # | Stap | Status |
|---|------|--------|
| 1 | Vergelijken met KPTSTD-879.doc | Afgerond |
| 2 | Review voorgesteld diagram | Afgerond |
| 3 | Voorstellen bespreken/accorderen | In afwachting |
| 4 | Aanpassingen doorvoeren op Confluence | Na akkoord |

**Scope:** Alleen Confluence wijzigingen (TOP-KT-011), geen FHIR IG profielaanpassingen.

---

### Bijlagen

#### Bijlage A: Causaliteitsketen Voorbeeld

```
epd100 (EPD request - Create Task)
    |
    +-- fhir200 (FHIR Store Notification)
            |
            +-- md300 (Task fetch - correlation: fhir200)
                    |
                    |-- md301 (Forward Task - correlation: md300)
                    |
                    +-- md302 (Patient fetch - correlation: md300, want Patient ref in Task)
                            |
                            +-- md303 (Forward Patient - correlation: md302)
```

#### Bijlage B: Nieuwe Trace Scenario

Wanneer een systeem zelf een trace start (bijv. batch processing, scheduled job):

```
batch001 (Batch processing start)
    |   X-Request-Id: batch001
    |   X-Correlation-Id: <leeg>
    |   X-Trace-Id: <nieuwe trace>
    |
    |-- proc001 (Process item 1)
    |   X-Request-Id: proc001
    |   X-Correlation-Id: batch001
    |   X-Trace-Id: <zelfde trace>
    |
    +-- proc002 (Process item 2)
        X-Request-Id: proc002
        X-Correlation-Id: batch001
        X-Trace-Id: <zelfde trace>
```

---

*Laatste update: 2026-01-26*
