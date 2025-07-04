---
topic: kt2practitioner
---
# {{page-title}}

{{tree:http://koppeltaal.nl/fhir/StructureDefinition/KT2Practitioner}}

## Overview

The Practitioner resource represents a person who is directly or indirectly involved in the provision of healthcare. This profile is based on the NlcoreHealthProfessionalPractitioner profile, which implements the Dutch Health Information Building Block (zib) for healthcare professionals.

## Identifier

The `identifier` element is mandatory and should contain at least one identifier for the practitioner. Common identifiers include:
- UZI (Unieke Zorgverlener Identificatie) number
- AGB (Algemeen GegevensBeheer) code
- BIG (Beroepen in de Individuele Gezondheidszorg) registration number
- Internal practitioner identifiers

Example:
```json
{
  "identifier": [{
    "system": "http://fhir.nl/fhir/NamingSystem/uzi-nr-pers",
    "value": "12345678"
  }]
}
```

## Active

The `active` element is required and indicates whether the practitioner's record is in active use.

Values:
- `true` - Practitioner is active
- `false` - Practitioner is no longer active

## Name

The `name` element is mandatory and follows Dutch naming conventions. At least one name must be provided with:
- A required `family` element
- At least one `given` element

The profile includes specific slices for Dutch name information:
- `nameInformation` - Official names according to Dutch conventions
- `nameInformation-GivenName` - Usual/calling names

Important constraints:
- The profile includes the constraint `kt2pnu-1` on names
- Various extensions like `nameUsage` are marked as not used in KT2
- The `text`, `prefix`, `suffix`, and `period` elements are not used in the nameInformation slice

Example:
```json
{
  "name": [{
    "use": "official",
    "family": "Jansen",
    "given": ["Peter", "J."]
  }]
}
```

## Telecom

The profile requires at least one email address in the `telecom[emailAddresses]` slice.

Example:
```json
{
  "telecom": [{
    "system": "email",
    "value": "p.jansen@example.org"
  }]
}
```

For telephone numbers (`telecom[telephoneNumbers]`), the following elements are not used:
- `extension[comment]`
- `use`
- `rank`
- `period`

## Elements Not Used

The following elements are explicitly excluded in this profile:
- `address` - Practitioner addresses are not used
- `photo` - Practitioner photos are not used

## Usage Notes

- This profile strictly follows Dutch healthcare naming and identification standards
- Email contact is mandatory for all practitioners
- The profile is designed to work within the Dutch healthcare context while maintaining FHIR compatibility