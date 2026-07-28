# TOP-KT-026 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-026 — Uitbreiding: Rol van de naaste |
| Bron-PDF | topics/KTSA-TOP-KT-026 - Uitbreiding_ Rol van de naaste-140726-142804.pdf (Confluence-versie 1.1.1, 7 oktober 2025, status definitief) |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

TOP-KT-028 (Opschoning patiëntgegevens) raakt de naaste op twee punten. Ten eerste telt activiteit van een `RelatedPerson` mee als patiëntbetrokkenheid: de User-Authentication-AuditEvents (TOP-KT-011) met de RelatedPerson op `entity.what` bepalen mede het startmoment van de bewaartermijn van de gekoppelde patiënt (`T_auth`). Ten tweede valt de `RelatedPerson` resource — altijd aan één patiënt gekoppeld — binnen de verwijder-scope: bij de opschoning van de patiënt wordt de RelatedPerson mee-verwijderd. Het topic verwijst nu alleen in de relatietabel summier naar Topic 11 en nergens naar de bewaartermijn-consequenties.

## Wijzigingen

### W1 — Overwegingen › nieuwe subparagraaf "Logging en bewaartermijn" (na "Toegangscontroles")
- **Actie**: toevoegen
- **Voorstel**:

  > **Logging en bewaartermijn**
  >
  > Bij de launch of authenticatie van een naaste legt de Koppeltaalvoorziening een User-Authentication-AuditEvent vast met de `RelatedPerson` als geauthenticeerde gebruiker op `entity.what` (`entity.role` `6` "User"); zie [TOP-KT-011 - Logging en tracing], paragraaf User Authentication. Applicaties hoeven deze events niet zelf aan te maken. Authenticeert een applicatie de naaste buiten de Koppeltaal-authenticatieketen (bijvoorbeeld een eigen sessie-login), dan SHOULD zij daarvoor zelf een Application User Authentication-event vastleggen (TOP-KT-011, subtype `DCM#110126`).
  >
  > Deze events tellen mee in de bewaartermijn van de **gekoppelde patiënt**: [TOP-KT-028 - Opschoning patiëntgegevens] leidt de laatste patiëntbetrokkenheid (`T_auth`) af uit de geslaagde User-Authentication-events met de Patient óf een gekoppelde RelatedPerson (via `RelatedPerson.patient`) op `entity.what`. Activiteit van een naaste stelt de opschoning van de patiënt dus uit.
  >
  > De `RelatedPerson` resource is altijd aan één patiënt gekoppeld en valt daarmee binnen de verwijder-scope van TOP-KT-028: bij de definitieve verwijdering van een patiënt worden de bijbehorende `RelatedPerson` resources mee-verwijderd.
- **Motivatie**: memo Wijzigingen TOPKT011 §3.6–3.7 en TOP-KT-028 ("Betrokkenheidsmodel", scope-tabel: `KT2_RelatedPerson` — "Wordt mee-verwijderd"). Zonder deze paragraaf is niet uit het topic af te leiden dat naasten-activiteit de bewaartermijn van de patiënt beïnvloedt en dat de RelatedPerson mee wordt opgeschoond.

### W2 — "Links naar gerelateerde onderwerpen"
- **Actie**: wijzigen (bestaande TOP-KT-011-rij aanvullen; nieuwe TOP-KT-028-rij toevoegen)
- **Voorstel**: de bestaande rij voor TOP-KT-011 ("De `RelatedPerson` is opgenomen in de logging van de paragraaf User Authentication, Launch en Launched.") aanvullen tot:

  > De `RelatedPerson` is opgenomen in de logging van de paragraaf User Authentication, Launch en Launched. Bij User Authentication staat de RelatedPerson als geauthenticeerde gebruiker op `entity.what` (`entity.role` `6`).

  En de volgende rij toevoegen:

  > | TOP-KT-028 - Opschoning patiëntgegevens | Activiteit van een `RelatedPerson` telt mee in de laatste patiëntbetrokkenheid (`T_auth`) en daarmee in de bewaartermijn van de gekoppelde patiënt. `RelatedPerson` resources vallen binnen de verwijder-scope en worden bij de opschoning van de patiënt mee-verwijderd. |
- **Motivatie**: de relatietabel is de plek waar lezers dwarsverbanden vinden; de bestaande Topic 11-rij dekt de nieuwe attributie (entity.what/entity.role) nog niet en TOP-KT-028 ontbreekt volledig.

### W3 — Versiegeschiedenis
- **Actie**: toevoegen (nieuwe rij bovenaan)
- **Voorstel**: versie 1.2.0, status concept, wijzigingstekst:

  > Paragraaf "Logging en bewaartermijn" toegevoegd: de RelatedPerson staat als geauthenticeerde gebruiker op `entity.what` van het User-Authentication-AuditEvent (TOP-KT-011); RelatedPerson-activiteit telt mee in de laatste patiëntbetrokkenheid (`T_auth`, bewaartermijn van de gekoppelde patiënt) en RelatedPerson resources vallen binnen de verwijder-scope van TOP-KT-028 - Opschoning patiëntgegevens. Relatietabel aangevuld.
- **Motivatie**: consistente versiegeschiedenis; inhoudelijke toevoeging zonder wijziging van de uitbreiding zelf (minor bump t.o.v. 1.1.1).

## Verwijzingen

- [TOP-KT-011 - Logging en tracing], paragraaf User Authentication — `entity.what` = Patient / RelatedPerson / Practitioner, `entity.role` `1` / `6` / `15` (zie ook `topics/updates/TOP-KT-011-update-instructies.md`, W3–W4)
- `input/pagecontent/memo-wijzigingen-topic11.md` §3.6 (RelatedPerson op `entity.what`) en §3.7 (Application User Authentication, SHOULD)
- `topics/TOP-KT-028-opschoning-patientgegevens.md` — "Betrokkenheidsmodel: last-patient-engagement" (Patient of gekoppelde RelatedPerson op `entity.what`) en de scope-tabel onder "Overwegingen › Scope" (`KT2_RelatedPerson`: wordt mee-verwijderd)
- `input/pagecontent/opschoning-patient-data.md` — IG-pagina met hetzelfde betrokkenheidsmodel
- Oude markdown-referentie: `topics/TOP-KT-026-uitbreiding-rol-van-de-naaste.md` (februari 2026; alleen referentie, de PDF is leidend)

## Open punten

1. **Subtype `DCM#110126` (W1, laatste zin eerste alinea)** — afhankelijk van besluit TOP-KT-028 discussiepunt 3: de benaming/keuze van het subtype voor Application User Authentication ("Node Authentication") staat nog niet definitief vast (geen harde SHALL). De rest van W1 steunt op besloten onderdelen.
2. **Volgorde-afhankelijkheid**: de verwijzing naar de paragraaf Application User Authentication veronderstelt dat de Topic 11-update is doorgevoerd; verwerk `TOP-KT-011-update-instructies.md` eerst.
