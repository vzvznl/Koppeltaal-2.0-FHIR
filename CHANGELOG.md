CHANGELOG

## 0.15.5 (2026-03-13)

### Gewijzigd
- **KT2CareTeam profiel**: `participant[patient]` op `0..0` gezet — de patiënt wordt altijd via `CareTeam.subject` gerepresenteerd, niet als participant

## 0.15.4 (2026-03-09)

### Gewijzigd
- **CareTeam autorisatierollen**: Case Manager rol samengevoegd met Zorgondersteuner (leveranciersfeedback)
  - SNOMED code `768821004` (Care team coordinator) valt nu onder Zorgondersteuner autorisatieniveau
  - Twee Practitioner autorisatieniveaus: Behandelaar (`405623001`) en Zorgondersteuner (`224608005` + `768821004`)
  - Voorbeelden, profiel en autorisatiepagina's bijgewerkt

## 0.15.3 (2026-02-18)

### Hersteld
- **KT2CareTeam profiel**: Role sub-slicing verwijderd om SLICING_CANNOT_BE_EVALUATED validatiefouten op te lossen; ValueSet binding nu direct op `participant.role`

### Gewijzigd
- **KT2CareTeam profiel**: Custom KoppeltaalCareTeamRole CodeSystem vervangen door SNOMED CT codes (Nictiz review)
- **ValueSets**: KoppeltaalPractitionerRoleValueSet en KoppeltaalRelatedPersonRoleValueSet gebruiken nu SNOMED CT codes
- **Voorbeelden**: Alle CareTeam voorbeelden bijgewerkt met SNOMED CT rolcodes

## 0.15.2 (2026-02-17)

### Gewijzigd
- **Autorisaties rol code mapping**: SNOMED CT codes bijgewerkt op basis van Nictiz review (Mirte)
  - Practitioner: Zorgondersteuner `224609002` → `224608005`, Case Manager `224608005` → `768821004` (Care team coordinator)
  - RelatedPerson: Mantelzorger `224610006` → `407542009` (Informal carer), Wettelijk vertegenwoordiger `419358007` → `310391000146105`, Naaste `133932002` → `125677006` (Relative), Buddy `125680007` → `62071000` (Buddy)
  - Familierelaties bijgewerkt met correcte SNOMED concepten (`303071001`, `40683002`, `67822003`, `262043009`, `375005`, `113163005`)
  - Open vragen over Nederlandse extensie en granulariteit opgelost (reviewed door Nictiz)

## 0.15.1 (2026-01-27)

### Hersteld
- **KT2_RelatedPerson profiel**: Typefout in `kt2-role-display-validation` invariant description hersteld
  - "role codes 21 and 24" gewijzigd naar "role codes 23 and 24" conform de daadwerkelijke validatie-expressie

## 0.15.0 (2025-11-25)

Geen wijzigingen ten opzichte van 0.15.0-beta.9.

## 0.15.0-beta.9 (2025-10-30)

### Gewijzigd
- **KT2_RelatedPerson profiel**: Display-validatie beperkt tot alleen codes 23 en 24
  - FHIRPath invariant `kt2-role-display-validation` valideert nu alleen COD472 codes 23 (Contactpersoon) en 24 (Wettelijke vertegenwoordiger)
  - Overige COD472 codes (01-22, 25-99) vereisen geen exacte display-matching meer
  - Vermindert onderhoudslast terwijl kritieke businessregels voor de twee meest gebruikte rolcodes behouden blijven
  - Profielcommentaren bijgewerkt ter verduidelijking van validatiescope en rationale

## 0.15.0-beta.8 (2025-10-28)

### Hersteld
- **KT2_RelatedPerson profiel**: Exacte display-waarden afgedwongen voor COD472 rolcodes
  - FHIRPath invariant `kt2-role-display-validation` toegevoegd die display-waarden valideert tegen CodeSystem definities
  - Valideert alle 16 COD472 code/display paren uit de Nictiz ValueSet (urn:oid:2.16.840.1.113883.2.4.3.11.22.472)
  - Geeft ERROR (niet alleen warning) bij onjuiste display-waarden
  - Valideert alleen COD472 codes; v3-RoleCode (HL7 internationale codes) blijven soepel
  - **Breaking change**: Resources met incorrecte display-waarden worden nu afgewezen met 422 error

## 0.15.0-beta.7 (2025-10-23)

### Hersteld
- **Choice type constraints**: FHIR validatiefouten opgelost bij het beperken van choice type elementen tot 0 cardinaliteit
  - KT2_Patient: `deceased[x]` en `multipleBirth[x]` gebruiken nu expliciete `0..0` cardinaliteit met `[x]` suffix
  - KT2_ActivityDefinition: `subject[x]`, `timing[x]` en `product[x]` gebruiken nu expliciete `0..0` cardinaliteit met `[x]` suffix
- **Extension slicing conflicten**: "derived max cannot be greater than base max" fouten opgelost
  - KT2_AuditEvent: resource-origin, traceId, correlationId en requestId extensions samengevoegd in één declaratie
  - KT2_ActivityDefinition: resource-origin, endpoint en publisherId extensions samengevoegd in één declaratie
  - KT2_Task: resource-origin en instantiates extensions samengevoegd in één declaratie
- **NamingSystem ID**: Ontbrekend expliciet ID toegevoegd aan koppeltaal-client-id NamingSystem

### Gewijzigd
- Ongebruikte Tracing ruleset verwijderd uit rulesets.fsh (extensions worden nu direct in profielen gedeclareerd)

## 0.15.0-beta.6 (2025-10-22)

### Gewijzigd
- **KT2_ActivityDefinition profiel**: useContext slice hernoemd van `feature` naar `koppeltaal-expansion`

## 0.15.0-beta.5 (2025-10-21)

### Gewijzigd
- **KT2_ActivityDefinition profiel**: useContext slice hernoemd van `feature` naar `koppeltaal-expansion`
  - Sluit aan bij de expansion-terminologie geïntroduceerd in 0.15.0-beta.4

## 0.15.0-beta.4 (2025-10-21)

### Gewijzigd
- **Terminologie hernoemd**: Van "features" naar "expansion" terminologie
  - `KoppeltaalFeatures` CodeSystem → `KoppeltaalExpansion`
  - URL gewijzigd van `http://vzvz.nl/fhir/CodeSystem/koppeltaal-features` naar `http://vzvz.nl/fhir/CodeSystem/koppeltaal-expansion`
  - `KoppeltaalFeatures_VS` ValueSet → `KoppeltaalExpansion_VS`
  - URL gewijzigd van `http://vzvz.nl/fhir/ValueSet/koppeltaal-features` naar `http://vzvz.nl/fhir/ValueSet/koppeltaal-expansion`
  - Beschrijvingen gewijzigd van "Required features or capabilities" naar "Optional expansions"
- **KT2_ActivityDefinition profiel**: useContext[feature] documentatie bijgewerkt
  - Gewijzigd van "Required feature or capability" naar "Optional expansion"

## 0.15.0-beta.3 (2025-10-21)

### Toegevoegd
- **KT2Task validatiedocumentatie**: Verplichte validatieregels voor Tasks met alleen-lezen rechten (`Task.code = view`)
  - Task moet `Task.partOf` bevatten
  - `Task.partOf` moet verwijzen naar een Task zonder `Task.code`
  - `Task.for` moet gelijk zijn aan de `Task.for` van de verwezen Task
- **KT2CareTeam validatiedocumentatie**: Verplichte validatieregels voor CareTeam operaties
  - `CareTeam.subject` moet gelijk zijn aan de bijbehorende Patient
  - `CareTeam.status` moet `active` zijn
  - Indien `CareTeam.period` aanwezig is, moet het validatiemoment binnen de periode vallen

### Gewijzigd
- Dubbelzinnige opmerking uit KT2Task documentatie verwijderd over dat de betekenis van `view` per applicatie kan verschillen

## 0.15.0-beta.2 (2025-10-21)

### Hersteld
- **KT2_ActivityDefinition useContext validatie**: Required binding toegevoegd voor expansion codes in useContext.valueCodeableConcept
  - `KoppeltaalExpansion_VS` ValueSet aangemaakt om expansion codes te valideren
  - Slicing op `useContext` geïmplementeerd om op code type te discrimineren
  - `feature` slice met required binding naar `KoppeltaalExpansion_VS` toegevoegd

### Toegevoegd
- **ValueSet**: `KoppeltaalExpansion_VS` (http://vzvz.nl/fhir/ValueSet/koppeltaal-expansion)

## 0.15.0-beta.1 (2025-10-16)

**Let op: versieschema gewijzigd van 1.4.5-beta.x naar 0.15.0-beta.x voor semver compatibiliteit**

### Gewijzigd
- **Versieschema**: Gewijzigd van 1.4.5-beta.012 naar 0.15.0-beta.1
- **Nictiz dependencies**: Bijgewerkt van 0.11.0-beta.1 naar 0.12.0-beta.4
  - Lost snapshot-generatiefouten op met zib-AddressInformation tijdens HAPI FHIR package installatie
  - Zowel `nictiz.fhir.nl.r4.zib2020` als `nictiz.fhir.nl.r4.nl-core` bijgewerkt

## 1.4.5-beta.012 (2025-10-14)

### Hersteld
- **KT2_ActivityDefinition useContext.code binding**: Gewijzigd van `extensible` naar `required` om ongeldige context type codes te voorkomen
- **activitydefinition-with-participant voorbeeld**: CodeSystem URL gecorrigeerd voor useContext.valueCodeableConcept
- **activitydefinition-standard-usecontext voorbeeld**: CodeSystem URL gecorrigeerd voor useContext.code met feature type

### Toegevoegd
- **Test case voor ongeldige useContext**: Negatieve test case `invalid-usecontext-invalid-codes` toegevoegd

## 1.4.5-beta.011 (2025-10-09)

### Hersteld
- **KoppeltaalUsageContextType_VS**: ValueSet gecorrigeerd om naar CodeSystem te verwijzen in plaats van een andere ValueSet
  - Lost HAPI FHIR server installatiefout op: "Unable to expand ValueSet because CodeSystem could not be found"

## 1.4.5-beta.010 (2025-10-07)

### Toegevoegd
- **KoppeltaalFeatures**: Nieuw CodeSystem voor Koppeltaal-specifieke feature codes (http://vzvz.nl/fhir/CodeSystem/koppeltaal-features)
- **Code 026-RolvdNaaste**: "Rol van de naaste" feature code
- **activitydefinition-standard-usecontext**: Nieuw voorbeeld met standaard FHIR useContext naast Koppeltaal-specifieke uitbreidingen

### Gewijzigd
- **KoppeltaalUsageContext → KoppeltaalUsageContextType**: CodeSystem hernoemd conform FHIR naamgeving
  - Canonical URL gewijzigd van `koppeltaal-usage-context` naar `koppeltaal-usage-context-type`
- **KoppeltaalUsageContext_VS → KoppeltaalUsageContextType_VS**: ValueSet hernoemd conform CodeSystem
- **KT2_ActivityDefinition**: useContext binding bijgewerkt naar hernoemde ValueSet
- **ActivityDefinition voorbeelden**: Extension gebruik gerefactord van numerieke indices naar benoemde slice referenties (`endpoint`, `publisherId`)

### Hersteld
- **Origin RuleSet**: Cardinaliteit voor `KT2_ResourceOrigin` extension gecorrigeerd van `0..*` naar `0..1`

## 1.4.5-beta.009 (2025-09-11)

### Toegevoegd
- **KoppeltaalUsageContextType**: Nieuw CodeSystem voor custom usage context types (http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context-type)
- **KoppeltaalUsageContextType_VS**: Nieuw ValueSet voor custom usage context types (http://vzvz.nl/fhir/ValueSet/koppeltaal-usage-context-type)

### Gewijzigd
- **KT2_ActivityDefinition**: Required binding toegevoegd voor useContext.code naar KoppeltaalUsageContextType_VS
- **ActivityDefinition voorbeelden**: Bijgewerkt met nieuwe useContext structuur

## 1.4.5-beta.008 (2025-09-10)

### Gewijzigd
- **KT2_ActivityDefinition**: useContext element geactiveerd met required binding naar KoppeltaalUsageContext ValueSet
- **KT2_ActivityDefinition**: useContext.value[x] beperkt tot alleen CodeableConcept

### Toegevoegd
- **KoppeltaalUsageContext**: Nieuw CodeSystem voor usage context waarden (http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context)
- **KoppeltaalUsageContext_VS**: Nieuw ValueSet voor usage context waarden (http://vzvz.nl/fhir/ValueSet/koppeltaal-usage-context)
- **Code 026-RolvdNaaste**: "Rol van de naaste" — maakt het mogelijk dat naasten participeren in het zorgtraject van de patiënt
