### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-04-13 | Initiële versie                          |

---

### Resultaten delen

De inzet van eHealth en blended care is breed ingebed in de zorg. Digitale interventies leveren waardevolle resultaten op — zoals vragenlijsten, scores en voortgangsinformatie — die essentieel zijn voor goede behandelbeslissingen. In de praktijk zijn deze resultaten echter vaak opgesloten binnen afzonderlijke applicaties, wat leidt tot informatieversnippering en extra administratieve lasten.

Door resultaten delen expliciet te ondersteunen binnen Koppeltaal ontstaat een uniforme en gestandaardiseerde manier om interventieresultaten veilig en geautoriseerd over te dragen van de bronapplicatie (module) naar de dossierhouder (EPD). Hierbij wordt aangesloten op bestaande MedMij- en Nictiz-standaarden. Koppeltaal fungeert als orkestratie-, transport- en autorisatielaag — niet als opslagsysteem.

### Typen resultaten

#### Documenten (DocumentReference)

Ongestructureerde resultaten zoals PDF/A-rapporten, vragenlijstuitkomsten of samenvattingen worden uitgewisseld via het FHIR [DocumentReference](https://www.hl7.org/fhir/documentreference.html) resource. Een DocumentReference bevat metadata over het document (type, datum, auteur, patiënt) en een verwijzing naar een [Binary](https://www.hl7.org/fhir/binary.html) resource met het daadwerkelijke document.

Het uitgangspunt is dat de Binary bij de bronapplicatie blijft. De DocumentReference in de Koppeltaal FHIR store bevat een referentie naar de Binary bij de bron — niet een kopie. Dit past bij het principe "data aan de bron": tijdens een actieve behandeling blijven resultaten bij de bronapplicatie.

De module genereert automatisch een PDF/A bij afronding van de interventie. PDF/A is het vereiste formaat voor duurzame archivering in het EPD.

#### Gestructureerde resultaten (Observation)

Gestructureerde, meetbare uitkomsten — zoals scores, metingen of gecodeerde antwoorden — worden uitgewisseld via het FHIR [Observation](https://www.hl7.org/fhir/observation.html) resource. Observations bieden een gestandaardiseerde manier om resultaten machineleesbaar vast te leggen, inclusief codering (bijv. SNOMED CT, LOINC) en eenheden.

QuestionnaireResponse-resultaten (zoals ingevulde vragenlijsten) kunnen eveneens via dit mechanisme worden overgedragen.

### Uitwisselingspatronen

Er zijn twee paden voor het overdragen van resultaten van de module naar het EPD:

#### Pad A: Direct ophalen via Koppeltaal FHIR store

In dit patroon publiceert de module een DocumentReference in de Koppeltaal FHIR store. Het EPD detecteert de nieuwe DocumentReference — via polling of een FHIR Subscription — en haalt vervolgens het daadwerkelijke document (Binary) op bij de bronapplicatie.

<div style="clear: both; margin: 1em 0;">
  <img src="resultaten-delen-pad-a.png" alt="Pad A: Direct ophalen via Koppeltaal FHIR store" style="display: block; max-width: 100%; height: auto;"/>
</div>

Dit is het eenvoudigste patroon. Het EPD moet echter zelf detecteren dat er nieuwe resultaten beschikbaar zijn.

#### Pad B: Notified Pull

In het Notified Pull patroon — gebaseerd op de [TA Notified Pull v1.0.1](https://www.nictiz.nl/) — neemt de module het initiatief door het EPD actief te notificeren dat er resultaten klaarstaan. Dit gebeurt via een Notification Task.

<div style="clear: both; margin: 1em 0;">
  <img src="resultaten-delen-pad-b.png" alt="Pad B: Notified Pull" style="display: block; max-width: 100%; height: auto;"/>
</div>

De Notification Task bevat verwijzingen naar de op te halen FHIR resources (DocumentReference, Binary). Het EPD haalt op eigen initiatief en tempo de data op bij de bron.

**Voordelen van Notified Pull:**

- **Dataminimalisatie**: het EPD bepaalt zelf welke data wordt opgehaald
- **Actuele data**: data wordt opgehaald op het moment dat het nodig is
- **Betere security**: de ontvanger identificeert zich bij het ophalen, waardoor inzichtelijk is wie de data raadpleegt
- **Data aan de bron**: het document hoeft niet gekopieerd te worden naar een tussenliggende opslag

### Workflow

Resultaat delen is het sluitstuk van de bestaande Koppeltaal Task lifecycle:

1. De behandelaar wijst een interventie toe aan de patiënt (Task wordt aangemaakt)
2. De patiënt voert de interventie uit via de module
3. De interventie wordt afgerond (Task.status → `completed`)
4. De module genereert het resultaat (PDF/A en/of Observation)
5. De module deelt het resultaat via pad A of pad B
6. Het EPD haalt het resultaat op en archiveert het in het patiëntdossier

De DocumentReference wordt gekoppeld aan zowel de Patient als de Task, zodat het resultaat traceerbaar is naar de specifieke interventie.

### Autorisatie

Toegang tot resultaten is gebonden aan de behandelrelatie:

- **Zorgverleners**: alleen zorgverleners met een geldige behandelrelatie — vastgelegd in het CareTeam — krijgen toegang tot resultaten
- **RelatedPerson**: personen betrokken bij de behandeling (ouders, mantelzorgers, wettelijk vertegenwoordigers) kunnen beperkte, doelgebonden en tijdgebonden inzage krijgen in resultaten. Toegang vervalt automatisch bij het eindigen van de relatie, het intrekken van toestemming of het afsluiten van de behandeling
- **Logging**: alle inzage en overdracht van resultaten wordt gelogd en is auditeerbaar

### Status

Deze pagina beschrijft de oplossingsrichting op hoog niveau. De exacte invulling van profielen, uitwisselingspatronen en autorisatieregels wordt in samenwerking met leveranciers bepaald.
