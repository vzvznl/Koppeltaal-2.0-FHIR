# TOP-KT-009 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-009 — Overzicht gebruikte FHIR Resources |
| Bron-PDF | topics/KTSA-TOP-KT-009 - Overzicht gebruikte FHIR Resources-140726-142449.pdf |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

TOP-KT-028 (Opschoning patiëntgegevens) introduceert een nieuwe StructureDefinition — het profiel `KT2_DeletePendingTask` (aankondigings-Task van het verwijderproces) — plus twee nieuwe SearchParameters (`auditevent-entity` en `task-owner`) voor de activiteitscheck. TOP-KT-009 is het overzicht van alle gebruikte FHIR resources en profielen en moet deze artefacten vermelden. Let op: de artefacten zijn een **eerste voorstel** en zijn nog niet gemerged of gepubliceerd (zie Open punten); de vermelding moet die status expliciet dragen.

## Wijzigingen

### W1 — Koppeltaal optionele uitbreidingen profiel (tabel)

- **Actie**: toevoegen (rij in de tabel met kolommen Topic / Profiel / Omschrijving / User stories / Simplifier)
- **Voorstel**: onderstaande rij letterlijk overnemen:

> | Topic | Profiel | Omschrijving | User stories | Simplifier |
> | --- | --- | --- | --- | --- |
> | TOP-KT-028 - Opschoning patiëntgegevens | `Task` (`KT2_DeletePendingTask`) | Het (FHIR) **KT2_DeletePendingTask**-profiel representeert de aankondiging dat de gegevens van een patiënt gepland staan voor definitieve verwijdering. De Koppeltaalvoorziening maakt per combinatie van patiënt en deelnemende applicatie één Task aan. Het is een **eigen profiel met `Parent: Task`** — bewust niet afgeleid van `KT2_Task`, omdat dat profiel `owner` aan mens-actoren bindt en `restriction`/`statusReason` verbiedt, terwijl de aankondigings-Task die juist nodig heeft. Vaste vorm: `code = delete-pending`, `intent = order`, `for` 1..1 → `KT2_Patient`, `owner` 1..1 → `KT2_Device` (de doelapplicatie), `requester` 1..1 → `KT2_Device` (de Koppeltaalvoorziening), `restriction.period.end` 1..1 (grace-deadline, server-beheerd), `statusReason` toegestaan (coded noodrem-reden bij `on-hold`). **Status: eerste voorstel — nog niet gemerged of gepubliceerd** (zie TOP-KT-028). | • De Koppeltaalvoorziening kondigt een voorgenomen verwijdering aan met een Task per (patiënt × applicatie) • De applicatie leest haar aankondigings-Task en zet de noodrem (`on-hold` met `statusReason`) • De applicatie geeft groen licht (`accepted`) • De applicatie ontvangt de bevestiging van de verwijdering via de `destroy`-AuditEvent | nog niet gepubliceerd |

- **Motivatie**: TOP-KT-009 kent twee profieltabellen; de tabel "Koppeltaal optionele uitbreidingen profiel" heeft een Topic-kolom en is de plek voor per-topic toevoegingen (vgl. de RelatedPerson-rij voor TOP-KT-026). De constraints komen uit TOP-KT-028 ("Coördinatie via Task" en "Apart profiel (`Parent: Task`), naast `KT2_Task`") en het FSH-voorstel `input/fsh/profiles/KT2_DeletePendingTask.fsh` op de feature branch. De statusvermelding voorkomt dat lezers het profiel op Simplifier zoeken.

### W2 — Overwegingen › Rol owner

- **Actie**: wijzigen (alinea toevoegen aan de bestaande sectie)
- **Voorstel**: onderstaande alinea letterlijk toevoegen aan het einde van de sectie:

> Uitzondering hierop is de aankondigings-Task van het opschoningsproces (`KT2_DeletePendingTask`, zie TOP-KT-028 - Opschoning patiëntgegevens): daar is de `owner` altijd een `Device` — de doelapplicatie die op de aankondiging moet reageren. Dit is een bewuste keuze: een `Patient` of `RelatedPerson` als owner zou als patiëntbetrokkenheid meetellen en de bewaartermijn-klok resetten.

- **Motivatie**: de sectie "Rol owner" stelt nu dat de owner van een Task één van vier entiteiten moet zijn (Patient, Practitioner, RelatedPerson, CareTeam). De delete-pending Task wijkt daarvan af (`owner` = Device); zonder deze aanvulling spreekt het topic het nieuwe profiel tegen. De motivering (retentieklok) komt uit TOP-KT-028, elemententabel bij "Coördinatie via Task".

### W3 — Koppeltaal profielen — nieuwe subsectie "SearchParameters (in voorbereiding)"

- **Actie**: toevoegen (subsectie aan het einde van het onderdeel "Koppeltaal profielen")
- **Voorstel**: onderstaande tekst letterlijk overnemen:

> **SearchParameters (in voorbereiding)**
>
> Ten behoeve van het opschoningsproces (TOP-KT-028 - Opschoning patiëntgegevens) zijn twee nieuwe Koppeltaal SearchParameters in voorbereiding:
>
> | SearchParameter | Basis | Expressie | Doel |
> | --- | --- | --- | --- |
> | `auditevent-entity` (`entity`) | `AuditEvent` | `AuditEvent.entity.what` | Vinden van de meest recente User Authentication-AuditEvent van een Patient of gekoppelde RelatedPerson (`T_auth`, de activiteitscheck) |
> | `task-owner` (`owner`) | `Task` | `Task.owner` | Vinden van de meest recente Task waarvan een Patient of gekoppelde RelatedPerson de uitvoerder is (`T_task_owner`); de aankondigings-Task zelf (`owner` = Device) valt hier buiten en beïnvloedt de bewaartermijn-klok dus niet |
>
> Beide parameters ondersteunen chaining op `patient` (bijvoorbeeld `owner:RelatedPerson.patient`). Status: in voorbereiding — onderdeel van hetzelfde voorstel als `KT2_DeletePendingTask`, nog niet gemerged of gepubliceerd.

- **Motivatie**: de instructie vraagt de bijbehorende SearchParameters als "in voorbereiding" te vermelden. De definities komen uit `input/fsh/searchparameters/auditevent-entity.fsh` en `task-owner.fsh` op de feature branch; het betrokkenheidsmodel (`T_auth`, `T_task_owner`) staat in TOP-KT-028. TOP-KT-009 noemt nu nergens SearchParameters; een aparte, expliciet als voorlopig gemarkeerde subsectie houdt de status zuiver.

## Verwijzingen

- TOP-KT-028 — Opschoning patiëntgegevens (repo: `topics/TOP-KT-028-opschoning-patientgegevens.md`), m.n. "Coördinatie via Task (`KT2_DeletePendingTask`)" en "Betrokkenheidsmodel: `last-patient-engagement`".
- IG-pagina "Opschoning Patient-data" (`input/pagecontent/opschoning-patient-data.md`).
- FSH-voorstel op feature branch `feature/opschoning-patient-data-fsh` (PR #67): `input/fsh/profiles/KT2_DeletePendingTask.fsh`, `input/fsh/searchparameters/auditevent-entity.fsh`, `input/fsh/searchparameters/task-owner.fsh`.

## Open punten

- **Status PR #67**: de PR (feat: opschoning patiëntdata — KT2DeletePendingTask en opt-in) is inmiddels **gesloten zonder merge**; het profiel en de SearchParameters bestaan alleen op de feature branch en zijn niet gepubliceerd (geen Simplifier-vermelding). Herindiening wordt verwacht nu het herontwerp in TOP-KT-028 is vastgesteld; de exacte profielinhoud kan daarbij nog wijzigen. De Confluence-tekst moet daarom de status "eerste voorstel, nog niet gemerged of gepubliceerd" dragen totdat een nieuwe PR is gemerged én gepubliceerd — daarna de Simplifier-link toevoegen en de statusvermelding verwijderen.
- **Terminologie in het FSH-voorstel**: de profielbeschrijving op de feature branch spreekt nog van "`$purge`", terwijl het besloten ontwerp de verwijdering server-agnostisch beschrijft (interne harde erase). Bij herindiening van de FSH moet die beschrijving worden bijgewerkt; de voorsteltekst in W1 volgt al de besloten terminologie.
- **Plaatsing fundament vs. optionele uitbreiding** — *afhankelijk van besluit TOP-KT-028 discussiepunt 3* (deelname/opt-in): als elke applicatie in het domein verplicht deelneemt, past de rij uit W1 wellicht beter in de tabel "Koppeltaal fundament functionele profielen". *Voorlopig besloten (19 aug 2026): deelname is automatisch voor elke app in het domein — plaatsing in de fundament-tabel ligt daarmee voor de hand.*
- **Datamodel-diagram**: het overzichtsdiagram onder "Overwegingen" toont de owner-relaties van Task; bij een volgende revisie van het diagram de Device-owner van de delete-pending Task meenemen (niet blokkerend voor deze tekstuele update).
