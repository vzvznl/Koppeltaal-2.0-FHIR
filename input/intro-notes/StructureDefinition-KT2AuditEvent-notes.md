
## AuditEvent.type

For the `type` element the generic VZVZ ValueSet for this element is used. This set contains only the relevant codes from the DICOM CodeSystem as used in Koppeltaal. The other Codesystems contain the remaining codes.

Note: for the code `transmit` use

```json
{
    "system": "http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle",
    "code": "transmit
}
```

## AuditEvent.subtype

The ValueSet for this element contains codes from several Codesystems. See: [ValueSet AuditEvent Subtype](http://hl7.org/fhir/ValueSet/audit-event-sub-type)

For FHIR actions such as `read`, `search` and `create`, use the codes from the CodeSystem `http://hl7.org/fhir/restful-interaction`. Example:

```json
{
    "system": "http://hl7.org/fhir/restful-interaction",
    "code": "search"
}
```

For interactions related to application launches and such use codes from the DICOM CodeSystem. Example (Application Start):

```json
{
    "system": "http://dicom.nema.org/resources/ontology/DCM",
    "code": "110120"
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
"agent": [
    {
        "type": {
            "coding": {
                "system": "http://dicom.nema.org/resources/ontology/DCM",
                "code": "110153"
            }
        },
        "requestor": "true"
    }
]
```

_destination_
```json
"agent": [
    {
        "type": {
            "coding": {
                "system": "http://dicom.nema.org/resources/ontology/DCM",
                "code": "110152"
            }
        },
        "requestor": "false"
    }
]
```

_patient_
```json
"agent": [
    {
        "type": {
            "coding": {
                "system": "http://terminology.hl7.org/CodeSystem/v3-RoleClass",
                "code": "PAT"
            }
        },
        "requestor": "false"
    }
]
```

## Entity.type

For this element, from the ValueSet only use the CodeSystem [ResourceType](http://hl7.org/fhir/resource-types) to indicate which FHIR Resource type was used. Example:

```json
{
    "system": "http://hl7.org/fhir/resource-types",
    "code": "CareTeam"
}
```
