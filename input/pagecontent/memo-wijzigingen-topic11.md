### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-04-01 | Initiële versie                          |

---

### Memo: Wijzigingen TOPKT011 (Logging & Tracing)

**Datum:** 2 april 2026
**Voor:** Koppeltaal Technical Community
**Van:** Kees Graveland & Roland Groen
**Onderwerp:** Overzicht wijzigingen in TOPKT011 en impact voor gekwalificeerde applicaties

### 1. Aanleiding

In voorbereiding op release KTV 2.4.0 van de Koppeltaalvoorziening worden diverse wijzigingen uit de nieuwe versie van TOPKT011 – Logging & Tracing doorgevoerd. Dit memo geeft een overzicht van de relevante wijzigingen en de impact hiervan op applicaties die gebruikmaken van Koppeltaal.

De nieuwe versie van het topic is gepubliceerd op [Confluence](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27095009/TOP-KT-011+-+Logging+en+tracing).

### 2. Implementatieverwachting voor applicaties

De laatste definitieve versie van het topic die door leveranciers geïmplementeerd moet zijn, is **versie 1.3.4**.

De wijzigingen die nu worden doorgevoerd in KTV 2.4.0 zijn óók relevant voor applicaties, maar leiden **niet** tot een aparte kwalificatieronde voor Topic 11.

Leveranciers die zich opnieuw laten kwalificeren kunnen deze wijzigingen direct meenemen in de reguliere kwalificatieprocedure.

### 3. Overzicht van de wijzigingen

Bij het verwerken van de updates uit TOPKT011 richten we ons uitsluitend op die elementen waar de applicatie zelf verantwoordelijk voor is. De aanpassingen worden hieronder per AuditEvent gespecificeerd.

#### 3.1 Wijzigingen voor alle AuditEvents

Alle AuditEvents krijgen de volgende generieke aanpassingen:

- **Extension-velden** zijn aangepast (uniformering en verduidelijking)
- **`source.site`** wordt vastgelegd volgens de nieuwe specificatie
- **`outcomeDesc`** is aangescherpt en dient door de applicatie correct gevuld te worden

#### 3.2 AuditEvent: Launch

Geen aanvullende aanpassingen naast de wijzigingen die voor alle AuditEvents gelden.

#### 3.3 AuditEvent: Launched

Geen extra wijzigingen buiten de generieke aanpassingen.

#### 3.4 AuditEvent: Receive Notification

Naast de generieke wijzigingen:

- **`type`**: code gewijzigd naar `receive`, display naar "Receive/Retain Record Lifecycle Event"
- **`agent.who`**, **`agent.type`** en **`agent.requestor`** van de verzendende partij zijn **verwijderd**. Deze informatie wordt vanaf nu alleen voor de ontvangende partij vastgelegd.

#### 3.5 AuditEvent: Status Change

Geen verdere inhoudelijke wijzigingen naast de generieke aanpassingen.

### 4. Kwalificatie-impact

- Er is **geen aparte kwalificatie** nodig specifiek voor Topic 11.
- De wijzigingen worden onderdeel van de reguliere kwalificatie wanneer een leverancier zijn applicatie opnieuw laat kwalificeren.
- Voor reeds gekwalificeerde applicaties geldt: implementatie wordt verwacht bij doorontwikkeling, maar er is geen directe verplichting tot herkwalificatie.

### 5. Conclusie

De aanpassingen in TOPKT011 die in release KTV 2.4.0 worden meegenomen, zijn beperkt en richten zich vooral op uniformiteit en verduidelijking van de AuditEvents. De impact op leveranciers is overzichtelijk. Leveranciers hoeven geen aparte kwalificatie te doorlopen maar kunnen de wijzigingen meenemen bij een toekomstige reguliere kwalificatie.
