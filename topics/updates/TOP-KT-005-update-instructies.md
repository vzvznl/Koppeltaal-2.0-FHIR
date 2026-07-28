# TOP-KT-005 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-005 — Toegangsbeheersing |
| Bron-PDF | topics/KTSA-TOP-KT-005 - Toegangsbeheersing-140726-142246.pdf |
| Datum | 2026-07-14 |
| Status | concept |

> **Let op — bronnen.** De PDF-export bevat alleen de hoofdpagina (v1.0.5, 11 mei 2026). Het topic is in Confluence opgesplitst in drie subpagina's: **TOP-KT-005a** (Rollen en rechten voor applicatie-instanties), **TOP-KT-005b** (Rollen Matrix) en **TOP-KT-005c** (Applicatie toegang: SMART on FHIR backend services). De inhoud van TOP-KT-005a is geverifieerd via de Confluence-Word-export van 8 jan 2026 (`TOP-KT-005a+-+Rollen+en+rechten+voor+applicatie-instanties.doc`, repo-root); 005b en 005c waren niet beschikbaar — zie [Open punten](#open-punten).

## Aanleiding

TOP-KT-028 — Opschoning patiëntgegevens introduceert **server-owned opschoon-resources** (de `KT2_DeletePendingTask` en de delete-AuditEvents) die buiten het reguliere CRUD-vlak van de autorisatiematrix vallen: hun `resource-origin` is de Koppeltaalvoorziening, dus de OWN/GRANTED-scopes van deelnemende applicaties geven er van nature geen toegang toe. De toegang wordt geregeld via één server-owned `meta.security`-marker (`kt2-delete-flow`) als **additieve grant bovenop de matrix** — de CRUD-matrix zelf wijzigt niet. Deze uitzondering moet in Topic 05 worden vastgelegd. Daarnaast moeten de eisen worden aangevuld met AuditEvent-logging: de authenticatie-events die de autorisatieketen produceert vormen het bewijsanker (`T_auth`) voor het betrokkenheidsmodel van TOP-KT-028.

## Wijzigingen

### W1 — Hoofdpagina TOP-KT-005, inleidende tekst

- **Actie**: toevoegen (nieuwe alinea ná de bestaande inleiding over rollen, permissies en het access token)
- **Voorstel**:

  > Naast het reguliere rollen- en rechtenmodel kent Koppeltaal één doel-specifieke uitzondering op de autorisatiematrix: de server-owned `meta.security`-marker `kt2-delete-flow`. Deze marker regelt de toegang tot de opschoon-resources van [TOP-KT-028 - Opschoning patiëntgegevens] en werkt als **additieve grant** bovenop de matrix — de CRUD-matrix zelf wijzigt niet. De uitwerking staat in [TOP-KT-005a - Rollen en rechten voor applicatie-instanties].

- **Motivatie**: de hoofdpagina is de ingang van het topic; wie de autorisatiematrix raadpleegt moet weten dat er precies één, doel-specifieke uitzondering bestaat en waar die is uitgewerkt.

### W2 — TOP-KT-005a, "Toepassing en restricties" → nieuwe subsectie (na "Autoriseren", vóór "Search Narrowing")

- **Actie**: toevoegen (nieuwe subsectie "Uitzondering op de autorisatiematrix: de `kt2-delete-flow`-marker")
- **Voorstel**:

  > #### Uitzondering op de autorisatiematrix: de `kt2-delete-flow`-marker
  >
  > Voor het opschoonproces van [TOP-KT-028 - Opschoning patiëntgegevens] maakt de Koppeltaalvoorziening **server-owned resources** aan: per (Patient × deelnemende applicatie) een delete-pending `Task` (`KT2_DeletePendingTask`) en per aggregaat-overgang een delete-`AuditEvent`. Omdat de `resource-origin` van deze resources de Koppeltaalvoorziening is, geven de reguliere OWN/GRANTED-permissies er geen toegang toe. De toegang wordt geregeld via één `meta.security`-marker:
  >
  > `https://koppeltaal.nl/fhir/CodeSystem/security-label` | code `kt2-delete-flow`
  >
  > De marker is een **additieve grant bovenop de autorisatiematrix**: de matrix zelf wijzigt niet, er komt uitsluitend toegang bíj op de gelabelde resources. De marker is doel-specifiek (géén generiek "overschrijf de matrix"-label) en **server-owned**: alleen de Koppeltaalvoorziening zet de marker; een door een applicatie aangeleverde marker MOET worden geweigerd op elke `create`, `PUT`, transactie en `$meta-add`.
  >
  > **Lezen — domein-breed.** Deelnemende applicaties binnen hetzelfde DPA-domein mogen alle met `kt2-delete-flow` gelabelde resources (de delete-pending Tasks én de delete-AuditEvents) lezen. De FHIR resource service MOET deze resources meenemen in de search- én subscription-narrowing — ze worden dus niet weggefilterd, ook niet uit `$count`/paging of notificatie-matching. Een applicatie die gericht alléén de delete-flow-set wil, filtert met een gewone token-search op `_security`. Bij ontbrekend recht filtert de server (lege Bundle) in plaats van een `403` te geven, zodat het bestaan van resources niet lekt.
  >
  > **Schrijven — owner-scoped.** Het enige schrijfrecht dat de marker toevoegt: een `PUT` op de **eigen** delete-pending Task — de Task waarvan `Task.owner` het Device van de geauthenticeerde applicatie-instantie is. Daarbij mag uitsluitend `Task.status` worden gewijzigd, en alleen via de toegestane overgangen: `requested`/`on-hold` → `on-hold` (met een coded `statusReason`) of → `accepted`. Alle overige mutaties blijven `403`: een Task van een andere applicatie, een ander veld, `create` of `delete`. Let op: dit is scoping op `Task.owner` (de aangewezen applicatie), níet op de matrix-`own` (`resource-origin`) — de Koppeltaalvoorziening maakt en bezit de Task.
  >
  > **Servervalidatie (normatief).** De Koppeltaalvoorziening MOET elke statusovergang valideren met optimistic concurrency (`If-Match`/ETag). De statussen `cancelled` en `completed` zijn **server-only**. Een `PUT` die de server-owned velden wijzigt (`owner`, `for`, `requester`, `code`, `restriction.period.end`) of de `kt2-delete-flow`-marker laat vallen, MOET worden geweigerd. Bij het verlaten van `on-hold` wist de server `statusReason`.
  >
  > **Borging.** De FHIR resource service leidt het DPA-domein van de aanroeper af uit de geauthenticeerde Device-registratie en een immutable server-side tenant/partitie — nooit uit een Patient-referentie (die is na de erase weg) of uit client-queryparameters. Doorsijpel-paden worden onafhankelijk geautoriseerd: `_include`/`_revinclude`, contained resources, history, Subscription-delivery en exports. Buiten de KT2-trust-boundary is de marker inert.

- **Motivatie**: dit is de kern van TOP-KT-028 discussiepunt 4 ("marker formeel vastleggen in de autorisatiepagina's"). TOP-KT-005a beschrijft het autorisatiemodel (RBAC, `resource-origin`, search-/subscription-narrowing); de uitzondering hoort op dezelfde plek, in dezelfde begrippen. De tekst volgt de normatieve passages van TOP-KT-028 (Oplossingsrichting, "Toegang buiten de matrix" en "Status-lifecycle & server-validatie") en eisen 5 t/m 9 en 15 daaruit.

### W3 — TOP-KT-005b Rollen Matrix, annotatie onder de matrix

- **Actie**: toevoegen (voetnoot/alinea direct onder de rollen-matrix)
- **Voorstel**:

  > De matrix hierboven wijzigt niet door het opschoonproces van [TOP-KT-028 - Opschoning patiëntgegevens]. De opschoon-resources (delete-pending Tasks en delete-AuditEvents) zijn server-owned; de toegang daartoe loopt via de `kt2-delete-flow`-marker als additieve grant bovenop deze matrix (lezen domein-breed, schrijven uitsluitend de eigen Task-statusovergang). Zie [TOP-KT-005a - Rollen en rechten voor applicatie-instanties], sectie "Uitzondering op de autorisatiematrix".

- **Motivatie**: voorkomt dat lezers van de matrix concluderen dat applicaties de delete-flow-resources niet kunnen zien (of dat er matrix-regels ontbreken). De inhoud van TOP-KT-005b was niet beschikbaar; de exacte plaatsing moet in Confluence worden bepaald — zie [Open punten](#open-punten).

### W4 — Eisen: AuditEvent-logging toevoegen

- **Actie**: toevoegen (nieuwe eisen in de eisen-sectie van het topic; nummering aansluiten op de bestaande eisen — de plaats van de eisen-sectie kon niet uit de PDF worden vastgesteld, zie [Open punten](#open-punten))
- **Voorstel**:

  > | # | Eis |
  > | --- | --- |
  > | E-nieuw-1 | De Koppeltaalvoorziening MOET elke authenticatie binnen het Koppeltaal-domein vastleggen als User Authentication-AuditEvent (`DCM#110114`, subtype `DCM#110122` "Login"), met de geauthenticeerde gebruiker (Patient, RelatedPerson of Practitioner) op `entity.what`, de uitvoerende applicatie als agent en het resultaat in `outcome`. Dit geldt voor de SMART app launch (`/authorize`, inclusief de optionele IdP-stappen) én voor de introspectie van HTI launch tokens. |
  > | E-nieuw-2 | Een applicatie die een patiënt of naaste buiten de Koppeltaal-authenticatieketen authenticeert (bijvoorbeeld een eigen sessie-login), SHOULD dit zelf vastleggen als Application User Authentication-AuditEvent (`DCM#110114`, subtype `DCM#110126`), met de geauthenticeerde gebruiker op `entity.what`. |
  > | E-nieuw-3 | AuditEvents zijn voor applicaties read-only: de FHIR resource service MOET update- en delete-interacties op `AuditEvent` weigeren. Dit is KT2-beleid (geen FHIR-norm). |
  > | E-nieuw-4 | De delete-AuditEvents van het opschoonproces — inclusief het `destroy`-event — MOETEN voor deelnemende applicaties binnen hetzelfde DPA-domein leesbaar en subscribebaar zijn via de `kt2-delete-flow`-marker. |
  > | E-nieuw-5 | De Koppeltaalvoorziening MOET statusovergangen op de delete-pending Task valideren met optimistic concurrency (`If-Match`/ETag): een applicatie mag uitsluitend op haar eigen Task (`Task.owner` = haar Device) de status naar `on-hold` (met coded `statusReason`) of `accepted` zetten; `cancelled` en `completed` MOGEN alleen door de server worden gezet; een `PUT` die de `kt2-delete-flow`-marker laat vallen of andere velden wijzigt MOET worden geweigerd. |

- **Motivatie**: de authenticatie-events (E-nieuw-1/2) zijn het bewijsanker voor `last-patient-engagement` (`T_auth`) in het betrokkenheidsmodel van TOP-KT-028 — zonder normatieve logging-eis op de plek waar de authenticatie is gespecificeerd, is de bewaartermijn-afleiding niet geborgd. E-nieuw-3/4 leggen het toegangsregime op AuditEvents vast (TOP-KT-028 eisen 13 en 16); E-nieuw-5 verankert de servervalidatie van de Task-overgangen (TOP-KT-028 eisen 7 en 8) in het toegangstopic.

## Verwijzingen

- `topics/TOP-KT-028-opschoning-patientgegevens.md` — besloten ontwerp (v0.3, 14 jul 2026); m.n. "Toegang buiten de matrix (`meta.security`)", "Status-lifecycle & server-validatie" en eisen 5–9, 13, 15, 16
- `input/pagecontent/opschoning-patient-data.md` — IG-pagina, uitgangspunten en oplossingsrichting
- `input/pagecontent/memo-wijzigingen-topic11.md` — AuditEvent-specificaties: §3.6 (User Authentication), §3.7 (Application User Authentication), §3.8 (opschoning-lifecycle)
- `TOP-KT-005a+-+Rollen+en+rechten+voor+applicatie-instanties.doc` (repo-root) — Confluence-export TOP-KT-005a, 8 jan 2026

## Open punten

1. **Subpagina's 005b en 005c niet beschikbaar.** De bron-PDF bevat alleen de hoofdpagina; van TOP-KT-005b (Rollen Matrix) en TOP-KT-005c (SMART on FHIR backend services) was geen actuele export beschikbaar. De plaatsing van W3 (waar precies onder de matrix) en van W4 (waar de eisen-sectie nu leeft — de versiegeschiedenis noemt "Eisen 004 en 005", vermoedelijk in 005c) moet in Confluence worden geverifieerd; de eis-nummering "E-nieuw-N" is een placeholder.
2. **Afhankelijk van besluit TOP-KT-028 discussiepunt 4**: de exacte code en het CodeSystem van de marker (`https://koppeltaal.nl/fhir/CodeSystem/security-label#kt2-delete-flow` is het werkvoorstel), de bevestiging dat AuditEvent-read-only KT2-beleid is, en de borging-details (server-owned marker; DPA-domein uit de Device-registratie; onafhankelijke autorisatie van doorsijpel-paden). W1, W2, W3 en E-nieuw-3/4/5 hangen hiervan af.
3. **Afhankelijk van besluit TOP-KT-028 discussiepunt 3**: het subtype `DCM#110126` ("Node Authentication") voor authenticatie aan applicatiezijde — nog geen harde SHALL. E-nieuw-2 hangt hiervan af.
4. **Afhankelijk van besluit TOP-KT-028 discussiepunt 5**: wie "deelnemende applicaties" zijn (automatisch elke app in het domein, of expliciete opt-in) bepaalt de reikwijdte van de domein-brede lees-grant in W2 en E-nieuw-4.
5. **Afhankelijk van besluit TOP-KT-028 discussiepunt 1**: de domein-brede leesbaarheid kan in een v2 worden versmald (footprint-based, AVG art. 19); de formulering "domein-breed" in W2/W3 zou dan wijzigen.
