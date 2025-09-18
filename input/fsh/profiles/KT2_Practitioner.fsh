Profile: KT2_Practitioner
Parent: NlcoreHealthProfessionalPractitioner
Id: KT2Practitioner
Description: "

## Overview

The Practitioner resource represents a healthcare professional who is directly or indirectly involved in the provision of patient care. This includes physicians, nurses, therapists, and other healthcare providers operating within the Koppeltaal ecosystem. The profile extends the NlcoreHealthProfessionalPractitioner profile, implementing Dutch Health Information Building Block (zib) standards.

## Identifier

The `identifier` element is mandatory and should contain at least one identifier for the practitioner. Common identifiers include:
- UZI (Unieke Zorgverlener Identificatie) number
- AGB (Algemeen GegevensBeheer) code
- BIG (Beroepen in de Individuele Gezondheidszorg) registration number
- Internal practitioner identifiers

Example:
```json
{
  \"identifier\": [{
    \"system\": \"http://fhir.nl/fhir/NamingSystem/uzi-nr-pers\",
    \"value\": \"12345678\"
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
  \"name\": [{
    \"use\": \"official\",
    \"family\": \"Jansen\",
    \"given\": [\"Peter\", \"J.\"]
  }]
}
```

## Telecom

The profile requires at least one email address in the `telecom[emailAddresses]` slice.

Example:
```json
{
  \"telecom\": [{
    \"system\": \"email\",
    \"value\": \"p.jansen@example.org\"
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
- The profile is designed to work within the Dutch healthcare context while maintaining FHIR compatibility"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* insert Origin
* identifier 1..
* active 1..
* name 1..
* name obeys kt2pnu-1
* name[nameInformation] ^sliceName = "nameInformation"
* name[nameInformation] ^comment = "This `.name` element represents a Dutch name according to the [zib NameInformation (v1.1, 2020)](https://zibs.nl/wiki/NameInformation-v1.1(2020EN)) (except for the GivenName concept). A Dutch name is represented in FHIR as an ordinary international name, but is augmented using extensions to specify how the last name is built up according to the Dutch rules. See the guidance on `.family` and on `.extension:nameUsage` for more information. Systems that need to work in a Dutch context **MUST** support these extensions as specified here. In addition, systems **MUST** use the core elements according to the FHIR specifications to provide compatibility outside Dutch contexts. It is encouraged to provide a representation of the full name in the `.text` element.\r\n\r\n**Note 1**: The zib cannot be represented straightforward in FHIR. Especially note the guidance on `.given` on how to map the FirstNames and Initials concepts, and on `.prefix`/`.suffix` on how to map the Titles concept.\r\n\r\n**Note 2**: This element should only contain a person's _official_ names. The GivenName concept is represented in another `.name` element with `.name.use` = _usual_.\r\n\r\n**Note 3**: The examples illustrate how the zib is mapped to FHIR."
  * extension[nameUsage] ^sliceName = "nameUsage"
    * insert notUsedKT2
  * text 
    * insert notUsedKT2
  * family 1..
  * given 1..
  * prefix 
    * insert notUsedKT2
  * suffix 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* name[nameInformation-GivenName]
  * text 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* telecom[telephoneNumbers]
  * extension[comment] ^sliceName = "comment"
    * insert notUsedKT2
  * use 
    * insert notUsedKT2
  * rank 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* telecom[emailAddresses] 1..
  * use 
    * insert notUsedKT2
  * rank 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* address ..0
* photo ..0
* qualification ..0
* communication ..0