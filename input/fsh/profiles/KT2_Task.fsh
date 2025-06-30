Profile: KT2_Task
Parent: Task
Id: KT2Task
Description: "The (FHIR) Task (resource) describes an eHealth task, that is, an eHealth activity assigned to a patient."
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