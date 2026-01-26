### Overzicht

Deze pagina bevat feedback en bevindingen uit de implementatie van TOP-KT-011 (Logging en tracering).

*Pagina in voorbereiding - gebaseerd op impactanalyse per 27 mei 2025*

*Verificatie uitgevoerd op 26 januari 2026 tegen KTSA-TOP-KT-011 v1.3.0*

---

### Gerelateerde Issues

| Issue | Titel | Status |
|-------|-------|--------|
| - | - | - |

---

### Algemeen (alle event types)

#### source.site

**Feedback:** De `source.site` waarin de base URL van de FHIR service wordt gelogd is redundant want dit is altijd dezelfde bekende waarde. Quick win maar geeft veel overhead op de proces en data.

**Update 11 juni 2025:** Aanpassen conform simplifier `source.site` naar domeinnaam van de observer.

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie definieert `source.site` als "Base URL van de applicatie waar de log wordt aangemaakt" - dit is inderdaad een redundante bekende waarde.

---

#### resourceOrigin Extension

**Feedback:** Voor het merendeel worden de Extensions beschreven in Topic 11, behalve de ResourceOrigin. Wellicht is deze eerder beschreven elders in het projectteam. Een verwijzing of beknopte beschrijving zou wenselijk zijn.

**Verificatie:** Bevestigd. De `extension.resource-origin` wordt wel genoemd in de mapping tabel (pagina 31) maar niet expliciet beschreven in de event type secties.

---

### Event Type Create

#### entity.query

**Feedback:** Is niet relevant want wordt niet gevuld bij een Create. Wel is een Nice to Have voor een ConditionalCreate, om een compleet beeld te geven in het kader van logging voor de audittrail voor de waarom-vraag. Wel ontbreekt nuance in details; je kunt niet zien of het daadwerkelijk is aangemaakt via http 201 of bestond via 200. Kan uit de If-None-Exist header worden opgehaald, maar gaan we niet doen.

**Besluit 10 juni 2025:** De If-None-Exist header laten we leeg en wordt niet toegevoegd.

**Verificatie:** Bevestigd. Documentatie (pagina 12-14) definieert `entity.query` als "Query parameters in base64Binary formaat" zonder onderscheid voor ConditionalCreate.

---

### Event Type Read

#### entity.query

**Feedback:** Heeft geen rol bij Read event type.

**Besluit 10 juni 2025:** Is geen zinvolle betekenis, wordt niet gevuld. Huidige situatie is akkoord.

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 8-9) definieert `entity.query` als "Query parameters in base64Binary formaat" - niet zinvol voor een Read operatie.

---

### Event Type Update

#### entity.query

**Feedback:** Wordt nu nooit gevuld. De query string kan wel worden gevuld via een ConditialUpdate. Impact is een kleine wijziging om het in de code vast te leggen om het voortaan te doen op een generieke niveau, maar gaan we niet doen.

**Besluit 10 juni 2025:** Is geen zinvolle betekenis, wordt niet gevuld. Huidige situatie is akkoord.

**Verificatie:** Bevestigd. Documentatie (pagina 9-10) definieert `entity.query` zonder onderscheid voor ConditionalUpdate.

---

### Event Type Delete

#### entity.type

**Feedback:** Bevat een fout in documentatie want moet beschreven worden dat de resourceType waarvoor een delete is gedaan.

**Besluit 11 juni 2025:** Impact betreft een documentatie aanpassing (OperationOutcome → `<deleted resourceType>`).

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 12) toont `"code": "OperationOutcome"` als voorbeeld voor `entity.type`, met de opmerking "De OperationOutcome wordt alleen getoond in een fout situatie." Dit is verwarrend - bij normale delete zou de verwijderde resourceType moeten staan.

---

#### entity.description

**Feedback:** Kan verwijderd worden vanwege dat ze historisch interpretatie van de Voorziening/Realisatie team zijn voor de Wat beantwoording i.p.v. de Uitkomst beantwoording.

**Besluit 11 juni 2025:** Mag worden verwijderd. Impact betreft een documentatie aanpassing.

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. `entity.description` wordt in de mapping tabel (pagina 34) beschreven als "Tekst die de entiteit in verder detail beschrijft" - kan verwijderd worden.

---

#### entity.role

**Feedback:** Wordt op dit moment niet gevuld en topic omschrijving ontbreekt. Wellicht moet het leeg zijn.

**Update 11 juni 2025:** Opnieuw uitzoeken in de referentieomgeving. Impact betreft een documentatie aanpassing als eerste aanleg, indien mogelijk ontwikkelwerkzaamheden in het vervolg.

Zie: [FHIR ObjectRole ValueSet](https://build.fhir.org/valueset-object-role.html)

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 12) zegt alleen `entity.role: Not Used` zonder verdere toelichting.

---

#### entity.query

**Feedback:** Wordt nu nooit gevuld. De query string kan wel worden gevuld via een ConditialDelete. Impact is een kleine wijziging om het in de code vast te leggen om het voortaan te doen op een generieke niveau, maar gaan we niet doen.

**Besluit 11 juni 2025:** Gaan we niet doen in de praktijk. De topic beschrijving wordt gecontroleerd op juistheid en de omschrijving wordt verwijderd. Impact betreft een documentatie aanpassing.

**Verificatie:** Bevestigd. Documentatie (pagina 10) definieert `entity.query` als "Query parameters in base64Binary formaat" zonder onderscheid voor ConditionalDelete.

---

### Event Type Search

#### subtype

**Feedback:** Een discrepantie in veldomschrijving.

**Besluit 11 juni 2025:** Documentatie voor dit element aanpassen (search → search-type), beide zijn toegestaan.

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 14) gebruikt `"code": "search"` in het voorbeeld. Volgens FHIR restful-interaction CodeSystem zijn zowel "search" als "search-type" valide codes.

---

#### action

**Feedback:** Een discrepantie in veldomschrijving (R → E).

**Besluit 11 juni 2025:** De FHIR standaard schrijft voor dat het een E moet zijn. Documentatie en Referentieomgeving moet hiervoor worden aangepast. Zie [FHIR referentie](https://build.fhir.org/auditevent.html).

| Operation | Action |
|-----------|--------|
| create | C |
| read, vread, history-instance, history-type, history-system | R |
| update | U |
| delete | D |
| transaction, operation, conformance, validate, search, search-type, search-system | E |

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 14) zegt `action: R` voor Search, maar FHIR standaard schrijft `E` (Execute) voor bij search operaties.

---

#### agent.requestor

**Feedback:** Het element betreft de verwijzing naar de resource.

**Update 11 juni 2025:** Impact betreft een aanpassing in de standaard documentatie.

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 15) zegt `agent.requestor: true` zonder verdere toelichting over de betekenis.

---

#### Entity 1 - bevraging

**Update 11 juni 2025:** Bundle ID vervangen door ResourceType en expliciet het onderscheid maken tussen bevraging en resultaat van de search actie (ticket voor de wijziging in de referentieomgeving).

- **entity.what(1):** Is leeg, de Bundle komt niet voor in de Koppeltaal FHIR profile/store en die kan niet mee opzoeken met resultaten. De bundle bevat geen referenties naar loggings. Impact is om dit Bundle te verwijderen, ter vervanging om de bevraging toch vast te leggen zie trace, request en correlation id's.
- **entity.description(1):** De query wordt in clear text vastgelegd. *Besluit 11 juni 2025:* Toevoegen aan de documentatie (Ticket) Bepalen of je dit als verschil wil documenteren of als wijziging in de standaard als optioneel veld.
- **entity.type(1):** De resourceType element is de opgevraagde resourceType, deze bevraging moeten we altijd vastleggen. Impact is om dit in de documentatie te vermelden. *Besluit 11 juni 2025:* Is geen zinvolle informatie, wordt niet gevuld. Huidige situatie is akkoord.
- **entity.role(1):** *Update 11 juni 2025:* Opnieuw uitzoeken in de referentieomgeving. Impact betreft een documentatie aanpassing als eerste aanleg, indien mogelijk ontwikkelwerkzaamheden in het vervolg.
- **entity.name(1):** *Update 11 juni 2025:* Check de beschrijving en check de juistheid verwijder de omschrijving gaan we niet doen in de praktijk. Moet gevuld met /\<resource\>?\<parameters\>. Impact betreft een documentatie aanpassing als eerste aanleg, indien mogelijk ontwikkelwerkzaamheden in het vervolg.

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 15) beschrijft entity(1) voor Search met `entity.what(1)` verwijzend naar gevraagde resource, `entity.type(1)` als ResourceType, en `entity.role(1)` met code "24" (Query).

---

### Send Notification Event type

#### referentieomgeving

**Feedback:** Ticket voor wijziging in de referentieomgeving. Expliciet het onderscheid maken tussen notification trigger van created/updated resource en Subscription notification van de send notification actie.

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 21-23) beschrijft Send Notification maar maakt geen expliciet onderscheid tussen trigger en notification actie.

---

#### agent.who(1)

**Feedback:** Omschrijving moet aangepast worden in de documentatie, het betreft een referentie naar de Device.

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 22) zegt `agent.who(1)`: "De referentie naar de applicatie die notificatie veroorzaakt" met voorbeeld `Device/<id|client_id>`.

---

#### agent.network(2)

**Feedback:** Omschrijving moet aangepast worden in de documentatie, het mist in specificatie. Het endpoint naar toe wordt gestuurd. Is afgestemd met Helma. Wordt in de voorziening bij agent(1) toegevoegd, moet aan agent(2) worden toegevoegd!

**Update 18 juni 2025:** Besluit of dit ook in de standaard op te nemen.

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 21-23) bevat geen `agent.network(2)` voor Send Notification - dit veld ontbreekt inderdaad.

---

#### (B) De Subscription op basis waarvan de notification wordt verstuurd

- **entity.role(2):** Toe te voegen in de documentatie. Zie toelichting voor toegepaste method in de code.
- **entity.query(2):** Toe te voegen in de documentatie. Zie HL7 standaard [Subscription - FHIR v4.0.1](https://hl7.org/fhir/R4/subscription.html).

**Type:** Documentatie | **Impact:** S

**Verificatie:** Bevestigd. Documentatie (pagina 23) beschrijft entity(2) voor Subscription met `entity.role(2): Not Used` en `entity.query(2)` als "Query parameters in base64Binary formaat".

---

### UserAuthentication Event type

#### type

**Feedback:** Spelfoutcorrectie (User Auntication → UserAuthentication) in de documentatie.

**Type:** Documentatie

**Verificatie:** Niet gevonden in huidige documentatie. In KTSA-TOP-KT-011 v1.3.0 (pagina 27) staat correct "User Authentication" - mogelijk al gecorrigeerd of elders in het systeem.

---

#### source.type

**Feedback:** Wat is de inhoud die de referentieomgeving logt. Wat is de logische inhoud, besluit nemen.

**Type:** Documentatie

**Verificatie:** Bevestigd. Documentatie (pagina 35) beschrijft `source.type` als "Type (device) van de bron waar de gebeurtenis gelogd is" met voorbeeld code "4" (Application Server), maar specifieke invulling voor UserAuthentication ontbreekt.
