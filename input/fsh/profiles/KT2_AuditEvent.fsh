Profile: KT2_AuditEvent
Parent: AuditEvent
Id: KT2AuditEvent
Description: "

## Overview

The AuditEvent resource is used to consolidate and track logging information within the Koppeltaal ecosystem. It captures details about system activities, data access, and interactions between applications for security and compliance purposes.

## AuditEvent.type

For the `type` element the generic VZVZ ValueSet for this element is used. This set contains only the relevant codes from the DICOM CodeSystem as used in Koppeltaal. The other Codesystems contain the remaining codes.

Note: for the code `transmit` use

```json
{
    \"system\": \"http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle\",
    \"code\": \"transmit\"
}
```

## AuditEvent.subtype

The ValueSet for this element contains codes from several Codesystems. See: [ValueSet AuditEvent Subtype](http://hl7.org/fhir/R4B/valueset-audit-event-sub-type.html)

For FHIR actions such as `read`, `search` and `create`, use the codes from the CodeSystem `http://hl7.org/fhir/restful-interaction`. Example:

```json
{
    \"system\": \"http://hl7.org/fhir/restful-interaction\",
    \"code\": \"search\"
}
```

For interactions related to application launches and such use codes from the DICOM CodeSystem. Example (Application Start):

```json
{
    \"system\": \"http://dicom.nema.org/resources/ontology/DCM\",
    \"code\": \"110120\"
}
```

## Agent

The AuditEvent resource instance should always contain at least 2 agents, one for the source, one for the destination.

If necessary the patient to which this event relates can be added as a third agent. For examples see the section _Agent.type_.

The `agent.network.address` is used to store the url of the source and the endpoint of the destination.

### Agent.type

For the `type` element the generic VZVZ ValueSet for this element is used. This set contains only the relevant codes from the DICOM CodeSystem as used in Koppeltaal. The other Codesystems contain the remaining codes.

As mentioned above, there are several agent elements, one for the source, one for the destination and one that refers to the patient. The examples below only show the relevant elements of `agent`, not the full set.

_source_
```json
{
  \"agent\": [
    {
      \"type\": {
        \"coding\": {
          \"system\": \"http://dicom.nema.org/resources/ontology/DCM\",
          \"code\": \"110153\"
        }
      },
      \"requestor\": \"true\"
    }
  ]
}
```

_destination_
```json
{
  \"agent\": [
    {
      \"type\": {
        \"coding\": {
          \"system\": \"http://dicom.nema.org/resources/ontology/DCM\",
          \"code\": \"110152\"
        }
      },
      \"requestor\": \"false\"
    }
  ]
}
```

_patient_
```json
{
  \"agent\": [
    {
      \"type\": {
        \"coding\": {
          \"system\": \"http://terminology.hl7.org/CodeSystem/v3-RoleClass\",
          \"code\": \"PAT\"
        }
      },
      \"requestor\": \"false\"
    }
  ]
}
```

## Entity.type

For this element, from the ValueSet only use the CodeSystem [ResourceType](https://simplifier.net/packages/hl7.fhir.r4.core/4.0.1/files/81127) to indicate which FHIR Resource type was used. Example:

```json
{
    \"system\": \"http://hl7.org/fhir/resource-types\",
    \"code\": \"CareTeam\"
}
```
"
* ^version = "0.10.0"
* ^status = #draft
* ^date = "2023-01-31"
* insert ContactAndPublisher
* insert Origin
* insert Tracing
* type from $audit-event-type-vs (extensible)
  * insert docAuditEvent
* subtype 
  * insert docAuditEvent
* purposeOfEvent ..0
* agent
  * type 1..
  * type from ParticipationRoleType (extensible)
    * insert docAuditEvent
  * role
    * insert notUsedKT2
  * who 1..
  * who only Reference(KT2_Device)
  * altId ..0
  * name ..0
  * location ..0
  * policy ..0
  * media ..0
  * purposeOfUse ..0
* source
  * site ^definition = "Domainname of the observer"
  * observer only Reference(KT2_Device)
    * ^definition = "Reporter that creates the event"
* entity 1..
  * type 
    * insert docAuditEvent
  * lifecycle
    * insert notUsedKT2
  * securityLabel
    * insert notUsedKT2
  * query ^comment = "Warning: name and query are mutually exclusive. Use query to register the full query, including parameters."
  * detail ..0