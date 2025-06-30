Profile: KT2_ActivityDefinition
Parent: ActivityDefinition
Id: KT2ActivityDefinition
Description: "The (FHIR) ActivityDefinition (resource) describes an eHealth activity that is available for assignment to a patient. When assigning an eHealth activity to a patient, an eHealth Task is created, in which sub-activities are included as contained resources that refer to the main task via Task.partOf."
* ^version = "0.9.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* . ^short = "Description of an eHealth activity"
* . ^comment = "The (FHIR) ActivityDefinition describes an eHealth activity available to assign to a patient. The assignment of an eHealth activity to a patient creates an eHealth Task (Task resource). This task can contain sub activities as contained resources which refer to the main task using the Task.partOf element."
* insert Origin
* extension contains
    KT2_EndpointExtension named endpoint 1..* and
    KT2_PublisherId named publisherId 0..*
* extension[endpoint] ^short = "Endpoint to the service application"
  * ^definition = "Mandatory reference to the service application (endpoint) that provides the eHealth activity. Can be more than one endpoint."
* extension[publisherId] ^isModifier = false
* url 1..
* title 1..
* experimental ..0
* subject[x] ..0
* date ..0
* publisher ..0
* contact ..0
* useContext ..0
  * ^definition = "The context for the content of the eHealth activity"
  * ^comment = "E.g. the activity is targeted to a certain age group"
* jurisdiction ..0
* jurisdiction ^definition = "This element is not used"
* purpose ..0
* usage ..0
* copyright ..0
* approvalDate ..0
* lastReviewDate ..0
* effectivePeriod ..0
* topic from KoppeltaalDefinitionTopic_VS (extensible)
  * ^short = "E.g. Self-Treatment and Self-Assessment, etc."
  * ^definition = "Descriptive topics related to the content of the activity. The topic is used to indicate that the activity is intended or suitable for initialization by patients."
  * ^binding.description = "High-level categorization of the definition, used for indicating special patient initialised activities"
* author ..0
* editor ..0
* reviewer ..0
* endorser ..0
* relatedArtifact ..0
* library ..0
* kind ..0
* profile ..0
* intent ..0
* priority ..0
* doNotPerform ..0
* timing[x] ..0
* location ..0
* product[x] ..0
* quantity ..0
* dosage ..0
* bodySite ..0
* specimenRequirement ..0
* observationRequirement ..0
* observationResultRequirement ..0
* transform ..0
* dynamicValue ..0