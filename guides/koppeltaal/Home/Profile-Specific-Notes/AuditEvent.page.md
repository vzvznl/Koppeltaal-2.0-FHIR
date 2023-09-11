---
topic: kt2auditevent
---
# {{page-title}}

{{tree:http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent}}

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

The ValueSet for this element contains codes from several Codesystems. See: [ValueSet AuditEvent Subtype](http://hl7.org/fhir/R4B/valueset-audit-event-sub-type.html)

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

The AuditEvent resource instance should always contain 2 agents, one for the source, one for the destination.

The `agent.network.address` is used to store the url of the source and the endpoint of the destination.