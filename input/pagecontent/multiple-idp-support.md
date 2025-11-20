# Multiple IdP Support

## Beschrijving

Deze pagina beschrijft de ondersteuning voor meerdere Identity Providers (IdPs) per gebruikerstype binnen een Koppeltaal domein. Deze functionaliteit maakt het mogelijk om per launch aan te geven bij welke IdP de gebruiker geauthenticeerd moet worden.

### Use case

Als platform die Koppeltaal 2.0 launches uitvoert, wil ik in de launch kunnen aangeven waar de gebruiker geauthenticeerd moet worden, zodat er per gebruiker een andere IdP gebruikt kan worden. Dit maakt het bijvoorbeeld mogelijk om onderscheid te maken tussen:

- RelatedPersons die DigiD moeten gebruiken (wettelijk vertegenwoordigers)
- RelatedPersons die een andere authenticatiemethode gebruiken (mantelzorgers via organisatie-IdP)

### Relatie met bestaande functionaliteit

Deze functionaliteit is een uitbreiding op de bestaande [Identity Provisioning](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27153689) configuratie. Waar voorheen per combinatie van domein, applicatie-instantie en gebruikerstype maximaal één IdP geconfigureerd kon worden (0..1), wordt dit uitgebreid naar meerdere IdPs (0..*).

## Overwegingen

### Waarom geen `id_token_hint`?

Initieel werd overwogen om de OIDC `id_token_hint` parameter te gebruiken om de gewenste IdP aan te geven. Na analyse is besloten dit niet te doen om de volgende redenen:

#### Security risico's
Een `id_token` wordt gemaakt en ondertekend door een IdP. De inhoud kan persoonlijk identificeerbare informatie (PII) bevatten zoals `email`, `name`, `picture`. Wanneer dit token wordt meegestuurd in de launch:
- Belandt deze informatie in ingress-logs
- Verschijnt in Application Performance Monitoring (APM) traces
- Kan onderschept worden bij misconfiguratie

#### AVG compliance
Het meesturen van onnodige PII voldoet niet aan artikel 5 van de AVG:
> "De persoonsgegevens dienen toereikend en ter zake dienend te zijn en beperkt te blijven tot wat noodzakelijk is voor de doeleinden waarvoor zij worden verwerkt."

#### OIDC semantische mismatch
Binnen OIDC wordt de `id_token_hint` gebruikt in scenario's waar de `sub` claim relevant is (bijvoorbeeld voor re-authenticatie van dezelfde gebruiker). In ons geval is de `sub` niet relevant; we willen alleen aangeven welke IdP gebruikt moet worden. Dit veroorzaakt verwarring over de bedoelde werking.

#### Toekomstbestendigheid
Mocht er in de toekomst ondersteuning komen voor andere authenticatiemechanismen dan OIDC, dan is er een grote kans dat deze geen `id_token` heeft om mee te geven als `id_token_hint`.

#### Extra complexiteit
Er moeten onduidelijke regels opgesteld worden voor edge cases, zoals: wordt een verlopen `id_token_hint` geaccepteerd?

### Waarom wel een custom `idp_hint` claim?

De gekozen oplossing is een custom claim `idp_hint` in het HTI launch token:

- **Duidelijke intentie**: De claim geeft expliciet aan waar de waarde voor dient
- **Ondertekend door lancerend platform**: Het HTI token is ondertekend, dus de `idp_hint` is betrouwbaar zonder extra JWT
- **Geen PII**: Bevat alleen een identifier van de IdP, geen persoonsgegevens
- **Toekomstbestendig**: Onafhankelijk van het authenticatiemechanisme van de IdP

### Inhoud van het idp_hint veld

De exacte waarde van het `idp_hint` veld wordt bepaald door de combinatie van domeinbeheer en autorisatie service. Het is aan deze partijen om af te stemmen welk formaat gebruikt wordt voor de IdP identifier. De volgende opties zijn mogelijk:

- **Issuer URL**: De issuer (`iss`) uit het IdP token, bijvoorbeeld: `https://idp.example.com/idp1/`
- **Database referentie**: Een interne database referentie, bijvoorbeeld: `c7fe7029-5a5d-47b4-b8a5-e35f04a633b7`
- **Logische identifier**: Een logisch toegekende identifier, bijvoorbeeld: `idp-relatedperson-oidc`

De lancerende applicatie dient de juiste waarde te verkrijgen via domeinbeheer of de bijbehorende documentatie.

## Toepassing, restricties en eisen

### Technische implementatie

De technische flow voor het gebruik van de `idp_hint` is als volgt:

1. **Aanmelding bij lancerende applicatie**: De gebruiker meldt zich aan bij de lancerende applicatie. Als dit met OIDC gebeurt, komt hier een `id_token` uit voort.

2. **Toevoegen idp_hint aan HTI token**: Tijdens de launch wordt aan het HTI token het veld `idp_hint` toegevoegd. De waarde van de `idp_hint` wordt bepaald door de combinatie van domeinbeheer en autorisatie service (zie "Inhoud van het idp_hint veld" in de overwegingen).

3. **Ontvangst door gelanceerde applicatie**: De gelanceerde applicatie (module) ontvangt de launch en start de SMART on FHIR app launch flow met de autorisatie service.

4. **Verwerking door autorisatie service**: De autorisatie service ontvangt het HTI token in de `launch` parameter en vindt daarin het `idp_hint` veld. Vervolgens past de autorisatie service de logica zoals beschreven in het onderdeel "IdP resolutie algoritme" toe.

#### Bepaling idp_hint waarde

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

#### Domeinbeheer configuratie

In domeinbeheer moet de volgende functionaliteit beschikbaar zijn:

1. **Meerdere IdPs per gebruikerstype**: Per combinatie van domein, applicatie-instantie en gebruikerstype (Patient, Practitioner, RelatedPerson) kunnen 0..* IdPs geconfigureerd worden
2. **Volgordelijke lijst**: De geselecteerde IdPs worden in een volgordelijke lijst beheerd
3. **Default IdP**: De eerste IdP in de lijst is de default
4. **IdP identifier**: Het moet eenvoudig zijn om de IdP identifier te kopiëren voor gebruik in de `idp_hint` claim
5. **Backwards compatible**: Bestaande 0..1 configuraties blijven werken

#### IdP resolutie algoritme

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

#### AuditEvent logging

Bij een misconfiguratie van de IdP (bijvoorbeeld een ongeldige `idp_hint`) moet een AuditEvent aangemaakt worden. Dit valt onder de bestaande AuditEvent logging voor authenticatie (type 110114, User Authentication).

#### Backwards compatibility

- Bestaande configuraties met 0..1 IdP blijven ongewijzigd werken
- Launch tokens zonder `idp_hint` worden verwerkt als voorheen
- **Gefaseerde uitrol**: Wanneer de autorisatie service en domeinbeheer Multiple IdP Support ondersteunen, maar de lancerende applicatie nog geen `idp_hint` meestuurt, is het fallback scenario van toepassing. De autorisatie service gebruikt dan automatisch de eerste (default) IdP uit de geconfigureerde lijst. Dit maakt een gefaseerde uitrol mogelijk waarbij applicaties op hun eigen tempo kunnen worden bijgewerkt.

### Gebruikte standaarden

- **OpenID Connect (OIDC)**: Voor communicatie met de Identity Provider
- **SMART on FHIR App Launch**: Framework voor de launch flow
- **HTI 2.0**: Health Tool Interoperability voor het launch token
- **JWT (RFC 7519)**: JSON Web Token voor ondertekening van het HTI token

### Eisen

#### Functionele eisen

1. Per gebruikerstype kunnen meerdere IdPs geconfigureerd worden
2. De volgorde van IdPs is aanpasbaar in domeinbeheer
3. De eerste IdP in de lijst is de default
4. De `idp_hint` claim in het launch token wordt herkend door de autorisatie service
5. Bij een ongeldige `idp_hint` wordt fallback naar default uitgevoerd
6. Misconfiguraties worden gelogd als AuditEvent

## Interactiediagrammen

### Happy flow: Launch met geldige idp_hint

<img src="multiple-idp-happy-flow.png" alt="Happy flow: Launch met geldige idp_hint" />

### Unhappy flow: Launch met ongeldige idp_hint

<img src="multiple-idp-invalid-hint.png" alt="Unhappy flow: Launch met ongeldige idp_hint" />

### Launch zonder idp_hint (meerdere IdPs geconfigureerd)

<img src="multiple-idp-no-hint.png" alt="Launch zonder idp_hint" />

## Referenties

- [TOP-KT-007 - Koppeltaal Launch](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27131284)
- [TOP-KT-023 - Identity Provisioning](https://vzvz.atlassian.net/wiki/spaces/KTSA/pages/27153689)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
- [SMART on FHIR App Launch](https://hl7.org/fhir/smart-app-launch/STU2.1/app-launch.html)
- [HTI 2.0](https://github.com/GIDSOpenStandaarden/GIDS-HTI-Protocol/blob/master/HTI.md)
