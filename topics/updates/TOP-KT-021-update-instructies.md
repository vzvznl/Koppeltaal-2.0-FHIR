# TOP-KT-021 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-021 — Token Introspection |
| Bron-PDF | topics/KTSA-TOP-KT-021 - Token Introspection-140726-142714.pdf (Confluence-versie 1.0.1, 26 juni 2023, status definitief) |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

Het topic beschrijft het token-introspection-endpoint voor drie tokentypes (HTI launch tokens, `access_token`, `id_token`), maar zegt niets over logging. Sinds de Topic 11-uitbreiding is de introspectie van een HTI launch token hét vastleggingsmoment van patiëntbetrokkenheid in de HTI-flow: de Koppeltaalvoorziening legt er een User-Authentication-AuditEvent bij vast, dat in TOP-KT-028 (Opschoning patiëntgegevens) meetelt in de bewaartermijn-afleiding (`T_auth`). Het onderscheid tussen de tokentypes (wél/geen AuditEvent) moet in dit topic worden benoemd.

## Wijzigingen

### W1 — "Beschrijving"
- **Actie**: toevoegen (alinea direct na de opsomming van de drie tokentypes)
- **Voorstel**:

  > De introspectie van deze tokentypes verschilt in logging. Uitsluitend de introspectie van een **HTI launch token** wordt door de Koppeltaalvoorziening vastgelegd als een User-Authentication-AuditEvent (type `DCM#110114`, subtype `DCM#110122`, prefix `introspect` in `outcomeDesc`), met de gebruiker uit het token (`Patient` / `RelatedPerson` / `Practitioner`) op `entity.what`. De introspectie van een `access_token` of `id_token` is een louter technische validatie en levert **géén** AuditEvent op. Zie [TOP-KT-011 - Logging en tracing], paragraaf User Authentication.
- **Motivatie**: memo Wijzigingen TOPKT011 §3.6; de Beschrijving somt de drie tokentypes op en is daarmee de plek waar het logging-onderscheid tussen die types thuishoort.

### W2 — "Toepassing, restricties en eisen" › "Het uitvoeren van de token introspection in stappen"
- **Actie**: toevoegen (alinea aan het slot, na "Na het succesvol valideren van het token wordt de inhoud van de body teruggestuurd …")
- **Voorstel**:

  > Bij een succesvolle introspectie van een HTI launch token legt de autorisatieservice daarnaast het bijbehorende User-Authentication-AuditEvent vast; de aanroepende applicatie hoeft hiervoor niets te doen. Dit event geldt binnen [TOP-KT-028 - Opschoning patiëntgegevens] als **patiëntbetrokkenheid** (`T_auth`): een geslaagde introspectie van een launch token van een Patient of een gekoppelde RelatedPerson start de bewaartermijn van de patiëntgegevens opnieuw. Voor de introspectie van een `access_token` of `id_token` wordt geen AuditEvent vastgelegd; die telt dus ook niet als betrokkenheid.
- **Motivatie**: verankert in de stapbeschrijving dat het event automatisch (server-side) ontstaat en welke betekenis het heeft voor de bewaartermijn — het enige gedragseffect van dit topic op TOP-KT-028.

### W3 — "Links naar gerelateerde onderwerpen"
- **Actie**: wijzigen (de sectie is nu leeg; tabel opnemen)
- **Voorstel**:

  > | Topic | Beschrijving van relatie met dit onderwerp |
  > | --- | --- |
  > | TOP-KT-011 - Logging en tracing | De introspectie van een HTI launch token wordt vastgelegd als User-Authentication-AuditEvent (paragraaf User Authentication, variant `introspect`); introspectie van access- en id-tokens wordt niet gelogd. |
  > | TOP-KT-028 - Opschoning patiëntgegevens | Het User-Authentication-AuditEvent van de HTI-introspectie telt mee als patiëntbetrokkenheid (`T_auth`) en bepaalt daarmee het startmoment van de bewaartermijn. |
- **Motivatie**: de sectie bestaat al maar is leeg (`{}`); andere topics gebruiken hier een relatietabel — zelfde vorm aanhouden.

### W4 — Versiegeschiedenis
- **Actie**: toevoegen (nieuwe rij bovenaan)
- **Voorstel**: versie 1.1.0, status concept, wijzigingstekst:

  > Logging van de introspectie toegevoegd: uitsluitend de introspectie van een HTI launch token levert een User-Authentication-AuditEvent op (`DCM#110114`/`DCM#110122`, prefix `introspect`; zie TOP-KT-011); introspectie van access- en id-tokens is technische validatie zonder AuditEvent. Het HTI-event telt als patiëntbetrokkenheid (`T_auth`) in TOP-KT-028 - Opschoning patiëntgegevens.
- **Motivatie**: consistente versiegeschiedenis; eerste inhoudelijke wijziging sinds 1.0.1 (2023), functionele toevoeging (minor bump).

## Verwijzingen

- [TOP-KT-011 - Logging en tracing], paragraaf User Authentication — specificatie van de `introspect`-variant (zie ook `topics/updates/TOP-KT-011-update-instructies.md`, W3)
- `input/pagecontent/memo-wijzigingen-topic11.md` §3.6 — "Het `introspect`-event wordt alleen vastgelegd voor HTI launch tokens; introspectie van access- of id-tokens is een technische validatie en levert géén AuditEvent op."
- `topics/TOP-KT-028-opschoning-patientgegevens.md` — "Betrokkenheidsmodel: last-patient-engagement" (`T_auth` dekt `/authorize` én HTI-tokenintrospectie, query-equivalent)
- Oude markdown-referentie: `topics/TOP-KT-021-token-introspection.md` (februari 2026; alleen referentie, de PDF is leidend)

## Open punten

1. **Volgorde-afhankelijkheid**: de verwijzingen veronderstellen dat de Topic 11-update (paragraaf User Authentication met de variant-prefixen) is doorgevoerd; verwerk `TOP-KT-011-update-instructies.md` eerst.
2. Geen afhankelijkheden van de openstaande TOP-KT-028-discussiepunten: de `introspect`-variant valt onder subtype `DCM#110122` (vastgesteld); discussiepunt 3 (subtype `DCM#110126`) raakt dit topic niet.
