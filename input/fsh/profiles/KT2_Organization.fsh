Profile: KT2_Organization
Parent: NlcoreHealthcareProviderOrganization
Id: KT2Organization
Description: "

## Overview

The Organization resource represents a formally or informally recognized grouping of people or organizations that collectively provide healthcare services. This includes healthcare providers, departments, community groups, and healthcare practice groups operating within the Koppeltaal ecosystem. The profile extends the NlcoreHealthcareProviderOrganization profile with Koppeltaal-specific requirements.

## Identifier

The `identifier` element is mandatory and should contain at least one identifier for the organization. Common identifiers include:
- AGB-Z (Algemeen GegevensBeheer Zorgverleners) codes
- KvK (Kamer van Koophandel) numbers
- Internal organization identifiers

Example:
```json
{
  \"identifier\": [{
    \"system\": \"http://fhir.nl/fhir/NamingSystem/agb-z\",
    \"value\": \"12345678\"
  }]
}
```

## Active

The `active` element is required and indicates whether the organization's record is in active use.

Values:
- `true` - Organization is active
- `false` - Organization is inactive/archived

## Name

The `name` element should contain the official name of the organization as it should be displayed.

## Type

Organization types should follow the nl-core organization type coding when applicable.

## Part Of

When an organization is part of a larger organization (e.g., a department within a hospital), the `partOf` element must reference another KT2_Organization resource.

Example:
```json
{
  \"partOf\": {
    \"reference\": \"Organization/parent-hospital\"
  }
}
```

## Endpoint

When specified, the `endpoint` element must reference KT2_Endpoint resources. This links the organization to its technical endpoints for service delivery.

Example:
```json
{
  \"endpoint\": [{
    \"reference\": \"Endpoint/org-endpoint-1\"
  }]
}
```

## Usage Notes

- Organizations in Koppeltaal represent both healthcare providers and organizational units that manage or provide eHealth services
- The organization hierarchy can be represented using the `partOf` element
- Active status should be maintained to reflect current operational status"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* extension ^slicing.discriminator.type = #value
  * ^slicing.discriminator.path = "url"
  * ^slicing.rules = #open
  * ^min = 0
* insert Origin
* identifier 1..
* active 1..
* alias ..0
* telecom ..0
* address ..0
* partOf only Reference(KT2_Organization)
* contact ..0
* endpoint ..0
* endpoint only Reference(KT2_Endpoint)