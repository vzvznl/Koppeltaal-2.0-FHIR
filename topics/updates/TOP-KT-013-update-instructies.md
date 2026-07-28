# TOP-KT-013 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-013 — Levenscyclus van een FHIR Resource |
| Bron-PDF | topics/KTSA-TOP-KT-013 - Levenscyclus van een FHIR Resource-140726-142621.pdf |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

TOP-KT-013 beschrijft de levenscyclus van FHIR resources binnen Koppeltaal en stelt dat resources "in normaal gebruik nooit echt verwijderd" worden (soft-deletes via `status`/`active`). Met TOP-KT-028 (Opschoning patiëntgegevens) krijgt de levenscyclus een gedefinieerd einde: een gecontroleerde, definitieve verwijdering op patiëntniveau. Het topic moet beschrijven welke resources daarbij verwijderd worden, dat `AuditEvent` daarvan is uitgezonderd, en hoe de erase-semantiek zich verhoudt tot de reguliere FHIR `DELETE` en de bestaande "Hard Delete"-passage.

## Wijzigingen

### W1 — Beschrijving

- **Actie**: wijzigen (nuancering van de bestaande tekst)
- **Voorstel**: vul de passage over soft-deletes ("resources worden in normaal gebruik nooit echt verwijderd, maar door middel van status worden ze op inactief gezet") aan met de volgende zin:

> Uitzondering hierop is het opschoningsproces van TOP-KT-028 - Opschoning patiëntgegevens: na het verstrijken van de bewaartermijn worden de aan een patiënt gebonden resources definitief verwijderd. De levenscyclus van deze resources kent daarmee een gedefinieerd einde.

- **Motivatie**: de absolute formulering ("nooit echt verwijderd") is met TOP-KT-028 niet langer juist; de nuancering verwijst direct naar het nieuwe proces zonder de soft-delete-systematiek voor het normale gebruik te wijzigen.

### W2 — Overwegingen › Soft en Hard Delete

- **Actie**: wijzigen (laatste zin van de sectie vervangen)
- **Voorstel**: vervang de zin "Hoewel nog niet duidelijk is om welke situaties het exact gaat, voorzien we dat er in de toekomst gebruik gemaakt gaat worden van deze functionaliteit." door:

> Eén van die situaties is inmiddels uitgewerkt: de opschoning van patiëntgegevens na het verstrijken van de bewaartermijn (en de verwijdering of retournering van gegevens bij contractbeëindiging). Zie TOP-KT-028 - Opschoning patiëntgegevens voor het volledige proces; de paragraaf "Definitieve verwijdering (opschoning)" hieronder beschrijft de gevolgen voor de levenscyclus.

- **Motivatie**: de bestaande tekst kondigt toekomstig gebruik van verwijderen aan zonder invulling; TOP-KT-028 geeft die invulling nu concreet. De verwijzing houdt TOP-KT-013 beknopt.

### W3 — Nieuwe subsectie onder "Toepassing, restricties en eisen", na "Overige statussen van een task": "Definitieve verwijdering (opschoning): einde van de levenscyclus op patiëntniveau"

- **Actie**: toevoegen (nieuwe subsectie)
- **Voorstel**: onderstaande tekst letterlijk overnemen:

> **Definitieve verwijdering (opschoning): einde van de levenscyclus op patiëntniveau**
>
> Bij de opschoning van patiëntgegevens (TOP-KT-028 - Opschoning patiëntgegevens) eindigt de levenscyclus van de aan een patiënt gebonden resources definitief. Omdat FHIR resources referentieel verbonden zijn, vindt de verwijdering plaats op patiëntniveau — alle aan de patiënt gebonden resources als geheel:
>
> | Resource | Binding aan de patiënt | Positie in de opschoning |
> | --- | --- | --- |
> | `Patient` | het anker zelf | Wordt verwijderd (Patient Compartment) |
> | `RelatedPerson` | `RelatedPerson.patient` (altijd één patiënt) | Wordt mee-verwijderd |
> | `CareTeam` | `CareTeam.subject` | Wordt mee-verwijderd |
> | `Task` | `Task.for` | Wordt mee-verwijderd; `Task` valt buiten het Patient Compartment en wordt apart meegenomen, inclusief de delete-pending-Tasks van het opschoningsproces zelf en de historische Tasks met status `cancelled` |
> | `AuditEvent` | pseudonieme referentie op `entity.what` | **Uitgezonderd**: blijft als centraal NEN 7513-record behouden en mag de verwijderde `Patient/{id}` blijven refereren |
>
> De erase is **definitief en server-agnostisch**: alle versies van de resources worden gewist, een latere `GET` geeft `404` en een `vread` is onmogelijk. Er is géén tombstone, géén archief- of read-only-tussentoestand en geen mogelijkheid om via de history alsnog gegevens terug te lezen. Hoe een server de erase technisch uitvoert, is een implementatiedetail. De `destroy`-AuditEvent is de gezaghebbende, blijvende bevestiging van de uitgevoerde verwijdering.
>
> Tijdens een lopende opschoningscyclus blijft een Task met status `cancelled` juist behouden: die onderscheidt een afgebroken verwijdering (hernieuwde betrokkenheid; de patiënt bestaat nog) van een uitgevoerde verwijdering (`GET` → `404`). Pas bij een latere, daadwerkelijk uitgevoerde erase wordt ook deze Task mee-verwijderd.

- **Motivatie**: dit is de kern van de instructie: de lifecycle-uitbreiding voor de te verwijderen resources, met de scope-tabel uit TOP-KT-028 ("Scope" en "Definitieve verwijdering") en de expliciete uitzondering voor `AuditEvent` (NEN 7513, bewaartermijn ≥ 5 jaar vs. max. 2 jaar PII). De erase-semantiek (404, geen tombstone, geen archief-tussentoestand) komt letterlijk uit het besloten ontwerp.

### W4 — Hard Delete

- **Actie**: wijzigen (alinea toevoegen aan het einde van de sectie, vóór het kader "Recht op vergetelheid"; het kader aanpassen)
- **Voorstel**: voeg onderstaande alinea toe:

> De hierboven beschreven FHIR `DELETE` is een *logische* verwijdering: de history blijft bestaan en een latere `GET` geeft `410 Gone` met een verwijzing naar de laatste versie. De definitieve verwijdering van het opschoningsproces (TOP-KT-028 - Opschoning patiëntgegevens) is nadrukkelijk **geen** reguliere FHIR `DELETE`: daar worden álle versies gewist, geeft een latere `GET` een `404` (de id is daarna onbekend) en is er geen history om op terug te vallen.

> En pas het kader "Recht op vergetelheid" als volgt aan: vervang de twee alinea's over `$expunge` ("Voor het fysiek verwijderen … alleen op instance-level aangeroepen worden.") door:

> Voor het fysiek verwijderen van resources kent FHIR R4 geen standaard operatie. Sommige FHIR resource providers bieden hiervoor een eigen mechanisme (zoals HAPI's `$expunge`); dit is een implementatiedetail van de server. Binnen Koppeltaal is de erase-semantiek van het opschoningsproces server-agnostisch gedefinieerd (alle versies gewist, `GET` → `404`, geen tombstone); zie TOP-KT-028 - Opschoning patiëntgegevens. Het recht om vergeten te worden (AVG art. 17) blijft een aparte procedure met eigen toetsing en valt buiten het reguliere opschoningsproces.

- **Motivatie**: de bestaande sectie legt het verschil tussen soft delete, logische `DELETE` (410) en fysiek verwijderen al uit, maar noemt `$expunge` als hét mechanisme. Het besloten ontwerp is bewust server-agnostisch (HAPI `$expunge`, IRIS-eigen mechanisme e.d. zijn implementatiedetails) en positioneert de 404-semantiek als norm. De afbakening van AVG art. 17 komt uit TOP-KT-028 ("Rechten van betrokkenen & contractbeëindiging").

### W5 — Statussen van een task

- **Actie**: wijzigen (noot toevoegen onder de bestaande tabellen)
- **Voorstel**: voeg onder de sectie "Overige statussen van een task" de volgende noot toe:

> De aankondigings-Task van het opschoningsproces (`KT2_DeletePendingTask`, zie TOP-KT-028 - Opschoning patiëntgegevens) gebruikt de native Task-statussen met een eigen betekenis: de Koppeltaalvoorziening zet `requested` (aankondiging), `cancelled` (afgebroken wegens hernieuwde betrokkenheid; de Task blijft behouden) en `completed` (verwijdering uitgevoerd; de Task verdwijnt mee in de erase); de doelapplicatie zet uitsluitend `on-hold` (noodrem, met coded `statusReason`) of `accepted` (groen licht). Deze statussen staan los van de bovenstaande use-case-tabellen voor eHealth-taken.

- **Motivatie**: de tabellen in deze sectie koppelen Task-statussen aan de eHealth-use-cases (kiezen/toewijzen/uitvoeren). De delete-pending Task gebruikt deels dezelfde statussen (`requested`, `accepted`, `on-hold`, `cancelled`, `completed`) met een andere semantiek; zonder noot kan dat tot misinterpretatie leiden — precies het risico dat de sectie "Semantiek" van dit topic benoemt.

## Verwijzingen

- TOP-KT-028 — Opschoning patiëntgegevens (repo: `topics/TOP-KT-028-opschoning-patientgegevens.md`), m.n. "Scope", "Status-lifecycle & server-validatie" en "Definitieve verwijdering" (eisen 1 en 14).
- IG-pagina "Opschoning Patient-data" (`input/pagecontent/opschoning-patient-data.md`).
- Memo Wijzigingen TOPKT011 (`input/pagecontent/memo-wijzigingen-topic11.md`), §3.8 — de `destroy`-AuditEvent als blijvend bewijs.

## Open punten

- Geen leesproblemen met de bron-PDF; alle secties waren leesbaar.
- **Profielnaam in W5** — de naam `KT2_DeletePendingTask` verwijst naar het FSH-voorstel dat nog niet is gemerged of gepubliceerd (zie de update-instructies voor TOP-KT-009). Als de profielnaam bij herindiening wijzigt, moet de noot in W5 meebewegen; de statusbeschrijving zelf volgt het besloten ontwerp en staat vast.
