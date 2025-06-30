Extension: KT2_Instantiates
Id: instantiates
Description: "Extension added to a Task to refer to the ActivityDefinition which is instantiated by this Task"
Context: Task
* ^url = "http://vzvz.nl/fhir/StructureDefinition/instantiates"
* ^status = #draft
* insert ContactAndPublisher
* value[x] 1..
* value[x] only Reference(KT2_ActivityDefinition)
  * ^short = "Reference to a KT2ActivityDefinition"
  * ^definition = "Use this reference rather than the element `Task.instantiatesCanonical` to refer to the ActivityDefinition which is instantiated by this Task."