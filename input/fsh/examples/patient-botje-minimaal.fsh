Instance: patient-botje-minimaal
InstanceOf: Patient
Description: "Bare minimum of Patient elements populated"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2Patient"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Bare minimum of Patient elements populated</div>"
* insert NLlang
* identifier[0]
  * use = #usual
  * system = "http://local/systeemnaamuitgave"
  * value = "BerendBotje-01"
* identifier[+]
  * use = #official
  * system = "http://irma.app"
  * value = "berendbotje01@vzvz.nl"
* active = true
* name
  * use = #official
  * text = "Berend Botje"
  * family = "Botje"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
      * valueString = "Botje"
  * given = "Berend"
    * extension
      * url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
      * valueCode = #BR
* telecom
  * system = #email
  * value = "berendbotje01@vzvz.nl"
  * use = #home
* gender = #male
  * extension
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
    * valueCodeableConcept = $v3-AdministrativeGender#M "Male"
* birthDate = "1970-12-20"