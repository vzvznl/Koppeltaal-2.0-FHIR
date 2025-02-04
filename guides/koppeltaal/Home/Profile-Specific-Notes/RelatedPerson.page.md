---
topic: kt2relatedperson
---
# {{page-title}}

{{tree:http://koppeltaal.nl/fhir/StructureDefinition/KT2RelatedPerson}}

## KT2_RelatedPerson.relationship 
De relatie(s) die Patient heeft met de RelatedPerson kan aan de hand van verschillende code systems worden vastgelegd, hieronder worden 3-tal voorbeelden worden getoond.

De Patient kan meerdere relatie types onderhouden met RelatedPerson.

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
          "system": "urn:oid:2.16.840.1.113883.2.4.3.11.22.472"
          "code": "21",
          "display": "cliëntondersteuner"
        }
      }
      ]
    }
  }
```

De KT2_RelatedPerson.Patient element bevat de referentie naar Patient waar betreffende patient aan gekoppeld is.  Zie hiervoor onderstaand voorbeeld: 

```JSON
{
  "patient" : {
    "reference" : "Patients/{PatientID}"
  }
  
}
```
