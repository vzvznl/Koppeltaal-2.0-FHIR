
#### Subject element

If the CareTeam is involved in the care of a specific patient, the subject element __MUST__ contain a reference to indicate that specific patient.

Otherwise the subject element remains absent.

#### Participant Role

For a healthcare professional the only applicable slice of `CareTeam.participant` is the slice `kt2healthcareProfessional`
This means the reference to the Practitioner should comply with the `KT2_Practitioner` profile.

For a RelatedPerson the applicable slice  of CareTeam.participant' is the slice 'kt2contactperson'
This means the reference to the RelatedPerson should comply with the 'KT2_RelatedPerson' profile.

The `practitioner.role` should comply to the codes defined in the ValueSet [ZorgverlenerRolCodelijst](https://simplifier.net/nictiz-r4-zib2020/2.16.840.1.113883.2.4.3.11.60.40.2.17.1.5--20200901000000).

#### Validation: CareTeam operations

When performing an action related to a CareTeam, applications must verify that the CareTeam has a relationship with the associated patient and that the CareTeam is active. This is necessary because the status and participants of a CareTeam change over time. This validation must be performed for all operations involving a CareTeam. This includes but is not limited to:

- Assigning digital interventions to a CareTeam participant
- Opening digital interventions by a CareTeam participant
- Notifying CareTeam participants of events

**Applications MUST validate that:**
- `CareTeam.subject` equals the associated `Patient`
- `CareTeam.status = active`
- If `CareTeam.period` is populated, the current date-time must fall within this period

If these validations fail, the application **MUST NOT** perform the operation.
