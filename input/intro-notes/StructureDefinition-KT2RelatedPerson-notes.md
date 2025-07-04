
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
          "display": "Cliëntondersteuner"
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

## Unexpected validation Warnings
<div class="dragon">

Due to an issue with the FHIR profile, the following validation warnings are generated for the `KT2_RelatedPerson` resource:

> This element does not match any known slice defined in the profile http://koppeltaal.nl/fhir/StructureDefinition/KT2RelatedPerson|0.xx.xx

This information notification is ignored when the creation or update of the resource is successful. However at the moment a resource contains an error, this information warning shows up in the `OperationOutcome`, potentially confusing / obfuscating the process of error assessment. We advise to ignore this _warning_ and focus on the _error_ in the `OperationOutcome` resource. 

Despite the effort to get this notification removed, the implementation team has not succeeded in removing the information notification. 
