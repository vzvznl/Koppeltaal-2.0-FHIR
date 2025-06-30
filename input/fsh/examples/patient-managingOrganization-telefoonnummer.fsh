Instance: patient-managingOrganization-telefoonnummer
InstanceOf: Patient
Description: "Example of a Patient with a telephone number and managing organization"
Usage: #example
* meta.profile = "http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a Patient with a telephone number and managing organization</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://irma.app"
  * value = "bertabotje01@vzvz.nl"
* active = true
* name[0]
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
  * system = #phone
    * extension
      * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
      * valueCodeableConcept = $v3-AddressUse#MC "mobile contact"
  * value = "+31611234567"
  * use = #home
* gender = #female
  * extension
    * url = "http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification"
    * valueCodeableConcept.coding = $v3-AdministrativeGender#F "Female"
* birthDate = "1972-11-12"
* managingOrganization = Reference(organization-minimaal)
  * type = "Organization"