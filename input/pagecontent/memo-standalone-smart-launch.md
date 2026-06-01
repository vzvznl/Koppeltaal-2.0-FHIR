### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-05-05 | Initiële versie                          |
| 0.0.2  | 2026-05-18 | Verwerking hypothesis-feedback: id_token/token response (#54), open vraag IdP-selectie (#55), "Log in met Koppeltaal"-UX (#56), launch-URL mag gedeeld (#57) |
| 0.0.3  | 2026-06-01 | Aanleiding-punt 1 herschreven: de bewaartermijn van patiëntdata wordt niet langer afgeleid uit een `last-patient-engagement`-extension op `Patient.meta`, maar uit AuditEvents (`/authorize`, `/introspect[hti]`) en `Task.owner==Patient`. Voor standalone-launch-applicaties betekent dit dat het schrijven van het AuditEvent bij `/authorize` voldoende is — geen aparte schrijfactie op `Patient.meta` meer nodig. Referentie naar de verwijderde pagina `opschoning-patient-data-startmoment` weggehaald |

---

### Memo: Standalone SMART on FHIR App Launch

| | |
|---|---|
| **Datum** | 2026-05-05 |
| **Status** | Concept |
| **Auteur** | Roland Groen |

---

### 1. Aanleiding

In het huidige Koppeltaal-stelsel worden module-applicaties uitsluitend gestart via een **EHR Launch**: een portaal (EPD of cliëntportaal) opent de module in de context van een specifieke gebruiker en taak. Dit model werkt goed zolang de interactie met de module altijd via het portaal verloopt.

In de praktijk zijn er echter scenario's waarin een module-applicatie **buiten het portaal om** contact heeft met de gebruiker — bijvoorbeeld door de gebruiker per e-mail uit te nodigen of door direct een account aan te maken na het detecteren van een nieuwe patiënt. In deze gevallen ontstaat interactie buiten het Koppeltaal-stelsel: er wordt geen launch uitgevoerd, er is geen gecontroleerde contextuele overdracht, en er wordt geen User Authentication AuditEvent aangemaakt.

De SMART on FHIR specificatie biedt hiervoor een gestandaardiseerd alternatief: de **Standalone Launch**. Hierbij start de app zelfstandig (bijvoorbeeld vanuit een app-icoon, e-mail of browser) en doorloopt alsnog de volledige autorisatie- en authenticatieflow.

Het ondersteunen van de standalone launch naast de bestaande EHR launch adresseert twee concrete behoeften:

1. **Opschoning Patient-data**: de bewaartermijn van patiëntdata wordt bepaald op basis van de laatste betrokkenheid van de patiënt. Die wordt op het moment van de activiteitscheck afgeleid uit AuditEvents bij `/authorize` en `/introspect[hti]` en uit Tasks waar de patiënt de uitvoerder is — zie [Opschoning Patient-data](opschoning-patient-data.html#startmoment-bewaartermijn-moet-eenduidig-zijn). Door de standalone launch via de Koppeltaal-`/authorize` te laten lopen, ontstaat het AuditEvent dat dit signaal voedt; de applicatie hoeft daarvoor zelf niets extra's te doen
2. **Autorisatie**: het geharmoniseerde autorisatiemodel vereist dat de identiteit en context van de gebruiker bij elke sessie worden vastgesteld — niet alleen bij de eerste launch vanuit een portaal (zie [Autorisaties](autorisaties.html))

### 2. EHR Launch vs. Standalone Launch

De [SMART App Launch](https://build.fhir.org/ig/HL7/smart-app-launch/app-launch.html) specificatie definieert twee launch-flows:

#### EHR Launch (huidig model)

De gebruiker heeft een actieve sessie in een portaal (EPD, cliëntportaal). Het portaal start de module-applicatie door een browser te openen naar de geregistreerde launch-URL met twee parameters:

- `iss`: het FHIR-endpoint van de Koppeltaalvoorziening
- `launch`: een opaque identifier die de sessie koppelt aan de gebruiker en context

De module ontvangt na autorisatie een token response met daarin het access token (voor toegang tot FHIR-resources), het id_token (met de `fhirUser` claim wanneer de scope `openid fhirUser` is aangevraagd), en de SMART context parameters (waaronder `patient`). Zie [SMART launch context parameters](https://build.fhir.org/ig/HL7/smart-app-launch/scopes-and-launch-context.html#launch-context-arrives-with-your-access_token). De context is volledig bepaald door het lancerende portaal.

#### Standalone Launch (nieuw)

De gebruiker start de module-applicatie zelfstandig — bijvoorbeeld door op een app-icoon te tikken, een link in een e-mail te volgen, of de applicatie direct in de browser te openen. Er is geen portaal dat context meegeeft.

De app doorloopt dezelfde OAuth2-autorisatieflow, maar met twee verschillen:

1. **Geen `launch` parameter**: de app stuurt geen `launch`-id mee, want er is geen portaalsessie
2. **Contextverzoek via scopes**: de app vraagt context aan via scopes als `launch/patient`, waarna de autorisatieserver de gebruiker een patiëntselectie kan aanbieden (of de context automatisch bepaalt op basis van de ingelogde gebruiker)

De app ontvangt vervolgens dezelfde token response als bij een EHR launch:

- Een access token met de juiste scopes
- Een id_token met de `fhirUser` claim (identiteit van de gebruiker, bij scope `openid fhirUser`)
- SMART context parameters waaronder `patient` (patiëntcontext)
- Een User Authentication AuditEvent wordt aangemaakt

### 3. Wat verandert er?

#### Voor de module-aanbieder

- De module moet naast de EHR launch ook een **standalone launch** ondersteunen: een pagina die de OAuth2-flow start zonder `launch`-parameter. Dit mag een aparte URL zijn, maar dezelfde launch-URL kan ook beide flows afhandelen op basis van aan- of afwezigheid van de `launch`-parameter
- Bij een standalone launch vraagt de module `launch/patient` en `openid fhirUser` scopes aan om context en identiteit te verkrijgen
- Modules die nu al direct contact met gebruikers leggen (e-mail, push-notificatie, eigen onboarding) bieden in plaats van een eigen login een **"Log in met Koppeltaal"**-route aan die verwijst naar de standalone launch-URL
- [PKCE](https://datatracker.ietf.org/doc/html/rfc7636) (S256) is verplicht voor alle SMART apps

#### Voor de Koppeltaalvoorziening

- De autorisatieserver moet standalone launch-flows ondersteunen: autorisatieverzoeken zonder `launch`-parameter maar met `launch/patient` scope
- Bij een standalone launch moet de autorisatieserver de patiëntcontext bepalen — bijvoorbeeld op basis van de ingelogde gebruiker (als deze een Patient is) of via een selectiewidget
- Een User Authentication AuditEvent wordt aangemaakt bij elke succesvolle standalone launch

#### Voor het portaal (EPD / cliëntportaal)

- Geen wijziging. De EHR launch blijft werken zoals nu.

### 4. Interactiepatronen

#### EHR Launch (bestaand)

De gebruiker is ingelogd in het portaal. Het portaal selecteert een taak en start de module:

<div style="clear: both; margin: 1em 0;">
{% include memo-smart-ehr-launch.svg %}
</div>

#### Standalone Launch (nieuw)

De gebruiker opent de module direct (bijv. via e-mail link of app-icoon):

<div style="clear: both; margin: 1em 0;">
{% include memo-smart-standalone-launch.svg %}
</div>

### 5. Het stelsel als uitgangspunt

Een kernprincipe van Koppeltaal is dat alle interactie met patiëntdata via het stelsel verloopt: geautoriseerd, gelogd en traceerbaar. De EHR launch borgt dit wanneer de gebruiker via een portaal werkt. De standalone launch breidt deze borging uit naar scenario's waarin de gebruiker buiten een portaal om wordt bereikt.

Door de standalone launch als gestandaardiseerde route aan te bieden, krijgen module-aanbieders een concreet alternatief voor directe gebruikerscommunicatie die buiten het stelsel om verloopt. In plaats van een eigen onboarding of notificatie die de Koppeltaal-autorisatie omzeilt, kan de module de gebruiker via een **"Log in met Koppeltaal"**-route alsnog door de volledige SMART on FHIR flow laten gaan. Het resultaat is hetzelfde — de gebruiker komt in de module terecht — maar de interactie is geautoriseerd, de identiteit is vastgesteld, en de activiteit is gelogd.

### 6. Open vragen

#### Patiëntselectie bij standalone launch

Bij een EHR launch bepaalt het portaal de patiëntcontext. Bij een standalone launch moet de autorisatieserver dit doen. Voor patiënten die zelf inloggen is dit eenvoudig (de ingelogde gebruiker is de patiënt), maar voor behandelaars of mantelzorgers moet een selectiemechanisme worden geboden. De exacte invulling hiervan moet worden uitgewerkt.

#### IdP-selectie bij standalone launch

Bij een EHR launch geeft het portaal `idp_hint` mee op basis van context die alleen daar bekend is — bijvoorbeeld een minderjarige patiënt die via een andere IdP moet inloggen dan een volwassene. Bij een standalone launch ontbreekt deze contextuele hint. Mogelijke routes:

- De gebruiker kiest zelf een IdP op een keuzepagina bij de autorisatieserver
- De module geeft zelf een `idp_hint` mee in het autorisatieverzoek (bijvoorbeeld omdat de uitnodigingscontext bekend is bij de module)
- De Koppeltaalvoorziening hanteert een default-IdP wanneer geen hint wordt meegegeven

De exacte invulling moet worden uitgewerkt, mede in samenhang met het scenario van meerdere IdPs.

#### Registratie van standalone launch-URLs

Module-applicaties moeten ondersteuning voor de standalone launch registreren bij de Koppeltaalvoorziening, naast hun bestaande EHR launch. Dit kan via dezelfde launch-URL (die beide flows afhandelt) of via een aparte URL. De wijze van registratie (via de bestaande Device-registratie of een apart mechanisme) moet worden bepaald.

### 7. Referenties

- [SMART App Launch - App Launch](https://build.fhir.org/ig/HL7/smart-app-launch/app-launch.html)
- [SMART App Launch - Scopes and Launch Context](https://build.fhir.org/ig/HL7/smart-app-launch/scopes-and-launch-context.html)
- [PKCE (RFC 7636)](https://datatracker.ietf.org/doc/html/rfc7636)
- [Opschoning Patient-data](opschoning-patient-data.html)
- [Autorisaties](autorisaties.html)
