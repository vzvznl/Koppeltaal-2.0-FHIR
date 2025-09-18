Profile: KT2_Task
Parent: Task
Id: KT2Task
Description: "

## Overview

The Task resource represents an eHealth activity that has been assigned to a specific patient. It tracks the lifecycle of patient assignments, from initial creation through completion, and may include subtasks for complex multi-step interventions. Tasks are created based on ActivityDefinition resources and managed throughout their execution within the Koppeltaal ecosystem.

## Reference to ActivityDefinition

**Warning**: As of 2023-11-02 the way the ActivityDefinition is referenced has changed!

A Task should refer to the `ActivityDefinition` it instantiates. This provides the possibility to search for Tasks that instantiate a specific instance of an `ActivityDefinition`, which in turn can be found based on its publisherId.

Using the element `instantiatesCanonical` does not allow chaining of the search parameters. Therefore this profile contains an extension `instantiates` which should hold the reference to the instantiated `ActivityDefinition`.

The element `instantiatesCanonical` should not be used for this reference. Receivers of a Task instance can ignore any value in the `instantiatesCanonical` and should look for the referred `ActivityDefinition` in the `instantiates` extension.

## Owner

`KT2_Task.owner` determines which actor is the executor of the respective task.

The `RelatedPerson` can be assigned as the owner of a task either directly or through a `CareTeam`.

## PartOf

This element is used to indicate the reference of a subtask to the main task.
The main task is assigned to the patient through `KT2_Task.owner` = `Reference(KT2_Patient)`.
The subtask is created as follows:
- `KT2_Task.partOf` references the main task
- The `KT2_RelatedPerson` who assists becomes the `Task.owner`
- `KT2_Task.for` references the `Patient` of the main task

## Code

With the `KT2_Task.code` element the permission of a `KT2_Task` can be set to `view`.
The exact meaning of the `view` permission can differ per application because authorisations in
Koppeltaal 2.0 are defined and executed by the applications.

## Example

Example showing a subtask for the `RelatedPerson` assigned in the `Task` of the patient:

```json
{
    \"resourceType\" : \"Task\",
    \"meta\" : {
        \"profile\" : [
            \"http://koppeltaal.nl/fhir/StructureDefinition/KT2Task\"
        ]
    },
    \"extension\" : [
        {
            \"url\" : \"http://vzvz.nl/fhir/StructureDefinition/instantiates\",
            \"valueReference\" : {
                \"reference\" : \"ActivityDefinition/8635519a-3ca5-4dc8-bd07-4ec1e7fefcd5\",
                \"type\" : \"ActivityDefinition\"
            }
        }
    ],
    \"identifier\" : [
        {
            \"use\" : \"official\",
            \"system\" : \"http:/vzvz.nl/Testtooling\",
            \"value\" : \"Vragenlijst${IdentifierValue}\"
        }
    ],
    \"description\" : \"Vul de vragenlijst zo goed mogelijk in. Dit kost ongeveer 10 minuten.\",
    \"partOf\" : [{
        \"reference\" : \"Task/1f2f427a-d7fd-4b91-809c-f4607365ce73\",
        \"type\" : \"Task\"
    }],
    \"for\" : {
        \"reference\" : \"Patient/810c315e-4720-4253-8369-1011f87691b6\",
        \"type\" : \"Patient\"
    },
    \"intent\" : \"order\",
    \"priority\" : \"routine\",
    \"code\" : {
        \"coding\" : [
            {
                \"system\" : \"http://vzvz.nl/fhir/CodeSystem/koppeltaal-task-code\",
                \"code\" : \"view\",
                \"display\" : \"This task can be viewed\"
            }
        ]
    },
    \"executionPeriod\" : {
        \"start\" : \"2024-07-20T08:25:05+02:00\"
    },
    \"requester\" : {
        \"reference\" : \"Practitioner/8849c230-5f03-4aab-83a0-8295dfc6000b\",
        \"type\" : \"Practitioner\"
    },
    \"owner\" : {
        \"reference\" : \"RelatedPerson/355651f0-2b28-4bf7-800d-0bbe4d96d793\",
        \"type\" : \"RelatedPerson\"
    },
    \"status\" : \"ready\",
    \"authoredOn\" : \"2024-07-30T08:25:05+02:00\",
    \"lastModified\" : \"2024-07-30T09:45:05+02:00\"
}
```"
* ^version = "0.8.1"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* insert Origin
* . ^definition = "An eHealth activity assigned to a patient."
* extension contains
    KT2_Instantiates named instantiates 0..*
* extension[instantiates] ^short = "Reference to ActivityDefinition"
  * ^definition = "Reference to the ActivityDefinition, which conforms to the KT2_ActivityDefinition profile."
  * ^comment = "Use this extension to refer to the ActivityDefinition it instantiates."
  * ^isModifier = false
* identifier 1..
* instantiatesCanonical only Canonical(KT2_ActivityDefinition)
  * ^comment = "As of 2023-11-02 this element is no longer used in Koppeltaal 2.0. Use the extension `instantiates` instead."
* instantiatesUri ..0
* basedOn ..0
* groupIdentifier ..0
* partOf only Reference(KT2_Task)
* statusReason ..0
* businessStatus ..0
* priority = #routine (exactly)
* code from $koppeltaal-task-code-vs (preferred)
* code ^comment = "See [Koppeltaal Implementation Guide](https://simplifier.net/guide/koppeltaal/Home/Profile-Specific-Notes/Task.page.md?version=current) for more information on the ValueSet"
* focus ..0
* for 1..
* for only Reference(KT2_Patient)
  * ^definition = "The patient who benefits from the performance of the service specified in the task."
  * ^comment = "In Koppeltaal this element always refers to the patient for whom the task is intended."
  * ^requirements = "Used to track tasks outstanding for a beneficiary.  Do not use to track the task owner or creator (see owner and creator respectively).  This _can_ also affect access control."
* encounter ..0
* requester only Reference(KT2_Practitioner)
  * ^definition = "In Koppeltaal this element contains a reference to the person requesting the eHealth Task"
* performerType ..0
* owner 1..
* owner only Reference(KT2_CareTeam or KT2_Patient or KT2_Practitioner or KT2_RelatedPerson)
  * ^definition = "Practitioner, CareTeam, RelatedPerson or Patient currently responsible for task execution."
  * ^comment = "In Koppeltaal the patient is usually the person who executes the task.\r\n\r\nNote, this element is not intended to be used for access restriction. That is left to the relevant applications."
* location ..0
* reasonCode ..0
* reasonReference ..0
* insurance ..0
* note ..0
* relevantHistory ..0
* restriction ..0
* input ..0
* output ..0