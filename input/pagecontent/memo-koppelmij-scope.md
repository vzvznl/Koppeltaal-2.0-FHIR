### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-05-05 | Initiële versie: drie harmonisatie-onderwerpen en scope-keuzes |

---

### Memo: Scope en technische impact KoppelMij

| | |
|---|---|
| **Datum** | 2026-05-05 |
| **Status** | Concept |
| **Auteur** | Roland Groen |

---

### 1. Inleiding

Het KoppelMij-traject is in essentie een **harmonisatie**: twee bestaande modellen — Koppeltaal en MedMij/KoppelMij — worden samengebracht tot één gestandaardiseerd raamwerk. Het uitgangspunt voor de bestaande Koppeltaal-leveranciers is dat de impact zo beperkt mogelijk wordt gehouden en het pad richting harmonisatie gefaseerd verloopt — zonder big-bang.

Om feature creep te voorkomen worden bewuste scope-keuzes gemaakt. Er zijn drie grote harmonisatie-onderwerpen, waarvan er slechts **één in de eerste fase actief wordt beproefd** — en uitsluitend door module-leveranciers. De andere twee onderwerpen blijven voor nu buiten scope, maar zijn voor de eindfase functioneel onmisbaar.

### 2. Drie harmonisatie-onderwerpen

#### 2.1 Persoonlijke autorisatie

**Wat verandert er?**
Koppeltaal autoriseert op **applicatieniveau** via SMART on FHIR backend services; het access_token uit de app launch is een placeholder (`NOOP`). KoppelMij autoriseert op **persoonsniveau** via SMART on FHIR app launch — het access_token vertegenwoordigt de daadwerkelijke gebruiker en de rechten worden door het platform afgedwongen.

**Scope eerste fase**

- ✅ **In scope**: persoonlijke autorisatie wordt beproefd door **module-leveranciers**
- ⛔ **Niet verplicht voor**: EPD's, portalen en andere leveranciers
- 🔁 **Coexistence**: backend services (legacy) en app launch (nieuw) werken parallel gedurende de transitiefase

Zie [Autorisaties](autorisaties.html) en het [Transitiemodel autorisatie](autorisaties-transitiemodel.html) voor het volledige fasering en coexistence-model.

#### 2.2 Module-level taken (ServiceRequest)

**Wat verandert er?**
In Koppeltaal wijst de behandelaar een module als geheel toe — één Task per toewijzing, de module is een black box. KoppelMij vraagt om **individuele taken binnen een module** zichtbaar te maken in het PGO. Hiervoor wordt het patroon **ServiceRequest → Task(s)** geïntroduceerd: een overkoepelende opdracht met door de module aangemaakte taken.

**Scope eerste fase**

- ⛔ **Out of scope**: dit is een uitbreiding richting de KoppelMij-flow die in een latere fase wordt geadresseerd
- 🔁 **Compatibiliteit**: het bestaande Koppeltaal-model (Task only) blijft werken via `ActivityDefinition.kind = Task`; nieuwe modules kunnen `kind = ServiceRequest` aanbieden

Zie [Memo: ServiceRequest KoppelMij](memo-servicerequest-koppelmij.html) voor de volledige uitwerking, inclusief impact per actor en open vragen.

#### 2.3 Resultaat delen

**Wat verandert er?**
Resultaten van een interventie (vragenlijsten, scores, voortgangsinformatie) moeten gestructureerd worden teruggekoppeld van de module naar het EPD/dossier. Hiervoor worden FHIR resources zoals **DocumentReference** en **Observation** ingezet, met meerdere uitwisselpatronen (direct ophalen, Notified Pull, of via de Koppeltaal FHIR store).

**Scope eerste fase**

- ⛔ **Out of scope**: dit is functioneel de **minst uitgewerkte** UC
- ⚠️ **Wel must-have voor de eindfase**: zonder gestructureerde resultaatoverdracht blijven interventieresultaten opgesloten in afzonderlijke applicaties
- 🔁 **Vervolg**: nadere uitwerking met leveranciers is nodig

Zie [Resultaten delen](resultaten-delen.html) voor de huidige stand.

### 3. Wat betekent dit per leveranciersrol?

#### Module-leveranciers

- **Eerste fase**: persoonlijke autorisatie beproeven via SMART on FHIR app launch
- **Later**: ServiceRequest-flow ondersteunen (`ActivityDefinition.kind = ServiceRequest`, taken aanmaken op basis van Subscriptions); gestructureerde resultaatoverdracht implementeren
- **Geen big-bang**: legacy backend services blijven beschikbaar tijdens de transitie

#### EPD-leveranciers

- **Eerste fase**: geen actie vereist; het huidige Koppeltaal-model blijft volledig ondersteund
- **Later**: ServiceRequests aanmaken en koppelen aan de onderliggende taken; ondersteuning voor persoonlijke autorisatie wanneer behandelaars via app launch werken
- **Geen verplichte migratie** in de eerste fase

#### Patiëntportaal- / PGO-leveranciers

- **Eerste fase**: geen actie vereist
- **Later**: UX-aanpassing om taken gegroepeerd onder een ServiceRequest te tonen (in plaats van een platte takenlijst)

### 4. Waarom deze scope-keuzes?

- **Impact minimaliseren**: bestaande Koppeltaal-leveranciers worden niet gedwongen om in één keer te migreren
- **Feature creep voorkomen**: drie grote onderwerpen tegelijk volledig uitwerken zou de eerste fase onuitvoerbaar zwaar maken
- **Leren door doen**: persoonlijke autorisatie is het meest concreet uitgewerkt en wordt als eerste beproefd; lessen uit deze pilot voeden de uitwerking van de overige onderwerpen
- **Coexistence boven big-bang**: het transitiemodel ondersteunt parallelle werking van legacy en nieuw, zodat leveranciers in eigen tempo kunnen migreren

### 5. Verwijzingen

- [Memo: Impact KoppelMij op Koppeltaal](memo-impact-koppelmij.html) — gedetailleerde technische impact per onderdeel
- [Autorisaties](autorisaties.html) — autorisatiemodel
- [Transitiemodel autorisatie](autorisaties-transitiemodel.html) — fasering en coexistence
- [Memo: ServiceRequest KoppelMij](memo-servicerequest-koppelmij.html) — module-level taken
- [Resultaten delen](resultaten-delen.html) — resultaat-overdracht
- [KoppelMij designs](https://koppelmij.github.io/koppelmij-designs/) — externe referentie
