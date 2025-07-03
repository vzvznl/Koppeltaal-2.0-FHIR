
## Subject element

If the CareTeam is involved in the care of a specific patient, the subject element __MUST__ contain a reference to indicate that specific patient.

Otherwise the subject element remains absent.

## Participant Role

For a healthcare professional the only applicable slice of `CareTeam.participant` is the slice `kt2healthcareProfessional` 
This means the reference to the Practitioner should comply with the `KT2_Practitioner` profile.

For a RelatedPerson the applicable slice  of CareTeam.participant' is the slice 'kt2contactperson'
This means the reference to the RelatedPerson should comply with the 'KT2_RelatedPerson' profile.

The `practitioner.role` should comply to the codes defined in the ValueSet [ZorgverlenerRolCodelijst](https://simplifier.net/nictiz-r4-zib2020/2.16.840.1.113883.2.4.3.11.60.40.2.17.1.5--20200901000000).