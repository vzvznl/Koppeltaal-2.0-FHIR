Profile: KT2_DeletePendingTask
Parent: Task
Id: KT2DeletePendingTask
Description: "The KT2_DeletePendingTask profile represents the announcement that a patient's data within the Koppeltaal service is scheduled for definitive deletion. When the grace period starts, the Koppeltaal service creates one Task per (Patient × participating application); the Task is server-owned but readable by participating applications and carries the server-owned `kt2-delete-flow` security label (`meta.security`). The target application responds through the native Task lifecycle: `on-hold` as a temporary emergency brake and `accepted` as green light. The Task resides in the Patient compartment and is removed together with the Patient. See the page Opschoning Patient-data."
* ^version = "0.1.0"
* ^status = #draft
* ^date = "2026-07-09"
* insert ContactAndPublisher
* insert Origin
// The emergency-brake reason is bound to the on-hold status in both directions.
* obeys kt2-dpt-status-reason
// The security label is the access grant, so a Task without it is not part of the flow.
* obeys kt2-dpt-delete-flow-marker
// A deadline before the announcement would mean the grace period has already expired.
* obeys kt2-dpt-grace-deadline
// Fixed code; marks this as the announcement Task of the deletion process.
* code 1..1
* code from $koppeltaal-task-code-vs (required)
* code = $koppeltaal-task-code#delete-pending
  * ^short = "Type of the announcement Task"
// A fixed, planned deletion is being announced.
* intent = #order (exactly)
// Always server-set: the Koppeltaal service creates the Task, so the moment is always known.
* authoredOn 1..1
  * ^short = "Moment of the announcement; the grace period starts here"
// Only these five of the twelve R4 statuses occur in the deletion flow.
* status from $koppeltaal-delete-pending-task-status-vs (required)
* status ^comment = "Native Task lifecycle. The Koppeltaal service sets `requested` (announcement), `cancelled` (renewed patient engagement) and `completed` (deletion executed). The target application only sets `on-hold` (temporary emergency brake) or `accepted` (green light); the server validates every transition."
// The emergency-brake reason; explicitly allowed (unlike KT2_Task, where statusReason is 0..0).
* statusReason ^short = "Reason for the emergency brake when `status = on-hold`"
  * ^comment = "Coded, from a closed list; `text` is closed off so the reason itself is not a free-text field. It must not be used to convey demographics. Set by the target application in the status write to `on-hold`; the server clears it when `on-hold` is left. The reason lives on the Task only (per application) and is not carried in the aggregated deletion lifecycle AuditEvents."
* statusReason from $koppeltaal-delete-hold-reason-vs (required)
// Exactly one reason: the closed list has no second terminology to translate into.
* statusReason.coding 1..1
* statusReason.coding.display ^short = "Human-readable description of the emergency-brake reason"
* statusReason.text 0..0
// Closed down to the same surface as KT2_Task, the house standard for a Task in this
// IG. Parent is Task rather than KT2_Task, so the shared UnusedTaskElements RuleSet
// carries that list. The two KT2_Task closes that this profile needs stay open: statusReason
// for the emergency-brake reason and restriction for the grace deadline. description
// is closed on top of that set, because these Tasks reach applications holding no
// Task read right at all and the coded statusReason should be the only reason
// recorded on them.
* insert UnusedTaskElements
* description 0..0
// The Patient being deleted; places the Task in the Patient compartment.
* for 1..1
* for only Reference(KT2_Patient)
  * ^short = "The Patient whose data is scheduled for deletion"
* owner 1..1
* owner only Reference(KT2_Device)
  * ^short = "The target application this announcement is directed at"
  * ^comment = "Always a Device. Never the Patient or a RelatedPerson, because a Task owned by the patient counts as patient engagement and would reset the retention clock."
* requester 1..1
* requester only Reference(KT2_Device)
  * ^short = "The Koppeltaal service announcing the deletion"
* restriction 1..1
* restriction.period 1..1
* restriction.period.end 1..1
  * ^short = "Grace deadline: the planned moment of definitive deletion"
  * ^comment = "Server-managed: on a grace reset the Koppeltaal service sets a new deadline; applications never modify this element."
