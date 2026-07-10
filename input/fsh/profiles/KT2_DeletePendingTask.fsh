Profile: KT2_DeletePendingTask
Parent: Task
Id: KT2DeletePendingTask
Title: "KT2 Delete Pending Task"
Description: "The KT2_DeletePendingTask profile represents the announcement that a patient's data within the Koppeltaal service is scheduled for definitive deletion. When the grace period starts, the Koppeltaal service creates one Task per (Patient × participating application); the Task is server-owned but readable by participating applications and carries the server-owned `kt2-delete-flow` security label (`meta.security`). The target application responds through the native Task lifecycle: `on-hold` as a temporary emergency brake and `accepted` as green light. The Task resides in the Patient compartment and is removed together with the Patient. See the page Opschoning Patient-data."
* ^version = "0.1.0"
* ^status = #draft
* ^date = "2026-07-09"
* insert ContactAndPublisher
* insert Origin
// Fixed code; marks this as the announcement Task of the deletion process.
* code = $koppeltaal-task-code#delete-pending
  * ^short = "Type of the announcement Task"
// A fixed, planned deletion is being announced.
* intent = #order (exactly)
* status ^comment = "Native Task lifecycle. The Koppeltaal service sets `requested` (announcement), `cancelled` (renewed patient engagement) and `completed` (deletion executed). The target application only sets `on-hold` (temporary emergency brake) or `accepted` (green light); the server validates every transition."
// The emergency-brake reason; explicitly allowed (unlike KT2_Task, where statusReason is 0..0).
* statusReason ^short = "Reason for the emergency brake when `status = on-hold`"
  * ^comment = "Coded, without demographics or free text. Set by the target application in the status write to `on-hold`; the server clears it when `on-hold` is left. The reason lives on the Task only (per application) and is not carried in the aggregated deletion lifecycle AuditEvents."
* statusReason from $koppeltaal-delete-hold-reason-vs (required)
* statusReason.coding 1..
* statusReason.coding.display 1..
  * ^short = "Human-readable description of the emergency-brake reason"
* statusReason.text 0..0
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
