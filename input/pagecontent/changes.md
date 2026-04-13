### Changelog

Deze pagina bevat een overzicht van de wijzigingen per versie van de Koppeltaal 2.0 Implementation Guide.

### 0.16.2 (2026-04-02)

#### Hersteld
- **ValueSet IDs**: FHIR resource IDs van `endpoint-connection-type` en `audit-event-type` hernoemd naar `KT2-endpoint-connection-type` en `KT2-audit-event-type` om conflict met standaard FHIR R4 ValueSets in HAPI FHIR te voorkomen. Canonical URLs blijven ongewijzigd.
- **RelatedPerson example**: ID override verwijderd uit `relatedperson-nictiz-example` die botste met Nictiz dependency (`nl-core-ContactPerson-01-nictiz`), waardoor Simplifier geen package kon aanmaken.

### 0.16.1 (2026-03-26)

#### Gewijzigd
- **ValueSet expansions**: SNOMED CT Dutch edition (module 11000146104) geconfigureerd als bron voor expansions, met Nederlandse display-namen. NL extensiecodes (bijv. 310391000146105) worden nu opgenomen.

### 0.16.0 (2026-03-24)

Versie bump na merge PR #52 (profiel changes in 0.15.x).

### 0.15.5 (2026-03-13)

#### Gewijzigd
- **KT2CareTeam profiel**: `participant[patient]` op `0..0` gezet — de patiënt wordt altijd via `CareTeam.subject` gerepresenteerd, niet als participant

### 0.15.4 (2026-03-09)

#### Gewijzigd
- **CareTeam autorisatierollen**: Case Manager rol samengevoegd met Zorgondersteuner (leveranciersfeedback)
  - SNOMED code `768821004` (Care team coordinator) valt nu onder Zorgondersteuner autorisatieniveau
  - Twee Practitioner autorisatieniveaus: Behandelaar (`405623001`) en Zorgondersteuner (`224608005` + `768821004`)

### 0.15.3 (2026-02-18)

#### Hersteld
- **KT2CareTeam profiel**: SLICING_CANNOT_BE_EVALUATED validatiefouten opgelost door sub-slicing op role te verwijderen

#### Gewijzigd
- **KT2CareTeam profiel**: Custom KoppeltaalCareTeamRole CodeSystem vervangen door SNOMED CT codes (Nictiz review)
- **ValueSets**: KoppeltaalPractitionerRoleValueSet en KoppeltaalRelatedPersonRoleValueSet gebruiken nu SNOMED CT codes
- **Voorbeelden**: Alle CareTeam voorbeelden bijgewerkt met SNOMED CT rolcodes

### 0.15.2 (2026-02-17)

#### Gewijzigd
- **Autorisaties rol code mapping**: SNOMED CT codes bijgewerkt op basis van Nictiz review (Mirte)
  - Practitioner: Zorgondersteuner `224609002` → `224608005`, Case Manager `224608005` → `768821004`
  - RelatedPerson: Mantelzorger `224610006` → `407542009`, Wettelijk vertegenwoordiger `419358007` → `310391000146105`, Naaste `133932002` → `125677006`, Buddy `125680007` → `62071000`
  - Familierelaties bijgewerkt met correcte SNOMED concepten

### 0.15.1 (2026-01-27)

#### Hersteld
- **KT2_RelatedPerson profiel**: Typefout in `kt2-role-display-validation` invariant description hersteld

### 0.15.0 (2025-11-25)

Geen wijzigingen ten opzichte van 0.15.0-beta.9.

### 0.15.0-beta.9 (2025-10-30)

#### Gewijzigd
- **KT2_RelatedPerson profiel**: Display-validatie beperkt tot alleen codes 23 en 24
  - FHIRPath invariant `kt2-role-display-validation` valideert nu alleen COD472 codes 23 (Contactpersoon) en 24 (Wettelijke vertegenwoordiger)
  - Overige COD472 codes vereisen geen exacte display-matching meer

### 0.15.0-beta.8 (2025-10-28)

#### Hersteld
- **KT2_RelatedPerson profiel**: Exacte display-waarden afgedwongen voor COD472 rolcodes
  - FHIRPath invariant `kt2-role-display-validation` toegevoegd
  - **Breaking change**: Resources met incorrecte display-waarden worden nu afgewezen met 422 error

### 0.15.0-beta.7 (2025-10-23)

#### Hersteld
- **Choice type constraints**: FHIR validatiefouten opgelost voor `0..0` cardinaliteit op choice type elementen (KT2_Patient, KT2_ActivityDefinition)
- **Extension slicing conflicten**: "derived max cannot be greater than base max" fouten opgelost (KT2_AuditEvent, KT2_ActivityDefinition, KT2_Task)
- **NamingSystem ID**: Ontbrekend expliciet ID toegevoegd aan koppeltaal-client-id NamingSystem

### 0.15.0-beta.6 (2025-10-22)

#### Gewijzigd
- **KT2_ActivityDefinition profiel**: useContext slice hernoemd van `feature` naar `koppeltaal-expansion`

### 0.15.0-beta.5 (2025-10-21)

#### Gewijzigd
- **KT2_ActivityDefinition profiel**: useContext slice hernoemd van `feature` naar `koppeltaal-expansion`

### 0.15.0-beta.4 (2025-10-21)

#### Gewijzigd
- **Terminologie hernoemd**: Van "features" naar "expansion" terminologie
  - `KoppeltaalFeatures` CodeSystem → `KoppeltaalExpansion`
  - `KoppeltaalFeatures_VS` ValueSet → `KoppeltaalExpansion_VS`
  - URLs bijgewerkt van `koppeltaal-features` naar `koppeltaal-expansion`

### 0.15.0-beta.3 (2025-10-21)

#### Toegevoegd
- **KT2Task validatiedocumentatie**: Verplichte validatieregels voor Tasks met `Task.code = view`
- **KT2CareTeam validatiedocumentatie**: Verplichte validatieregels voor CareTeam operaties

### 0.15.0-beta.2 (2025-10-21)

#### Hersteld
- **KT2_ActivityDefinition useContext validatie**: Required binding toegevoegd voor expansion codes

#### Toegevoegd
- **ValueSet**: `KoppeltaalExpansion_VS` (http://vzvz.nl/fhir/ValueSet/koppeltaal-expansion)

### 0.15.0-beta.1 (2025-10-16)

#### Gewijzigd
- **Versieschema**: Gewijzigd van 1.4.5-beta.x naar 0.15.0-beta.x (semver compatibiliteit)
- **Nictiz dependencies**: Bijgewerkt van 0.11.0-beta.1 naar 0.12.0-beta.4

### 1.4.5-beta.012 (2025-10-14)

#### Hersteld
- **KT2_ActivityDefinition useContext.code binding**: Gewijzigd van `extensible` naar `required`

### 1.4.5-beta.011 (2025-10-09)

#### Hersteld
- **KoppeltaalUsageContextType_VS**: ValueSet gecorrigeerd om naar CodeSystem te verwijzen in plaats van een andere ValueSet

### 1.4.5-beta.010 (2025-10-07)

#### Toegevoegd
- **KoppeltaalFeatures**: Nieuw CodeSystem voor Koppeltaal-specifieke feature codes
- **Code 026-RolvdNaaste**: "Rol van de naaste" feature code

#### Gewijzigd
- **KoppeltaalUsageContext → KoppeltaalUsageContextType**: CodeSystem hernoemd conform FHIR naamgeving

#### Hersteld
- **Origin RuleSet**: Cardinaliteit voor `KT2_ResourceOrigin` extension gecorrigeerd van `0..*` naar `0..1`

### 1.4.5-beta.009 (2025-09-11)

#### Toegevoegd
- **KoppeltaalUsageContextType**: Nieuw CodeSystem voor custom usage context types
- **KoppeltaalUsageContextType_VS**: Nieuw ValueSet voor custom usage context types

#### Gewijzigd
- **KT2_ActivityDefinition**: Required binding toegevoegd voor useContext.code
