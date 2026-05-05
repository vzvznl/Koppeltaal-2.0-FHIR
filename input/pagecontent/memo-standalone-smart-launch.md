### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-05-05 | Initiële versie                          |

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

1. **Archivering**: de bewaartermijn van patiëntdata wordt bepaald op basis van de laatste User Authentication. Wanneer interactie buiten de launch om plaatsvindt, wordt dit event niet aangemaakt en kan de bewaartermijn niet correct worden berekend (zie [Archivering](archivering.html#startmoment-bewaartermijn-moet-eenduidig-zijn))
2. **Autorisatie**: het geharmoniseerde autorisatiemodel vereist dat de identiteit en context van de gebruiker bij elke sessie worden vastgesteld — niet alleen bij de eerste launch vanuit een portaal (zie [Autorisaties](autorisaties.html))

### 2. EHR Launch vs. Standalone Launch

De [SMART App Launch](https://build.fhir.org/ig/HL7/smart-app-launch/app-launch.html) specificatie definieert twee launch-flows:

#### EHR Launch (huidig model)

De gebruiker heeft een actieve sessie in een portaal (EPD, cliëntportaal). Het portaal start de module-applicatie door een browser te openen naar de geregistreerde launch-URL met twee parameters:

- `iss`: het FHIR-endpoint van de Koppeltaalvoorziening
- `launch`: een opaque identifier die de sessie koppelt aan de gebruiker en context

De module ontvangt via het access token de gebruikersidentiteit (`fhirUser`) en patiëntcontext (`patient`). De context is volledig bepaald door het lancerende portaal.

#### Standalone Launch (nieuw)

De gebruiker start de module-applicatie zelfstandig — bijvoorbeeld door op een app-icoon te tikken, een link in een e-mail te volgen, of de applicatie direct in de browser te openen. Er is geen portaal dat context meegeeft.

De app doorloopt dezelfde OAuth2-autorisatieflow, maar met twee verschillen:

1. **Geen `launch` parameter**: de app stuurt geen `launch`-id mee, want er is geen portaalsessie
2. **Contextverzoek via scopes**: de app vraagt context aan via scopes als `launch/patient`, waarna de autorisatieserver de gebruiker een patiëntselectie kan aanbieden (of de context automatisch bepaalt op basis van de ingelogde gebruiker)

De app ontvangt vervolgens dezelfde informatie als bij een EHR launch:

- Een access token met de juiste scopes
- De `fhirUser` claim (identiteit van de gebruiker)
- De `patient` parameter (patiëntcontext)
- Een User Authentication AuditEvent wordt aangemaakt

### 3. Wat verandert er?

#### Voor de module-aanbieder

- De module moet naast de EHR launch ook een **standalone launch-URL** ondersteunen (een pagina die de OAuth2-flow start zonder `launch`-parameter)
- Bij een standalone launch vraagt de module `launch/patient` en `openid fhirUser` scopes aan om context en identiteit te verkrijgen
- Directe gebruikersinteractie (e-mail, push-notificatie, etc.) verwijst naar de standalone launch-URL in plaats van direct naar de module
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

Door de standalone launch als gestandaardiseerde route aan te bieden, krijgen module-aanbieders een concreet alternatief voor directe gebruikerscommunicatie die buiten het stelsel om verloopt. In plaats van een eigen onboarding of notificatie die de Koppeltaal-autorisatie omzeilt, kan de module de gebruiker via de standalone launch alsnog door de volledige SMART on FHIR flow laten gaan. Het resultaat is hetzelfde — de gebruiker komt in de module terecht — maar de interactie is geautoriseerd, de identiteit is vastgesteld, en de activiteit is gelogd.

### 6. Open vragen

#### Patiëntselectie bij standalone launch

Bij een EHR launch bepaalt het portaal de patiëntcontext. Bij een standalone launch moet de autorisatieserver dit doen. Voor patiënten die zelf inloggen is dit eenvoudig (de ingelogde gebruiker is de patiënt), maar voor behandelaars of mantelzorgers moet een selectiemechanisme worden geboden. De exacte invulling hiervan moet worden uitgewerkt.

#### Registratie van standalone launch-URLs

Module-applicaties moeten hun standalone launch-URL registreren bij de Koppeltaalvoorziening, naast hun bestaande EHR launch-URL. De wijze van registratie (via de bestaande Device-registratie of een apart mechanisme) moet worden bepaald.

### 7. Referenties

- [SMART App Launch - App Launch](https://build.fhir.org/ig/HL7/smart-app-launch/app-launch.html)
- [SMART App Launch - Scopes and Launch Context](https://build.fhir.org/ig/HL7/smart-app-launch/scopes-and-launch-context.html)
- [PKCE (RFC 7636)](https://datatracker.ietf.org/doc/html/rfc7636)
- [Archivering - Startmoment bewaartermijn](archivering.html)
- [Autorisaties](autorisaties.html)
