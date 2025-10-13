Instance: patient-met-resource-origin
InstanceOf: Patient
Description: "Example of Patient with resource origin extension populated"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Patient"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of Patient with resource origin extension populated</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "https://irma.app"
  * value = "bertabotje01@vzvz.nl"
* active = true
* name
  * use = #official
  * text = "Berta Botje"
  * family = "Botje"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-partner-name"
      * valueString = "Botje"
  * given = "Berta"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #BR
* telecom
  * system = #email
  * value = "bertabotje01@vzvz.nl"
  * use = #home
* gender = #female
  * extension
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
    * valueCodeableConcept.coding = $v3-AdministrativeGender#F "Female"
* birthDate = "1972-11-12"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"