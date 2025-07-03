# RelatedPerson

The `RelatedPerson` resource is a new actor in the Koppeltaal Standard. A `RelatedPerson` can represent various individuals, such as the following roles and relationships:

* Parent or Guardian
* Authorized Representative
* Care Supporter

The `RelatedPerson.relationship` element specifies this relationship. The `RelatedPerson.patient` element contains the reference to the `Patient` for whom the actor is a `RelatedPerson`.

A `RelatedPerson` can perform tasks on behalf of the `Patient`, assist with the `Patient's` tasks, or view them. In addition, the `Patient` and `Practitioner` have the ability to revoke a `RelatedPerson's` access to a task that was assigned to the `RelatedPerson`.

Below is a description of the elements involved in executing tasks, viewing, and revoking access.

## Executing a Task by the RelatedPerson

When a `RelatedPerson` executes a task and starts it via a launch:
1. The owner of the `Task` can be a `RelatedPerson`:
`Task.owner` = `Reference (KT2_RelatedPerson)`
`Task.for` = `Reference (KT2_Patient)`
2. The owner of the `Task` can also be a `CareTeam` where:
    - `CareTeam.subject` = `Reference (KT2_Patient)`
    - `CareTeam.participant.member` = `Reference (KT2_RelatedPerson)`
    - `RelatedPerson.patient` = `Reference (KT2_Patient)`
    - `CareTeam.subject` = `RelatedPerson.patient`.

These conditions must be verified by the launching application.

## Viewing and Supporting a Task of the Patient
The following conditions are necessary for a `RelatedPerson` to view a task of the `Patient`:
1. The task that the `RelatedPerson` performs should be a sub-task of the main task being performed by the patient:
    - `Task.partOf` = `Reference (K2_Task)`
    - `Task.owner` = `Reference (KT2_RelatedPerson)`
    - `Task.code` = `view`.

## Revoking Authorization for a Task to be Performed by a RelatedPerson

To make it clear that a `RelatedPerson` is no longer authorized to perform or view a task, the following options are available:
1. `Task.status` = `cancelled`
2. `RelatedPerson.active` = `0` (inactive)
3. `CareTeam.participant.kt2contactperson` is removed from the `CareTeam`.


For more information on this profile see also [KT2RelatedPerson](StructureDefinition-KT2RelatedPerson.html)
