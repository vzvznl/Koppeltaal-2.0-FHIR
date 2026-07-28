# Briefing — update-instructies topics t.b.v. TOP-KT-028 (Opschoning patiëntgegevens)

Het nieuwe **TOP-KT-028 "Opschoning patiëntgegevens"** (voorheen "Archivering") introduceert een gecontroleerd verwijderproces voor patiëntdata. Elf bestaande topics moeten daarop worden bijgewerkt. Dit document is de gedeelde context voor het opstellen van **update-instructies per topic**.

## Werkwijze

- Output per topic: één bestand `topics/updates/TOP-KT-XXX-update-instructies.md` volgens het sjabloon onderaan.
- Taal: **Nederlands**.
- De nieuwe PDF (`topics/KTSA-TOP-KT-XXX …-140726-*.pdf`) is de **actuele Confluence-inhoud** van het topic; lees die met de Read-tool (parameter `pages`, max. 20 pagina's per aanroep — begin met de inhoudsopgave en lees gericht). De `TOP-KT-XXX-*.md`-bestanden in `topics/` dateren van februari 2026 en zijn alleen referentie.
- **Geen git-commando's** (niet stagen, niet committen); de hoofdsessie verzorgt git.
- Wijzig geen bestaande bestanden; schrijf alleen nieuwe bestanden onder `topics/updates/`.

## Ankerdocumenten (het ontwerp)

1. `topics/TOP-KT-028-opschoning-patientgegevens.md` — besluitvormingsdocument: ontwerp, rollen, scope, discussiepunten
2. `input/pagecontent/opschoning-patient-data.md` — IG-pagina: uitgangspunten en oplossingsrichting
3. `input/pagecontent/memo-wijzigingen-topic11.md` — AuditEvent-specificaties (§3.6 t/m §3.9)

## Het ontwerp in het kort

- **Aankondigings-Task `KT2_DeletePendingTask`** (eigen profiel, `Parent: Task` — bewust géén KT2_Task): `code = delete-pending`, `intent = order`, `for` = Patient, `owner` = Device (de deelnemende app), `requester` = Device (Koppeltaalvoorziening), `restriction.period.end` = grace-deadline, `statusReason` = noodrem-reden. Eén Task per (Patient × app).
- **Lifecycle**: `requested` (KV, create) → app schrijft `on-hold` (noodrem, met `statusReason`) of `accepted` (groen licht) → KV zet `cancelled` (hernieuwde betrokkenheid; Task blijft behouden) of `completed` (erase; Task verdwijnt mee). `cancelled`/`completed` zijn server-only.
- **Grace period**: 10 dagen (vast; SHOULD, onderbouwd afwijken MAY). Noodrem-time-out voorlopig oneindig, wel een grace-reset-mechanisme. Vervroegde voltooiing zodra álle Tasks `accepted`.
- **Verwijderpad**: *graceful* (aankondiging + grace + noodrem) of *fast-track* (geen recente activiteit → directe erase, alleen destroy-AuditEvent). Activiteitscheck vlak vóór de erase.
- **Betrokkenheidsmodel**: `last-patient-engagement = max(T_auth, T_task_owner)`; wordt afgeleid via queries, niet als state opgeslagen. `T_auth` = meest recente User-Authentication-AuditEvent (`DCM#110114`/`DCM#110122`) met de geauthenticeerde gebruiker (Patient of gekoppelde RelatedPerson) op `entity.what`; dekt `/authorize` én HTI-tokenintrospectie (query-equivalent). `T_task_owner` = meest recente Task met `Task.owner` = Patient/RelatedPerson. Practitioner-activiteit telt niet mee.
- **Opschoning-AuditEvents**: ISO 21089-lifecycle-codes op `AuditEvent.type`: `archive` (aangekondigd), `hold` (noodrem), `unhold` (opgeheven), `reactivate` (afgebroken), `destroy` (uitgevoerd; draagt het **post-delete-signaal**). Geen PII, alleen pseudonieme technische referenties; overleven de erase (bewaartermijn ≥ 5 jaar vs. max. 2 jaar PII).
- **Autorisatie**: server-owned `meta.security`-marker **`kt2-delete-flow`** als *additieve grant* bovenop de bestaande autorisatiematrix (de CRUD-matrix wijzigt niet). Een app schrijft uitsluitend op haar **eigen** Task en alleen `status` → `on-hold`/`accepted`; servervalidatie van de overgangen (If-Match/ETag) is normatief.
- **Subscription-delivery-failures**: verzendpogingen worden gelogd; bij herhaald falen gaat de `Subscription` op `status=error` en loopt de lifecycle **door**; alerting op failures is de verantwoordelijkheid van de leverancier (een dode webhook = geen noodrem meer).
- **Terminologie**: het topic heet nu **"Opschoning patiëntgegevens"**; de PDF-export heet nog "Archivering". Gebruik in instructies de nieuwe titel. Er bestaat géén archief-/read-only-tussentoestand meer.
- **Status**: TOP-KT-028 is een besluitvormingsdocument. Sommige punten zijn nog open (o.a. exacte code/CodeSystem van de marker, subtype `110126`, opt-in-/Subscription-provisioning). Markeer instructies die daarvan afhangen expliciet als *"afhankelijk van besluit TOP-KT-028 discussiepunt N"*.

## Sjabloon per topic

```markdown
# TOP-KT-XXX — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-XXX — <Confluence-titel> |
| Bron-PDF | topics/KTSA-TOP-KT-XXX …-140726-*.pdf |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding
<1–3 zinnen: waarom raakt TOP-KT-028 dit topic>

## Wijzigingen
<per bestaande sectie van het topic; nummer W1, W2, …>

### W1 — <sectie/kop in het topic>
- **Actie**: toevoegen / wijzigen
- **Voorstel**: <concrete voorsteltekst (NL), klaar om over te nemen>
- **Motivatie**: <korte onderbouwing vanuit het ontwerp>

## Verwijzingen
<naar TOP-KT-028, memo Topic 11 (§…), IG-pagina's>

## Open punten
<afhankelijkheden van openstaande besluiten in TOP-KT-028>
```
