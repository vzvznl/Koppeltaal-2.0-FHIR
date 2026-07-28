# TOP-KT-007 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-007 — Koppeltaal Launch |
| Bron-PDF | topics/KTSA-TOP-KT-007 - Koppeltaal Launch-140726-142354.pdf (Confluence-versie 2.0.7, 19 januari 2026, status definitief) |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

De launch is het moment waarop patiëntbetrokkenheid ontstaat. TOP-KT-028 (Opschoning patiëntgegevens) leidt de bewaartermijn van patiëntgegevens af uit de User-Authentication-AuditEvents die de Koppeltaalvoorziening tijdens de launch vastlegt (TOP-KT-011, paragraaf User Authentication). Dit topic beschrijft de launch-flows, maar verwijst nog nergens naar die logging; leveranciers kunnen er nu niet uit opmaken dat de login-events automatisch ontstaan en dat zij daar niets voor hoeven te doen.

## Wijzigingen

### W1 — Beschrijving › "De launch in het kort"
- **Actie**: toevoegen (slotalinea van de subparagraaf)
- **Voorstel**:

  > Bij beide varianten legt de Koppeltaalvoorziening de bijbehorende login-AuditEvents vast: bij een launch via HTI op het moment van de (impliciete) introspectie van het HTI launch token, bij een SMART on FHIR app launch bij de `/authorize`-call. Applicaties hoeven deze events **niet zelf aan te maken**; zie [TOP-KT-011 - Logging en tracing], paragraaf User Authentication. Deze events vormen het **bewijsanker voor patiëntbetrokkenheid**: de bewaartermijn van patiëntgegevens wordt ervan afgeleid (zie [TOP-KT-028 - Opschoning patiëntgegevens]).
- **Motivatie**: "De launch in het kort" introduceert beide flows; dit is de natuurlijke plek om de logging-consequentie van de flowkeuze (introspect- versus authorize-event) te benoemen.

### W2 — "De HTI flow voor applicaties die geen persoons en/of medische gegevens verwerken"
- **Actie**: toevoegen (extra bullet, direct na de stap waarin de authorization service het token valideert)
- **Voorstel**:

  > - De autorisatieservice legt bij de introspectie van het HTI launch token een User-Authentication-AuditEvent vast (`DCM#110114` / `DCM#110122`, prefix `introspect` in `outcomeDesc`), met de gebruiker uit het token op `entity.what`. De module hoeft hiervoor niets te doen; zie [TOP-KT-011 - Logging en tracing].
- **Motivatie**: maakt in de stapbeschrijving zelf zichtbaar dat de introspectie het vastleggingsmoment is — het enige login-event dat in de HTI-only-flow ontstaat.

### W3 — "De SMART on FHIR app launch flow voor applicaties die persoons en/of medische gegevens verwerken"
- **Actie**: toevoegen (extra bullet, direct na "De autorisatie service identificeert de gebruiker volgens de SSO implementatie van het domein.")
- **Voorstel**:

  > - De autorisatieservice legt deze stappen vast als User-Authentication-AuditEvents (`DCM#110114` / `DCM#110122`): de `/authorize`-call met prefix `authorize` en — indien een externe IdP wordt gebruikt — de IdP-stappen met prefix `idp call` respectievelijk `idp login` (het IdP-besluit: `outcome` `0` geslaagd / `8` geweigerd, met de IdP op `agent.who(2)`). De module hoeft hiervoor niets te doen; zie [TOP-KT-011 - Logging en tracing].
- **Motivatie**: legt per flow-stap vast welk event ontstaat, consistent met W2, zodat de prefix-systematiek van Topic 11 herkenbaar terugkomt in de launch-beschrijving.

### W4 — "De restricties en eisen" › nieuwe subparagraaf "Logging van de launch" (na "Token introspection", vóór "RelatedPerson")
- **Actie**: toevoegen
- **Voorstel**:

  > **Logging van de launch**
  >
  > - De Koppeltaalvoorziening legt de User-Authentication-AuditEvents van de launch vast (varianten `introspect`, `authorize`, `idp call` en `idp login`; zie [TOP-KT-011 - Logging en tracing], paragraaf User Authentication). Applicaties hoeven deze events niet zelf aan te maken. De bestaande verantwoordelijkheid van de applicatie voor de Launch- en Launched-AuditEvents (TOP-KT-011) blijft ongewijzigd.
  > - Deze events gelden binnen [TOP-KT-028 - Opschoning patiëntgegevens] als bewijsanker voor patiëntbetrokkenheid (`T_auth`): een geslaagde launch door een Patient of een gekoppelde RelatedPerson start de bewaartermijn van de patiëntgegevens opnieuw. Alleen de introspectie van een **HTI launch token** levert zo'n event op; introspectie van access- of id-tokens niet (zie [TOP-KT-021 - Token Introspection]).
- **Motivatie**: de restricties-en-eisen-sectie is waar leveranciers hun verplichtingen aflezen; hier hoort de expliciete afbakening thuis (login-events: Koppeltaalvoorziening; Launch/Launched: applicatie) plus de betekenis voor de bewaartermijn.

### W5 — Versiegeschiedenis
- **Actie**: toevoegen (nieuwe rij bovenaan)
- **Voorstel**: versie 2.0.8, status concept, wijzigingstekst:

  > Verwijzing naar de vernieuwde logging in TOP-KT-011 toegevoegd: de Koppeltaalvoorziening legt de login-AuditEvents vast bij de introspectie van het HTI launch token en bij de `/authorize`-call (inclusief IdP-stappen); applicaties hoeven deze niet zelf aan te maken. Deze events zijn het bewijsanker voor patiëntbetrokkenheid en daarmee voor de bewaartermijn (TOP-KT-028 - Opschoning patiëntgegevens).
- **Motivatie**: consistente versiegeschiedenis; tekstuele toevoeging zonder wijziging van de launch-flow zelf (micro bump t.o.v. 2.0.7).

## Verwijzingen

- [TOP-KT-011 - Logging en tracing], paragraaf User Authentication — de specificatie van de vier login-varianten (zie ook `topics/updates/TOP-KT-011-update-instructies.md`, W3)
- `input/pagecontent/memo-wijzigingen-topic11.md` §3.6 — de variant-tabel (prefixen `introspect`/`authorize`/`idp call`/`idp login`)
- `topics/TOP-KT-028-opschoning-patientgegevens.md` — "Betrokkenheidsmodel: last-patient-engagement" (`T_auth`)
- `input/pagecontent/opschoning-patient-data.md` — IG-pagina met hetzelfde betrokkenheidsmodel
- Oude markdown-referentie: `topics/kop-kt-007-koppeltaal-launch.md` (februari 2026; alleen referentie, de PDF is leidend)

## Open punten

1. **Volgorde-afhankelijkheid**: deze wijzigingen verwijzen naar paragrafen die pas met de Topic 11-update (zie `TOP-KT-011-update-instructies.md`, W3) in Confluence bestaan; verwerk Topic 11 eerst, of neem de verwijzingen alvast op met een noot dat de doelparagraaf in voorbereiding is.
2. Geen inhoudelijke afhankelijkheden van de openstaande TOP-KT-028-discussiepunten: de hier voorgestelde teksten steunen uitsluitend op de besloten onderdelen (User-Authentication-events en `T_auth`).
