
#### Relationship

The relationship(s) that the `Patient` has with the `RelatedPerson` can be documented using various code systems. A `Patient` can maintain multiple relationship types with a `RelatedPerson`.

Example:
```json
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

#### Patient Reference

The `patient` element contains the reference to the `Patient` to which the given `RelatedPerson` is linked:

```json
{
  "patient": {
    "reference": "Patient/${PatientID}"
  }
}
```

#### Required Elements

The following elements are mandatory:
- `identifier` - At least one identifier for the related person
- `active` - Indicates whether the record is in active use
- `patient` - Reference to the associated KT2_Patient
- `relationship` - At least one relationship code
- `name` - Name information following Dutch conventions
- `gender` - Gender of the related person
- `birthDate` - Birth date of the related person

#### Validation Warnings

Due to an issue with the FHIR profile, validation warnings may be generated for the `KT2_RelatedPerson` resource:

> This element does not match any known slice defined in the profile

These warnings should be ignored when the creation or update of the resource is successful. Focus on actual errors in the `OperationOutcome` resource rather than these informational warnings.
