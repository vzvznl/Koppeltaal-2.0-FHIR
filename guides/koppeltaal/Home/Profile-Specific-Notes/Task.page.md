---
topic: kt2task
---
# {{page-title}}

{{tree:http://koppeltaal.nl/fhir/StructureDefinition/KT2Task}}

## Reference to ActivityDefinition

<div class="warning">
<p><span>⚠️ Warning</span>&nbsp;As of 2023-11-02 the way the ActivityDefinition is referenced is changed!
</div>

A Task should refer to the `ActivityDefinition` it instantiates. This provides the possibility to search for Tasks that instantiate a specific instance of an `ActivityDefinition`, which in turn can be found based on its publisherId.

Using the element `instantiatesCanonical` does not however allow chaining of the search parameters. Therefore this profile contains an extension `instantiates` which should hold the reference to the instantiated `ActivityDefinition`.

The element `instantiatesCanonical` should not be used for this reference. Receivers of a Task instance can ignore any value in the `instantiatesCanonical` and should look for the referred `ActivityDefinition` in the `instantiates` extension.

## KT2_Task.owner
`KT2_Task.owner` bepaalt welke actor uitvoerder is van betreffende taak.

De `RelatedPerson` kan rechtstreeks als owner aan een taak worden toegekend of via een `CareTeam`.

```JSON
{
  "owner": {
    "reference": "RelatedPerson/${RelatedPersonId}",
    "display": "KT2 Related Person"
  }
}
```
 

```JSON
{
  "owner": {
    "reference": "CareTeam/${CareTeamId}",
    "display": "KT2 CareTeam"
  }
}
```

### Voorbeeld
Beneden een voorbeeld met als owner een `RelatedPerson`.

```JSON
{
    "resourceType" : "Task",
    "meta" : {
        "profile" : [
            "http://koppeltaal.nl/fhir/StructureDefinition/KT2Task"
        ]
    },
    "extension" : [
        {
            "url" : "http://vzvz.nl/fhir/StructureDefinition/instantiates",
            "valueReference" : {
                "reference" : "ActivityDefinition/8635519a-3ca5-4dc8-bd07-4ec1e7fefcd5",
                "type" : "ActivityDefinition"
            }
        }
    ],
    "identifier" : [
        {
            "use" : "official",
            "system" : "http:/vzvz.nl/Testtooling",
            "value" : "Vragenlijst${IdentifierValue}"
        }
    ],
    "description" : "Vul de vragenlijst zo goed mogelijk in. Dit kost ongeveer 10 minuten.",
    "partOf" : [{
        "reference" : "Task/1f2f427a-d7fd-4b91-809c-f4607365ce73",
        "type" : "Task"
    }],
    "for" : {
        "reference" : "Patient/810c315e-4720-4253-8369-1011f87691b6",
        "type" : "Patient"
    },
    "intent" : "order",
    "priority" : "routine",
    "code" : {
        "coding" : [
            {
                "system" : "http://vzvz.nl/fhir/CodeSystem/koppeltaal-task-code",
                "code" : "view",
                "display" : "This task can be viewed"
            }
        ]
    },
    "executionPeriod" : {
        "start" : "2024-07-20T08:25:05+02:00"
    },
    "requester" : {
        "reference" : "Practitioner/8849c230-5f03-4aab-83a0-8295dfc6000b",
        "type" : "Practitioner"
    },
    "owner" : {
        "reference" : "RelatedPerson/355651f0-2b28-4bf7-800d-0bbe4d96d793",
        "type" : "RelatedPerson"
    },
    "status" : "ready",
    "authoredOn" : "2024-07-30T08:25:05+02:00",
    "lastModified" : "2024-07-30T09:45:05+02:00"
}
```

## KT2_Task.partOf 
Met behulp van dit element wordt een subtaak aangemaakt. De hoofdtaak is is toegewezen aan de patient door `KT2_Task.owner`= `Reference (KT2_Patient)`. De subtaak wordt als volgt opgebouwd.
* De `KT2_Task.partOf` wijst naar de hoofdtaak.
* De `KT2_RelatedPerson` die meekijkt wordt de `Task.owner`
* De `KT2_Task.for` wijst naar de `Patient` van de hoofdtaak.

### Voorbeeld
In het voorbeeld hieronder staat een subtaak voor een `RelatedPerson` die gekoppeld is aan een `Task` van de patient.
```JSON
{
  "for": {
    "reference": "Patient/kt2-patient-example",
    "display": "KT2 Patient"
  },
  "owner": {
    "reference": "RelatedPerson/kt2-relatedperson-example",
    "display": "KT2 Related Person"
  },
  "description": "Sub task for the KI2 Patient performed by a related person.",
  "partof": [
    {
      "reference": "Task/kt2-maintask-example",
      "display": "Main Task"
    }
  ]
}
```

## KT2_Task.code

Met behulp van het `KT2_Task.code` element kan voor een `KT2_Task` de permissie op `view` worden gezet. Wat de exacte betekenis de `view` permissie is kan per applicatie verschillen, aangezien in koppeltaal 2.0 de autorisaties door de applicaties worden uitgevoerd.

```JSON
{
  "code": "view",
  "display": "This task can be viewed"
}
```
