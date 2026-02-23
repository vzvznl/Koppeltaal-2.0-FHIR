# TOP-KT-005 - Toegangsbeheersing

| Versie | Datum       | Status     | Wijzigingen                                                          |
|--------|-------------|------------|----------------------------------------------------------------------|
| 1.0.4  | 13 Feb 2024 | definitief | Aanpassing Rollen Matrix, eHealthModule → CareTeam → R(All)          |
| 1.0.3  | 21 Dec 2023 | definitief | Aanpassing Rollen Matrix, eHealthModule → EndPoint → CRU             |
| 1.0.2  | 12 Dec 2023 | definitief | Wijzigingen ter verduidelijking Relatie client_id en device reference |
| 1.0.1  | 11 May 2023 | definitief | Kleine wijziging in Eisen 004 en 005                                 |
| 1.0.0  | 27 Feb 2023 | definitief | Geen wijzigingen ten opzichte van laatste concept                    |
| 0.1.1  | 27 Jan 2023 | concept    | Links toegevoegd                                                     |
| 0.1.0  | 8 Dec 2022  | concept    |                                                                      |

In koppeltaal hebben applicaties toegang tot een FHIR resource service in een domein. Deze toegang wordt gegeven door de autorisatie service. De applicaties worden geconfigureerd in de domein database. Deze database bevat rollen met daaraan gekoppeld permissies. Op basis van de rol(en) van de applicatie kent de autorisatie service permissies toe aan de applicatie. Dit doet deze door het genereren van een access token voor de applicatie. Deze access token wordt aan de applicatie toegekend door middel van SMART on FHIR backend services.

- In het onderdeel **Rollen en rechten voor applicatie-instanties** wordt besproken hoe de rollen en rechten werken.
- In het onderdeel **Rollen Matrix** wordt de matrix van rollen en rechten toegelicht.
- In het onderdeel **Applicatie toegang: SMART on FHIR backend services** wordt het verkrijgen van een access token door middel van SMART on FHIR backend services besproken.
