### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.0.1 | 2026-05-26 | Initiële versie: voorstel voor een asynchroon community-proces met topic-document als eenheid, lazy consensus via Final Comment Period, en de tweewekelijkse meeting als complementair toelichtings- en operationeel overleg |

---

### Memo: Herziening tech community process



| **Datum** | 2026-05-26 |
| **Status** | Concept |
| **Auteur** | Roland Groen |

---

### 1. Aanleiding

De Koppeltaal 2.0 tech community komt op dit moment elke twee weken bij elkaar in een opt-in meeting. Daarin worden voorstellen besproken en wordt consent opgehaald voor de richting waarin de standaard zich ontwikkelt. In de praktijk lopen we tegen vier knelpunten aan:

- **Slecht bezochte meetings.** Veel vendors melden zich af; relevante stakeholders zijn niet altijd in de meeting aanwezig op het moment dat een onderwerp hen raakt.
- **Onstabiele beslissingen.** Een richting die in de meeting wordt afgesproken kan twee weken later opnieuw ter discussie staan, omdat andere vendors er pas later kennis van nemen.
- **Gemiste informatie bij vendors.** Beslissingen vallen wel, maar bereiken niet alle implementaties.
- **Beperkte relevantie van de agenda.** Veel onderwerpen raken slechts één of twee vendors; de overige deelnemers zitten erbij maar dragen weinig bij.

Tegelijkertijd neemt het aantal beslissingen en wijzigingen toe (zie onder andere de lopende trajecten KoppelMij, Opschoning, Topic 11, Documenten delen en Multiple IdP). De tweewekelijkse meeting alleen schaalt niet mee.

Deze memo stelt een aanvullend, asynchroon community-proces voor, waarmee voorstellen kunnen worden ingediend, gereviewd en met expliciete consent kunnen worden aangenomen — **buiten** de meeting om. De meeting blijft bestaan, maar krijgt een nieuwe rol.

### 2. Doel

Een herhaalbaar, asynchroon proces opzetten waarmee de tech community:

1. nieuwe Topics in de standaard kan voorstellen,
2. inhoudelijke wijzigingen op bestaande Topics kan doorvoeren,
3. consent kan ophalen zonder dat fysieke aanwezigheid in de meeting een vereiste is,
4. een auditbaar spoor achterlaat van overwegingen, bezwaren en uiteindelijke besluiten.

Beslissingen vallen in dit proces **asynchroon**, niet in de meeting. De meeting wordt complementair: een plek voor live toelichting op lopende voorstellen en voor operationele afstemming.

### 3. Artefacten

Drie soorten documenten leven naast elkaar in het proces:

| Artefact | Functie | Locatie |
| --- | --- | --- |
| **Memo** | Discussie- en analysedocument. Verkent een probleem of richting. Niet-normatief. | `input/pagecontent/memo-*.md` |
| **Spec** | Concept-normatieve beschrijving van een nieuw Topic of een wijziging op een bestaand Topic. Doorloopt formeel een Final Comment Period (FCP). | `input/pagecontent/<topic-slug>.md` |
| **Topic** | De geaccordeerde, canonieke beschrijving van een onderwerp in de standaard (bv. "Topic 11", "Opschoning Patient-data", "KoppelMij"). | Onderdeel van de IG, met eigen positie in het menu |

De normale flow is **memo → spec → topic**, waarbij:

- een **memo** een vraagstuk of richting verkent en aan de community wordt voorgelegd voor review (geen formele consent),
- de **spec** uit de memo voortkomt, doorgaat door een FCP en bij accept onderdeel wordt van het Topic,
- een **Topic** zelf één of meerdere specs en sub-pages kan bevatten, en in de loop van de tijd kan worden uitgebreid via opvolgende memo's en specs.

Een kleine wijziging op een bestaand Topic kan ook **direct als spec-PR** worden ingediend, zonder voorafgaande memo, mits de impact helder is. De shepherd bepaalt welke fasen overgeslagen kunnen worden.

### 4. Lifecycle

Een **spec** doorloopt onderstaande fases. Elke fase-overgang wordt expliciet aangekondigd door de shepherd.

```
   Draft
     │
     ▼
   Open for Discussion
     │
     ▼
   Final Comment Period (FCP)
     │
     ├──► Accepted
     │
     ├──► Postponed
     │
     └──► Rejected
```

#### Fase: Draft

De auteur schrijft de spec. Er kan worden samengewerkt, maar er is nog geen verzoek om brede review. Status in het document: `Concept`.

#### Fase: Open for Discussion

De shepherd kondigt aan dat het document klaar is voor brede community-review. Vendors lezen, stellen vragen, geven feedback. De auteur verwerkt feedback in het document. Status: `In review`.

#### Fase: Final Comment Period (FCP)

De shepherd verklaart dat de spec stabiel is, alle open vragen zijn geadresseerd, en opent de FCP met een samenvattings-comment: *"FCP geopend, loopt tot dd-mm-yyyy. Bij geen substantiële bezwaren wordt de spec daarna geaccepteerd."*

- Stilte tijdens FCP = consent (lazy consensus).
- Een **substantieel bezwaar** (concern) wordt gemarkeerd door een community-lid; de FCP-klok pauzeert tot het concern is geadresseerd door de auteur, waarna de shepherd de FCP-klok hervat of een nieuwe FCP opent (afhankelijk van de zwaarte van de wijziging).
- Niet-substantiële opmerkingen (typo's, verduidelijkingen) worden door de auteur verwerkt zonder klok-pauze.

Status: `FCP`.

#### Fase: Accepted

De shepherd sluit de FCP en publiceert een afsluitende samenvatting (besluit, eventuele open vervolgvragen). De spec wordt onderdeel van het Topic. Eventuele FSH-/profielwijzigingen die in de spec zijn aangekondigd worden via de gebruikelijke repo-PR-flow doorgevoerd, met verwijzing naar het Topic.

Status: `Geaccordeerd`.

#### Fase: Postponed / Rejected

Wanneer er geen consensus haalbaar is, of de richting niet langer wenselijk is, sluit de shepherd het traject. Het document blijft als historisch artefact behouden, met een statusnotitie.

### 5. Rollen

| Rol | Wie | Verantwoordelijkheid |
| --- | --- | --- |
| **Auteur** | Vendor of architect die het document schrijft | Eigenaar van de inhoud. Verwerkt feedback, beantwoordt vragen. |
| **Shepherd** | Architect (Kees Graveland of Roland Groen) | Bewaakt het proces. Beslist over fase-overgangen. Opent en sluit de FCP. Schrijft de afsluitende samenvatting. |
| **Community-lid** | Vendor in de Koppeltaal tech community | Leest, geeft feedback, markeert concerns. Geeft impliciet consent via lazy consensus. |
| **Visiegroep** | — | Escalatie-instantie wanneer consent niet haalbaar is via het normale proces. |
| **Eigenaarsraad** | — | Stelt elke 6 maanden de roadmap vast (bepaalt *wat* opgepakt wordt; het procesvoorstel hier bepaalt *hoe* een topic verloopt). |

### 6. Consent-mechaniek

Het beslismodel is **lazy consensus**: een spec wordt geaccepteerd als er aan het einde van een aangekondigde Final Comment Period geen substantiële bezwaren openstaan.

**Substantiële bezwaren** zijn comments die expliciet als `concern: <reden>` worden gemarkeerd door een community-lid. Een concern is substantieel wanneer het:

- een implementatiebarrière benoemt voor één of meer vendors,
- een interoperabiliteitsrisico benoemt,
- een conflict benoemt met andere onderdelen van de standaard, wet- en regelgeving, of bestaande topics,
- een afwijking aankaart van de overeengekomen scope of richting.

Niet-substantieel zijn typo's, stilistische voorkeuren of vragen om verduidelijking — die worden door de auteur verwerkt zonder dat de klok pauzeert.

Bij een substantieel concern:

1. de FCP-klok pauzeert;
2. de auteur antwoordt op het concern (verwerken of beargumenteerd weerleggen);
3. de shepherd beoordeelt of het concern is geadresseerd;
4. de FCP-klok hervat, óf er wordt een nieuwe FCP geopend bij grote inhoudelijke wijzigingen.

### 7. Relatie tot de tweewekelijkse meeting

De meeting blijft bestaan en wordt complementair aan het asynchrone proces:

- **Toelichting op lopende voorstellen.** De shepherd of auteur kan een lopende spec kort toelichten en vragen beantwoorden. Dit is een *aanvulling* op de asynchrone discussie; besluiten vallen niet in de meeting.
- **Operationele afstemming.** Project-voortgang, kwartaalplanning, status van implementaties, openstaande tickets.
- **Triage.** Welke openstaande topics zijn klaar voor FCP? Wie pakt iets op? Zijn er blokkades?

De agenda van de meeting volgt rechtstreeks uit de status van lopende specs en memo's. Wanneer er geen onderwerpen zijn die live toelichting behoeven, kan een meeting worden ingekort of geannuleerd.

### 8. Escalatie

Wanneer een traject vastloopt — bijvoorbeeld omdat een concern niet op te lossen is, of de community fundamenteel verdeeld is — escaleren de architects naar de **Visiegroep**. De Visiegroep neemt een richtinggevend besluit, dat door de shepherd in de spec wordt verwerkt en alsnog door een FCP gaat (om expliciet te maken dat het besluit ook na escalatie geconsolideerd is).

### 9. Aankondigingen en notificaties

Voor het slagen van lazy consensus is **brede en tijdige aankondiging** cruciaal — anders geldt "stilte = consent" niet, omdat stilte ook *onwetendheid* kan zijn.

Bij elke fase-overgang van een spec stuurt de shepherd een aankondiging naar de community via een vast aankondigingskanaal (zie §11, open vraag). De aankondiging bevat ten minste:

- titel en link naar het document,
- nieuwe status,
- bij FCP: einddatum van de FCP-klok en wat er gebeurt bij stilte,
- bij Accepted: link naar de afsluitende samenvatting.

Daarnaast kunnen community-leden zich per spec of per Topic **abonneren** (zie §11) om gerichter te volgen wat hen raakt.

### 10. Wat valt buiten dit proces?

Het proces is **niet** verplicht voor:

- typo's en stilistische correcties,
- build-tooling, scripts, CI-aanpassingen,
- documentatie-fixes die geen semantiek raken,
- verduidelijkingen waarover de tech community al unaniem akkoord is en die geen nieuwe interpretatie introduceren.

Deze wijzigingen volgen de gewone repo-PR-flow uit `CONTRIBUTING.md` (review door één maintainer, merge zonder FCP).

### 11. Open vragen

De volgende keuzes blijven bewust open en moeten in de eerste werkelijke toepassing van dit proces worden ingevuld:

1. **Duur van de FCP.** Bestaande communities hanteren waarden van 7 dagen (Rust RFC tweaks) tot 30 dagen (HL7 ballots). Voor Koppeltaal lijkt een duur tussen 10 en 14 werkdagen passend, zodat er in elke FCP minimaal één meeting valt waarin live toelichting mogelijk is.
2. **Tooling / kanaal.** Waar leeft de discussie en de aankondiging? Opties: e-mail-distributielijst, GitHub Issues/PRs op deze IG-repo, een dedicated Discourse- of Confluence-ruimte, of een Teams/Slack-kanaal. De keuze raakt vendors die geen GitHub-account hebben of die het stelsel niet dagelijks volgen.
3. **Abonnementen.** Wil de community een opt-in mechanisme waarbij vendors per Topic of spec aan kunnen geven dat ze actief volgen, zodat zij gerichte notificaties krijgen?
4. **Initiator-recht.** Mag elke vendor een memo of spec initiëren, of wordt initiatie geleid door de architects (vendors brengen wel onderwerpen in, maar het schrijven gebeurt door of in opdracht van de architects)?
5. **Shepherd-rol versus auteurschap.** Is het verplicht dat shepherd ≠ auteur — zodat de andere architect het proces bewaakt — of mag dezelfde persoon beide rollen vervullen mits dat expliciet wordt gemaakt?
6. **Memo-fase consent.** Krijgt een memo ook een formele FCP (lichtere variant), of blijft de memo-fase een vrije review en valt het formele consent-moment pas op het spec-niveau?
7. **Beheer publicatie.** Wie verwerkt de geaccepteerde spec in de canonieke Topic-pagina en eventuele FSH-wijzigingen — de auteur, de shepherd, of een aangewezen IG-beheerder?
8. **Definitie "substantieel".** Is de lijst in §6 voldoende, of moeten we explicieter omschrijven wanneer een concern de FCP-klok pauzeert versus wanneer het een gewone opmerking is?

### 12. Hoe verder

Deze memo doorloopt zelf — uiteraard — het proces dat hij voorstelt:

1. publicatie van deze memo als concept,
2. review door de tech community (eerste meeting na publicatie wordt benut voor live toelichting),
3. verwerking van feedback in een opvolgende spec-versie,
4. FCP op de spec-versie,
5. bij accept: het procesvoorstel wordt een nieuw Topic ("Tech Community Process"), de huidige memo blijft als historisch artefact bestaan.

### 13. Referenties — bestaande community-processen

Dit voorstel is geïnspireerd op een aantal bestaande open-standaard-communities. Voor wie zich verder wil inlezen:

- [Rust RFC-proces](https://github.com/rust-lang/rfcs) — GitHub-PR-gebaseerd, met een Final Comment Period en aangewezen shepherd. Goed leesbaar template, sterk vergelijkbaar met dit voorstel.
- [Python PEP](https://peps.python.org/pep-0001/) — proposal-document met statusveld, "PEP champion" en BDFL-Delegate (vergelijkbaar met de shepherd-rol hier).
- [IETF RFC en working groups](https://www.ietf.org/standards/process/) — mailinglist als hoofdkanaal, rough consensus, formele Last Call.
- [HL7 FHIR change request en ballot](https://confluence.hl7.org/display/FHIR/FHIR+Specification+Change+Request+Process) — tracker-gebaseerd (Jira), formele ballot-rondes.
- [W3C Process Document](https://www.w3.org/2023/Process-20230612/) — werkgroepen, chairs, formele transitions tussen Working Draft, Candidate Recommendation, Recommendation.
- [Apache Software Foundation voting](https://www.apache.org/foundation/voting.html) — lazy consensus met expliciete +1/0/-1 en binding versus non-binding stemmen.
- [Kubernetes KEP](https://github.com/kubernetes/enhancements/tree/master/keps) — Kubernetes Enhancement Proposals, statusveld, sponsoring SIG.
