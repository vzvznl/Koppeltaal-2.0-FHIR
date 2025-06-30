
## Reference to ActivityDefinition

<div class="dragon">
<p>As of 2023-11-02 the way the ActivityDefinition is referenced is changed!</p>
</div>


A Task should refer to the `ActivityDefinition` it instantiates. This provides the possibility to search for Tasks that instantiate a specific instance of an `ActivityDefinition`, which in turn can be found based on its publisherId.

Using the element `instantiatesCanonical` does not however allow chaining of the search parameters. Therefore this profile contains an extension `instantiates` which should hold the reference to the instantiated `ActivityDefinition`.

The element `instantiatesCanonical` should not be used for this reference. Receivers of a Task instance can ignore any value in the `instantiatesCanonical` and should look for the referred `ActivityDefinition` in the `instantiates` extension.

## KT2_Task.owner
`KT2_Task.owner` determines which actor is the executor of the respective task.

The `RelatedPerson` can be assigned as the owner of a task either directly or through a `CareTeam`.

## KT2_Task.partOf 
This element is used to indicate the reference of a subtask to the main task.
The main task is assigned to the patient through `KT2_Task.owner`= `Reference (KT2_Patient)`. 
The subtask is created as follows:
* KT2_Task.partOf` references the main task
* The `KT2_RelatedPerson` who assists becomes the `Task.owner`
* KT2_Task.for` references the `Patient` of the main task

## KT2_Task.code

With the `KT2_Task.code` element the permission of a `KT2_Task` can be set to `view`. 
The exact meaning of the `view` permission can differ per application because authorisations in 
Koppeltaal 2.0 are defined and executed by the applications.

### Example
This example shows a subtask for the `RelatedPerson` assigned in the `Task` of the patient.



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
