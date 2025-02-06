---
topic: kt2relatedperson
---
# {{page-title}}

{{tree:http://koppeltaal.nl/fhir/StructureDefinition/KT2RelatedPerson}}

## KT2_RelatedPerson.relationship

The relationship(s) that the `Patient` has with the `RelatedPerson` can be documented using various code systems. Below, three examples are provided.

A `Patient` can maintain multiple relationship types with a `RelatedPerson`.

### Example:

```JSON
{
  "relationship": [
    {
      "coding": [
        {
          "system": "http://terminology.h17.org/Codesystem/v3-RoleCode",
          "code": "MTH",
          "display": "Mother"
        }
      ]
    },
    {
      "coding": [
        {
          "system": "urn:oid:2.16.840.1.113883.2.4.3.11.22.472",
          "code": "21",
          "display": "cliëntondersteuner"
        }
      ]
    }
  ]
}
```

The `KT2_RelatedPerson.patient` element contains the reference to the `Patient` to which the given `RelatedPerson` is linked. See the example below:

```JSON
{
  "patient": {
    "reference": "Patient/${PatientID}"
  }
}
```
