### Changelog

| Datum | Wijziging |
|-------|-----------|
| 2025-12-02 | Drie interactiediagrammen samengevoegd tot één diagram met alt scenarios |
| 2025-12-02 | Functionele eis toegevoegd: lege lijst resulteert in default IdP |
| 2025-12-02 | Interne links toegevoegd naar paragrafen |
| 2025-12-02 | "De volgende opties zijn mogelijk" gewijzigd naar "Hieronder staan drie voorbeelden" |
| 2025-11-24 | Overwegingen sectie herschreven met focus op `idp_hint` keuze |
| 2025-11-24 | Initiële versie van de pagina |

### Beschrijving

Deze pagina beschrijft de ondersteuning voor meerdere Identity Providers (IdPs) per gebruikerstype binnen een Koppeltaal domein. Deze functionaliteit maakt het mogelijk om per launch aan te geven bij welke IdP de gebruiker geauthenticeerd moet worden.

#### Use case

Als platform die Koppeltaal 2.0 launches uitvoert, wil ik in de launch kunnen aangeven waar de gebruiker geauthenticeerd moet worden, zodat er per gebruiker een andere IdP gebruikt kan worden. Dit maakt het bijvoorbeeld mogelijk om onderscheid te maken tussen:

- RelatedPersons die DigiD moeten gebruiken (wettelijk vertegenwoordigers)
- RelatedPersons die een andere authenticatiemethode gebruiken (mantelzorgers via organisatie-IdP)

#### Relatie met bestaande functionaliteit

Deze functionaliteit is een uitbreiding op de bestaande [Identity Provisioning](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27153689) configuratie. Waar voorheen per combinatie van domein, applicatie-instantie en gebruikerstype maximaal één IdP geconfigureerd kon worden (0..1), wordt dit uitgebreid naar meerdere IdPs (0..*).

### Overwegingen

#### Keuze voor custom `idp_hint` claim

De gekozen oplossing is een custom claim `idp_hint` in het HTI launch token. De voordelen van deze aanpak:

- **Duidelijke intentie**: De claim geeft expliciet aan waar de waarde voor dient
- **Ondertekend door lancerend platform**: Het HTI token is ondertekend, dus de `idp_hint` is betrouwbaar zonder extra JWT
- **Geen PII**: Bevat alleen een identifier van de IdP, geen persoonsgegevens
- **Toekomstbestendig**: Onafhankelijk van het authenticatiemechanisme van de IdP

##### Overwogen alternatief: `id_token_hint`

Initieel werd de OIDC `id_token_hint` parameter overwogen. Dit alternatief is afgewezen vanwege:

- **Security risico's**: PII in het token kan in logs en APM traces belanden
- **AVG compliance**: Meesturen van onnodige PII voldoet niet aan het dataminimalisatieprincipe (artikel 5 AVG)
- **Semantische mismatch**: `id_token_hint` is bedoeld voor re-authenticatie van dezelfde gebruiker, niet voor IdP-selectie
- **Toekomstbestendigheid**: Niet alle authenticatiemechanismen hebben een `id_token`
- **Extra complexiteit**: Onduidelijke regels voor edge cases (bijv. verlopen tokens)

#### Inhoud van het idp_hint veld

De `idp_hint` wordt gevuld met een **unieke logische identifier**, bijvoorbeeld: `idp-relatedperson-digid`. Vanuit domeinbeheer kan deze toegekend worden aan een IdP. Deze kan runtime aangepast worden, zonder dat er in de applicaties iets aangepast hoeft te worden.

De lancerende applicatie dient de juiste waarde te verkrijgen via domeinbeheer of de bijbehorende documentatie.

### Toepassing, restricties en eisen

#### Technische implementatie

De technische flow voor het gebruik van de `idp_hint` is als volgt:

1. **Aanmelding bij lancerende applicatie**: De gebruiker meldt zich aan bij de lancerende applicatie. Als dit met OIDC gebeurt, komt hier een `id_token` uit voort.

2. **Toevoegen idp_hint aan HTI token**: Tijdens de launch wordt aan het HTI token het veld `idp_hint` toegevoegd. De waarde van de `idp_hint` wordt bepaald door de combinatie van domeinbeheer en autorisatie service (zie [Inhoud van het idp_hint veld](#inhoud-van-het-idp_hint-veld)).

3. **Ontvangst door gelanceerde applicatie**: De gelanceerde applicatie (module) ontvangt de launch en start de SMART on FHIR app launch flow met de autorisatie service.

4. **Verwerking door autorisatie service**: De autorisatie service ontvangt het HTI token in de `launch` parameter en vindt daarin het `idp_hint` veld. Vervolgens past de autorisatie service de logica zoals beschreven in [IdP resolutie algoritme](#idp-resolutie-algoritme) toe.

##### Bepaling idp_hint waarde

De exacte waarde van het `idp_hint` veld is implementatie-specifiek en wordt bepaald door de combinatie van domeinbeheer en autorisatie service. De lancerende applicatie dient de juiste waarde te verkrijgen via domeinbeheer of de bijbehorende documentatie van het domein.

Het HTI launch token wordt uitgebreid met een optionele `idp_hint` claim:

```json
{
  "iss": "client_id_portal",
  "aud": "Device/123",
  "sub": "Patient/456",
  "resource": "Task/789",
  "definition": "ActivityDefinition/abc",
  "idp_hint": "https://idp.example.com/idp1/",
  "iat": 1234567890,
  "exp": 1234567950
}
```

##### Domeinbeheer configuratie

In domeinbeheer moet de volgende functionaliteit beschikbaar zijn:

1. **Meerdere IdPs per gebruikerstype**: Per combinatie van domein, applicatie-instantie en gebruikerstype (Patient, Practitioner, RelatedPerson) kunnen 0..* IdPs geconfigureerd worden
2. **Volgordelijke lijst**: De geselecteerde IdPs worden in een volgordelijke lijst beheerd
3. **Default IdP**: De eerste IdP in de lijst is de default
4. **IdP identifier**: Het moet eenvoudig zijn om de IdP identifier te kopiëren voor gebruik in de `idp_hint` claim
5. **Backwards compatible**: Bestaande 0..1 configuraties blijven werken

##### IdP resolutie algoritme

De autorisatie service bepaalt welke IdP gebruikt wordt volgens het volgende algoritme:

```
ALS idp_hint NIET aanwezig in launch token:
    ALS geen custom IdP geconfigureerd voor gebruikerstype:
        Gebruik default Koppeltaal 2.0 IdP
    ANDERS:
        Gebruik eerste geconfigureerde IdP (default)

ALS idp_hint WEL aanwezig in launch token:
    ALS idp_hint waarde geconfigureerd voor dit gebruikerstype:
        Gebruik deze IdP
    ANDERS:
        Log misconfiguratie
        Voer fallback uit (alsof geen hint gegeven)
```

##### AuditEvent logging

Bij een misconfiguratie van de IdP (bijvoorbeeld een ongeldige `idp_hint`) moet een AuditEvent aangemaakt worden. Dit valt onder de bestaande AuditEvent logging voor authenticatie (type 110114, User Authentication).

##### Backwards compatibility

- Bestaande configuraties met 0..1 IdP blijven ongewijzigd werken
- Launch tokens zonder `idp_hint` worden verwerkt als voorheen
- **Gefaseerde uitrol**: Wanneer de autorisatie service en domeinbeheer Multiple IdP Support ondersteunen, maar de lancerende applicatie nog geen `idp_hint` meestuurt, is het fallback scenario van toepassing. De autorisatie service gebruikt dan automatisch de eerste (default) IdP uit de geconfigureerde lijst. Dit maakt een gefaseerde uitrol mogelijk waarbij applicaties op hun eigen tempo kunnen worden bijgewerkt.

#### Gebruikte standaarden

- **OpenID Connect (OIDC)**: Voor communicatie met de Identity Provider
- **SMART on FHIR App Launch**: Framework voor de launch flow
- **HTI 2.0**: Health Tool Interoperability voor het launch token
- **JWT (RFC 7519)**: JSON Web Token voor ondertekening van het HTI token

#### Eisen

##### Functionele eisen

1. Per gebruikerstype kunnen meerdere IdPs geconfigureerd worden
2. De volgorde van IdPs is aanpasbaar in domeinbeheer
3. De eerste IdP in de lijst is de default
4. Een lege lijst resulteert in gebruik van de default IdP van het domein
5. De `idp_hint` claim in het launch token wordt herkend door de autorisatie service
6. Bij een ongeldige `idp_hint` wordt fallback naar default uitgevoerd
7. Misconfiguraties worden gelogd als AuditEvent

### Interactiediagram

Het volgende diagram toont de drie scenario's voor IdP selectie:
- **idp_hint is geldig**: De specifieke IdP uit de hint wordt gebruikt
- **idp_hint niet gevonden**: Misconfiguratie wordt gelogd, fallback naar default IdP
- **geen idp_hint aanwezig**: De eerste (default) IdP uit de configuratie wordt gebruikt

<img src="multiple-idp-flow.png" alt="IdP selectie flow met alt scenarios" />

### Referenties

- [TOP-KT-007 - Koppeltaal Launch](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27131284)
- [TOP-KT-023 - Identity Provisioning](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27153689)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
- [SMART on FHIR App Launch](https://hl7.org/fhir/smart-app-launch/STU2.1/app-launch.html)
- [HTI 2.0](https://github.com/GIDSOpenStandaarden/GIDS-HTI-Protocol/blob/master/HTI.md)
