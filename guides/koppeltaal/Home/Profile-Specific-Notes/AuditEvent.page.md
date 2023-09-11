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
## Agent

The AuditEvent resource instance should always contain 2 agents, one for the source, one for the destination.

The `agent.network.address` is used to store the url of the source and the endpoint of the destination.