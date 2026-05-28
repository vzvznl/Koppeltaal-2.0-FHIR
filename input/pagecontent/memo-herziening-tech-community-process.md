### Changelog

| Versie | Datum | Wijziging |
| --- | --- | --- |
| 0.0.1 | 2026-05-26 | Initiële versie: voorstel voor een asynchroon community-proces met topic-document als eenheid, lazy consensus via Final Comment Period, en de tweewekelijkse meeting als complementair toelichtings- en operationeel overleg |
| 0.0.2 | 2026-05-28 | §5 Break-out groepen toegevoegd als opt-in werkvorm voor de drafting-fase. Consensus binnen een break-out geldt als consent in de tech community (geen aparte FCP nodig). Latere secties met één opgeschoven |
| 0.0.3 | 2026-05-28 | In §7 expliciete verwijzing naar Sociocratie als filosofische basis voor de objection-vs-preference onderscheid in lazy consent; Sociocracy 3.0 toegevoegd aan §14 Referenties |
| 0.0.4 | 2026-05-28 | §5 en §4 scherpgesteld: een break-out is een werkvorm voor onderwerpen die diepe inhoudelijke analyse en samenwerking tussen betrokken partijen vereisen, niet voor het oplossen van discussies of conflicten |
| 0.0.5 | 2026-05-28 | §5 verzacht: na consensus binnen een break-out wordt het voorstel altijd aan de bredere community voorgelegd met een korte reactietermijn; consent volgt op grond van stakeholder-betrokkenheid in de groep, niet door de aankondiging zelf. §7, §10 cross-refs en §12 open vragen aangepast |

---

### Memo: Herziening tech community process



| **Datum** | 2026-05-26 |
| **Status** | Concept |
| **Auteur** | Roland Groen |

---

### 1. Aanleiding

De Koppeltaal 2.0 tech community komt op dit moment elke twee weken bij elkaar in een opt-in meeting. Daarin worden voorstellen besproken en wordt consent opgehaald voor de richting waarin de standaard zich ontwikkelt. In de praktijk lopen we tegen vier knelpunten aan:

- **Lage bezoekgraad meetings.** **Veel vendors melden zich af; relevante stakeholders zijn niet altijd in de meeting aanwezig op het moment dat een onderwerp hen raakt.**
- **Risico op onstabiele beslissingen.** **Een richting die in de meeting wordt afgesproken kan twee weken later opnieuw ter discussie staan, omdat andere vendors er pas later kennis van nemen.**
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

Een **spec** doorloopt onderstaande fases in de reguliere route. Elke fase-overgang wordt expliciet aangekondigd door de shepherd.

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

Naast deze reguliere route bestaat een alternatieve route via een break-out groep, beschreven in §5. Een break-out is geen aparte fase, maar een werkvorm die de reguliere Open for Discussion en FCP vervangt voor onderwerpen die diepe inhoudelijke analyse en intensieve samenwerking tussen de betrokken partijen vereisen.

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

### 5. Break-out groepen

Sommige onderwerpen vereisen een **diepe inhoudelijke analyse** en intensieve samenwerking tussen de inhoudelijk meest betrokken partijen — méér dan in async-review of in een reguliere tweewekelijkse meeting kan worden gerealiseerd. Daarvoor introduceert het proces een **break-out groep**: een opt-in werkvorm waarin een klein team van betrokken vendors een onderwerp gezamenlijk uitwerkt.

De aanleiding voor een break-out is de **complexiteit van het onderwerp**, niet onenigheid binnen de community. Een break-out is dus geen instrument om vastgelopen discussies vlot te trekken; daarvoor zijn de reguliere route met FCP en, in laatste instantie, de Visiegroep (zie §9). De bredere community wordt actief geïnformeerd over het werk in een break-out, en consent op de uiteindelijke spec komt voort uit de inhoudelijke betrokkenheid van de deelnemers.

#### Kenmerken

- **Ad-hoc en tijdelijk.** Een break-out wordt gevormd rond één specifiek onderwerp met een heldere deliverable en lost op zodra het werk is afgerond. Vergelijkbaar met een W3C Task Force.
- **Opt-in deelname.** Vendors melden zich expliciet aan. De groep is doorgaans klein (3–6 deelnemers) en bestaat uit de inhoudelijk meest betrokken partijen.
- **Eigen cadens en afspraken.** De break-out maakt zijn eigen schema van meetings en werkafspraken, los van de tweewekelijkse all-hands.
- **Volledig open transparantie.** Notulen, afspraken en work-in-progress documenten zijn voor de hele community zichtbaar. Niet-deelnemers kunnen meelezen en, indien gewenst, alsnog aansluiten of input via de shepherd inbrengen.

#### Vorming en aankondiging

Een break-out kan worden geïnitieerd door:

- **een vendor**: stelt voor om een break-out rond een specifiek onderwerp te vormen en draagt een eerste set deelnemers aan,
- **een shepherd** (architect): kan bij een complex onderwerp zelf de oprichting van een break-out voorstellen.

De formele start vereist accordering door de shepherd, om dubbel werk te voorkomen. De shepherd kondigt de break-out aan met (a) onderwerp en scope, (b) initiatiefnemers en deelnemers, (c) verwachte deliverable (memo, spec, of beide), (d) de plek waar notulen en WIP worden gepubliceerd.

De gedragsregel is: **vendors die deel willen nemen, sluiten zich aan.** De community is klein genoeg dat hiervoor geen formele verificatie- of join-window nodig is.

#### Output en voorlegging aan de community

In een break-out wordt **inhoudelijk consensus opgebouwd onder de meest betrokken vendors**. Zodra de groep een consensueel voorstel heeft, doorloopt het de volgende stappen:

- **Voorlegging aan de community.** De shepherd publiceert het voorstel aan de bredere tech community met deelnemerslijst, samenvatting van de gemaakte keuzes en een verwijzing naar de werkdocumenten. Er is **ruimte voor kritiek, vragen en opmerkingen** — een break-out levert een voorstel, geen voldongen feit.
- **Korte reactietermijn.** Het voorstel staat een afgesproken periode open voor reactie (zie §12, open vraag over de duur). Deze termijn is korter dan een reguliere FCP, omdat verondersteld wordt dat de inhoudelijk meest betrokken stakeholders al in de groep hebben meegedacht en hun mening hebben kunnen geven.
- **Substantiële bezwaren** worden door de break-out groep of de shepherd behandeld, conform de criteria in §7. De drempel voor heropening of inhoudelijke herziening ligt hoger dan bij een reguliere FCP, omdat de centrale discussie in de break-out heeft plaatsgevonden.
- **Bij accept**: de shepherd sluit de voorlegging, de spec krijgt status `Geaccordeerd` en wordt onderdeel van het Topic.
- **Eventuele FSH-/profielwijzigingen** die uit het voorstel volgen worden via de gebruikelijke repo-PR-flow doorgevoerd, met verwijzing naar het Topic en de break-out.

#### Geen consensus binnen de break-out

Wanneer de groep er onderling niet uitkomt, zijn er drie routes:

- **Terug naar de reguliere route**: de break-out levert het concept-document, en het traject vervolgt via Open for Discussion → FCP, waarin de bredere community alsnog meebeslist.
- **Escalatie naar de Visiegroep** (zie §9): wanneer het inhoudelijk vastloopt en de architects een richtinggevende uitspraak nodig hebben.
- **Uitstellen of intrekken**: de shepherd sluit het traject met een afsluitende notitie. Een toekomstige hervatting begint opnieuw, eventueel met een andere samenstelling.

#### Lifecycle-positie

```
   Draft
     │
     ├──► (regulier)  Open for Discussion → FCP ──────────────► Accepted
     │
     └──► (alt: break-out) interne consensus
                                 │
                                 ▼
                      Voorlegging aan community
                      (korte reactietermijn)
                                 │
                                 ▼
                              Accepted

   Postponed / Rejected zijn mogelijk vanuit beide routes.
```

De break-out is een **alternatieve route** naast de reguliere drafting + FCP-flow, niet een aparte fase erbovenop. Het verschil zit in **waar de inhoudelijke discussie plaatsvindt** (in de break-out groep in plaats van in een brede async-review) en in de **duur en zwaarte van het consent-moment** (kortere reactietermijn, hogere drempel voor heropening).

### 6. Rollen

| Rol | Wie | Verantwoordelijkheid |
| --- | --- | --- |
| **Auteur** | Vendor of architect die het document schrijft | Eigenaar van de inhoud. Verwerkt feedback, beantwoordt vragen. |
| **Shepherd** | Architect (Kees Graveland of Roland Groen) | Bewaakt het proces. Beslist over fase-overgangen. Opent en sluit de FCP. Accordeert oprichting en afronding van break-outs. Schrijft de afsluitende samenvatting. |
| **Community-lid** | Vendor in de Koppeltaal tech community | Leest, geeft feedback, markeert concerns. Sluit zich aan bij break-outs waar relevant. Geeft impliciet consent via lazy consensus. |
| **Visiegroep** | — | Escalatie-instantie wanneer consent niet haalbaar is via het normale proces of een break-out. |
| **Eigenaarsraad** | — | Stelt elke 6 maanden de roadmap vast (bepaalt *wat* opgepakt wordt; het procesvoorstel hier bepaalt *hoe* een topic verloopt). |

### 7. Consent-mechaniek

Het beslismodel is **lazy consensus**: een spec wordt geaccepteerd als er aan het einde van een aangekondigde Final Comment Period geen substantiële bezwaren openstaan. Voor specs die uit een break-out komen, geldt een verkorte voorlegging aan de community in plaats van een reguliere FCP — met hogere drempel voor inhoudelijke heropening, omdat de centrale discussie in de break-out heeft plaatsgevonden (zie §5).

De criteria voor wat een geldig bezwaar is, sluiten aan bij **Sociocratie**, en specifiek de [consent-based decision-making](https://patterns.sociocracy30.org/patterns/consent-decision-making.html) van Sociocracy 3.0. In sociocratie geldt: een voorstel wordt aangenomen als er geen *objections* zijn — waarbij een objection alleen telt wanneer het voorstel onwerkbaar is voor degene die bezwaar maakt, of voor het bereiken van de gezamenlijke doelen. Een persoonlijke voorkeur of stilistische kanttekening is geen objection. De achterliggende filosofie *"good enough for now, safe enough to try"* sluit goed aan bij specs die in opvolgende FCP-rondes verder worden aangescherpt.

Dit voorstel combineert deze sociocratische definitie van een geldig bezwaar met een **passief consent-mechanisme** uit lazy-consensus-stijl open source communities (Apache, Rust RFC): deelnemers hoeven niet actief "+1" te zeggen om consent te geven — stilte gedurende de FCP geldt als consent. Wel moet een bezwaarmaker actief zijn `concern: <reden>` markeren om de klok te pauzeren.

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

### 8. Relatie tot de tweewekelijkse meeting

De meeting blijft bestaan en wordt complementair aan het asynchrone proces:

- **Toelichting op lopende voorstellen.** De shepherd of auteur kan een lopende spec kort toelichten en vragen beantwoorden. Dit is een *aanvulling* op de asynchrone discussie; besluiten vallen niet in de meeting.
- **Statusoverzicht break-outs.** Welke break-outs lopen, wat is de voortgang, zijn er obstakels?
- **Operationele afstemming.** Project-voortgang, kwartaalplanning, status van implementaties, openstaande tickets.
- **Triage.** Welke openstaande topics zijn klaar voor FCP? Wie pakt iets op? Zijn er blokkades?

De agenda van de meeting volgt rechtstreeks uit de status van lopende specs, memo's en break-outs. Wanneer er geen onderwerpen zijn die live toelichting behoeven, kan een meeting worden ingekort of geannuleerd.

### 9. Escalatie

Wanneer een traject vastloopt — bijvoorbeeld omdat een concern niet op te lossen is, de community fundamenteel verdeeld is, of een break-out geen consensus bereikt — escaleren de architects naar de **Visiegroep**. De Visiegroep neemt een richtinggevend besluit, dat door de shepherd in de spec wordt verwerkt en alsnog door een FCP gaat (om expliciet te maken dat het besluit ook na escalatie geconsolideerd is).

### 10. Aankondigingen en notificaties

Voor het slagen van lazy consensus is **brede en tijdige aankondiging** cruciaal — anders geldt "stilte = consent" niet, omdat stilte ook *onwetendheid* kan zijn.

Bij elke fase-overgang van een spec of bij vorming/oplevering van een break-out stuurt de shepherd een aankondiging naar de community via een vast aankondigingskanaal (zie §12, open vraag). De aankondiging bevat ten minste:

- titel en link naar het document,
- nieuwe status,
- bij FCP: einddatum van de FCP-klok en wat er gebeurt bij stilte,
- bij break-out vorming: deelnemers, scope, plek van notulen/WIP,
- bij break-out oplevering: deelnemerslijst, samenvatting van het voorstel en einddatum van de reactietermijn,
- bij Accepted: link naar de afsluitende samenvatting.

Daarnaast kunnen community-leden zich per spec of per Topic **abonneren** (zie §12) om gerichter te volgen wat hen raakt.

### 11. Wat valt buiten dit proces?

Het proces is **niet** verplicht voor:

- typo's en stilistische correcties,
- build-tooling, scripts, CI-aanpassingen,
- documentatie-fixes die geen semantiek raken,
- verduidelijkingen waarover de tech community al unaniem akkoord is en die geen nieuwe interpretatie introduceren.

Deze wijzigingen volgen de gewone repo-PR-flow uit `CONTRIBUTING.md` (review door één maintainer, merge zonder FCP).

### 12. Open vragen

De volgende keuzes blijven bewust open en moeten in de eerste werkelijke toepassing van dit proces worden ingevuld:

1. **Duur van de FCP.** Bestaande communities hanteren waarden van 7 dagen (Rust RFC tweaks) tot 30 dagen (HL7 ballots). Voor Koppeltaal lijkt een duur tussen 10 en 14 werkdagen passend, zodat er in elke FCP minimaal één meeting valt waarin live toelichting mogelijk is.
2. **Tooling / kanaal.** Waar leeft de discussie en de aankondiging? Opties: e-mail-distributielijst, GitHub Issues/PRs op deze IG-repo, een dedicated Discourse- of Confluence-ruimte, of een Teams/Slack-kanaal. De keuze raakt vendors die geen GitHub-account hebben of die het stelsel niet dagelijks volgen.
3. **Abonnementen.** Wil de community een opt-in mechanisme waarbij vendors per Topic of spec aan kunnen geven dat ze actief volgen, zodat zij gerichte notificaties krijgen?
4. **Initiator-recht.** Mag elke vendor een memo of spec initiëren, of wordt initiatie geleid door de architects (vendors brengen wel onderwerpen in, maar het schrijven gebeurt door of in opdracht van de architects)?
5. **Shepherd-rol versus auteurschap.** Is het verplicht dat shepherd ≠ auteur — zodat de andere architect het proces bewaakt — of mag dezelfde persoon beide rollen vervullen mits dat expliciet wordt gemaakt?
6. **Memo-fase consent.** Krijgt een memo ook een formele FCP (lichtere variant), of blijft de memo-fase een vrije review en valt het formele consent-moment pas op het spec-niveau?
7. **Beheer publicatie.** Wie verwerkt de geaccepteerde spec in de canonieke Topic-pagina en eventuele FSH-wijzigingen — de auteur, de shepherd, of een aangewezen IG-beheerder?
8. **Definitie "substantieel".** Is de lijst in §7 voldoende, of moeten we explicieter omschrijven wanneer een concern de FCP-klok pauzeert versus wanneer het een gewone opmerking is?
9. **Drempel voor een break-out.** Wanneer is een onderwerp "complex genoeg" om voor een break-out te kiezen in plaats van de reguliere route? Is dat een inschatting van de shepherd, of zijn er objectievere criteria (aantal betrokken vendors, type wijziging, omvang van impact)?
10. **Duur van de community-voorlegging na een break-out.** Hoe lang staat een break-out-voorstel open voor reactie van de bredere community? Korter dan een reguliere FCP — een week werkdagen lijkt redelijk — maar de exacte duur ligt nog niet vast.

### 13. Hoe verder

Deze memo doorloopt zelf — uiteraard — het proces dat hij voorstelt:

1. publicatie van deze memo als concept,
2. review door de tech community (eerste meeting na publicatie wordt benut voor live toelichting),
3. verwerking van feedback in een opvolgende spec-versie,
4. FCP op de spec-versie (of break-out indien complex genoeg),
5. bij accept: het procesvoorstel wordt een nieuw Topic ("Tech Community Process"), de huidige memo blijft als historisch artefact bestaan.

### 14. Referenties — bestaande community-processen

Dit voorstel is geïnspireerd op een aantal bestaande open-standaard-communities. Voor wie zich verder wil inlezen:

- [Rust RFC-proces](https://github.com/rust-lang/rfcs) — GitHub-PR-gebaseerd, met een Final Comment Period en aangewezen shepherd. Goed leesbaar template, sterk vergelijkbaar met dit voorstel.
- [Python PEP](https://peps.python.org/pep-0001/) — proposal-document met statusveld, "PEP champion" en BDFL-Delegate (vergelijkbaar met de shepherd-rol hier).
- [IETF RFC en working groups](https://www.ietf.org/standards/process/) — mailinglist als hoofdkanaal, rough consensus, formele Last Call.
- [HL7 FHIR change request en ballot](https://confluence.hl7.org/display/FHIR/FHIR+Specification+Change+Request+Process) — tracker-gebaseerd (Jira), formele ballot-rondes.
- [W3C Process Document](https://www.w3.org/2023/Process-20230612/) — werkgroepen, chairs, formele transitions tussen Working Draft, Candidate Recommendation, Recommendation.
- [W3C Task Forces](https://www.w3.org/2020/Process-20200915/#GroupTaskForces) — tijdelijke opt-in subgroepen binnen een Working Group, met een afgebakende deliverable. Vergelijkbaar met de break-out groep hier.
- [Apache Software Foundation voting](https://www.apache.org/foundation/voting.html) — lazy consensus met expliciete +1/0/-1 en binding versus non-binding stemmen.
- [Kubernetes KEP](https://github.com/kubernetes/enhancements/tree/master/keps) — Kubernetes Enhancement Proposals, statusveld, sponsoring SIG.
- [Sociocracy 3.0 — Consent Decision Making](https://patterns.sociocracy30.org/patterns/consent-decision-making.html) — consent-based besluitvorming waarin een objection alleen geldt als deze de gezamenlijke doelen of werkbaarheid raakt, niet als persoonlijke voorkeur. Het criterium voor een substantieel bezwaar in §7 is hierop gebaseerd.
