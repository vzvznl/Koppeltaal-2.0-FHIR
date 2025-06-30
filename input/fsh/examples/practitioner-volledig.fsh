Instance: practitioner-volledig
InstanceOf: Practitioner
Description: "Example of Practitioner with all elements populated"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Practitioner"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of Practitioner with all elements populated</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://fhir.nl/fhir/NamingSystem/big"
  * value = "11223344556"
* active = true
* name
  * use = #official
  * text = "Kees Jongen"
  * family = "Jongen"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
      * valueString = "Jongen"
  * given = "Kees"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #BR
* telecom
  * system = #email
  * value = "kees.jongen@therapieland.nl"
  * use = #work
* gender = #unknown
  * extension
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
    * valueCodeableConcept.coding = $v3-NullFlavor#UNK "Unknown"
* birthDate = "1990-12-12"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"