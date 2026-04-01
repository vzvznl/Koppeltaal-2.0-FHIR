### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-03-31 | Initiële versie                          |

---

### Memo: Impact KoppelMij op Koppeltaal

Het [KoppelMij](https://koppelmij.github.io/koppelmij-designs/) project integreert Koppeltaal eHealth-modules in MedMij Persoonlijke Gezondheidsomgevingen (PGO's). Dit heeft gevolgen voor de Koppeltaal FHIR-profielen en de implementatie door leveranciers.

Deze memo geeft op hoog niveau een overzicht van de verwachte wijzigingen.

### 1. Autorisatiemodel

In Koppeltaal vindt autorisatie op **applicatieniveau** plaats. Een module ontvangt een applicatie-breed access_token via **SMART on FHIR backend services** (server-to-server). Hoewel Koppeltaal ook SMART on FHIR app launch gebruikt, wordt het access_token uit de app launch momenteel niet gebruikt voor data-uitwisseling.

In KoppelMij vindt autorisatie op **persoonsniveau** plaats. Het access_token uit de **SMART on FHIR app launch** wordt nu wél gebruikt en is gekoppeld aan de specifieke gebruiker. Dit betekent voor de module-applicatie:

- Het access_token is niet langer applicatie-breed, maar **in de scope van de gebruiker**.
- De module gebruikt dit access_token voor alle FHIR-interacties met de DVA (Dienstverlener Aanbiedertaken).
- De module hoeft zich niet bezig te houden met hoe het access_token tot stand komt — de Token Exchange ([RFC 8693](https://datatracker.ietf.org/doc/html/rfc8693)) tussen PGO en DVA is transparant voor de module.

De uitwerking van autorisatie op persoonsniveau vindt plaats in de [Autorisaties](autorisaties.html) sectie van deze Implementation Guide.

### 2. Return URL

Er komt een nieuw element `return_url` in de **SMART on FHIR launch context**. Na afloop van een module-sessie wordt de gebruiker teruggestuurd naar het PGO.

- Het PGO geeft een `return_url` mee in de launch context. De module **MOET** de gebruiker na afsluiting via deze URL terugsturen.
- Het PGO kan de `return_url` verrijken met query-parameters, bijvoorbeeld een `task_id`, zodat het PGO weet om welke specifieke taak het gaat.
- De module **MOET** de taakstatus (Task.status) bijwerken vóór de redirect naar de `return_url`.
- Bij annulering of foutgevallen kan een `error` parameter worden meegegeven (bijv. `error=temporarily_unavailable`).
- Voor mobiele apps geldt hetzelfde mechanisme via Universal Links (iOS) en App Links (Android).

### 3. Profielwijzigingen

De Koppeltaal FHIR-profielen worden op een aantal punten aangepast:

- **Openstellen van profielen**: De huidige Koppeltaal-profielen staan geen onbekende extensions toe ("gesloten"). Voor gebruik in de MedMij-context moeten profielen worden opengesteld, zodat MedMij-specifieke extensions mogelijk zijn.
- **Endpoint: extension `client_id`**: Een nieuwe extension op het Endpoint resource, die het client-ID bevat dat gebruikt wordt als `audience` parameter bij de DVA token exchange.
- **Group identifier op Tasks**: Een groeps-identifier waarmee gerelateerde taken kunnen worden gegroepeerd (bijv. alle taken binnen één COPD-zorgpad).
- **Task.code / security labels**: Mogelijke uitbreidingen voor het classificeren van taken en het toepassen van autorisatieregels. Dit is nog in onderzoek.

### 4. Workflow uitbreiding

KoppelMij introduceert workflow resources zoals de **ServiceRequest** als nieuw FHIR resource:

```
ServiceRequest → Task(s) → Uitvoering
```

Een behandelaar kan via een ServiceRequest een digitale activiteit "voorschrijven" voor een patiënt. De ServiceRequest bevat onder andere een verwijzing naar de patiënt, patiëntspecifieke instructies en een planning.

**Beperkte impact op modules en PGO's:** Het belangrijke uitgangspunt is dat deze workflow resources (zoals ServiceRequest) potentieel niet zichtbaar of beschikbaar worden gemaakt aan het PGO of de module. De Task blijft het startpunt voor zowel de module als het PGO. De relatie met de achterliggende workflow is hooguit zichtbaar als referentie, bijvoorbeeld via een group identifier op de Task. Dit betekent dat de workflow rond de taken kan bestaan en evolueren zonder dat dit impact heeft op de module of het PGO.

### Status

Deze wijzigingen bevinden zich in de ontwerp- en proof-of-concept fase. De exacte invulling wordt in samenwerking met leveranciers bepaald. Voor de volledige technische specificatie verwijzen we naar de [KoppelMij Implementation Guide](https://koppelmij.github.io/koppelmij-designs/) en het bijbehorende [FHIR-profiel](https://github.com/KoppelMij/MedMij-R4-KoppelMij).
