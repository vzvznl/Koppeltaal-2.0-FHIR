// Compares the references as written: a relative and an absolute reference to the same
// Patient count as different. References with only an identifier are not checked.
Invariant: kt2-task-patient-owner
Description: "If owner is a Patient, it must be the same Patient as for. Another patient executes the Task as a RelatedPerson."
Severity: #error
Expression: "owner.where(reference.contains('Patient/')).exists() implies (for.reference.exists() and for.reference = owner.reference)"
