// The Task elements Koppeltaal does not use, shared by KT2_Task and
// KT2_DeletePendingTask.
//
// KT2_DeletePendingTask inherits from Task rather than KT2_Task, because KT2_Task
// closes statusReason and restriction and binds owner to human actors — all three of
// which the deletion announcement needs, and a derived profile can only narrow, never
// relax. Without this RuleSet the two lists would have to be kept in sync by hand, and
// an element added to one would be missed silently by the other.
//
// Elements only one of the two closes stay out of here: statusReason and restriction
// (closed by KT2_Task, used by KT2_DeletePendingTask) and description (the other way
// around).
RuleSet: UnusedTaskElements
* instantiatesUri ..0
* basedOn ..0
* groupIdentifier ..0
* businessStatus ..0
* focus ..0
* encounter ..0
* performerType ..0
* location ..0
* reasonCode ..0
* reasonReference ..0
* insurance ..0
* note ..0
* relevantHistory ..0
* input ..0
* output ..0
