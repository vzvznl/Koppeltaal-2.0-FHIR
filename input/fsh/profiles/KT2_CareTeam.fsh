Profile: KT2_CareTeam
Parent: NlcoreCareTeam
Description: "The care team of a patient that aids the patient in his/her treatment"
Id: KT2CareTeam
* ^url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
* ^version = "0.9.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* insert Origin
* identifier 1..
* status 1..
* category ..0
* subject 1..
* subject only Reference(KT2_Patient)
  * ^short = "Patient treated by this care team"
* encounter ..0
* participant ^comment = "WARNING: `allSlices` is a display bug in Simplifier.net. There is no `allSlices` slice. Firely is already notified of this bug."
* participant[contactPerson] ..0
* participant[patient].member only Reference(KT2_Patient)
* participant[patient].onBehalfOf ^comment = "This element is not used in the context of Koppeltaal 2.0"
* participant[patient].period ^comment = "This element is not used in the context of Koppeltaal 2.0"
* participant[healthcareProfessional] ..0
* participant[healthcareProfessional] ^comment = "This slice is not used in the context of Koppeltaal 2.0"
* participant contains
 kt2contactperson 0..* and
 kt2healthcareProfessional 0..*
* participant[kt2contactperson].member only Reference(KT2_RelatedPerson)
* participant[kt2contactperson].onBehalfOf ^comment = "This element is not used in the context of Koppeltaal 2.0"
* participant[kt2contactperson].period ^comment = "This element is not used in the context of Koppeltaal 2.0"
* participant[kt2healthcareProfessional].role ^slicing.discriminator.type = #value
* participant[kt2healthcareProfessional].role ^slicing.discriminator.path = "$this"
* participant[kt2healthcareProfessional].role ^slicing.rules = #open
* participant[kt2healthcareProfessional].role ^comment = "See [Koppeltaal Implementation Guide](https://simplifier.net/guide/koppeltaal/Home/Profile-Specific-Notes/CareTeam.page.md?version=current) for more information on the ValueSet of the role."
* participant[kt2healthcareProfessional].role contains healthProfessionalRole 0..1
* participant[kt2healthcareProfessional].role[healthProfessionalRole] from ZorgverlenerRolCodelijst (required)
* participant[kt2healthcareProfessional].role[healthProfessionalRole] ^definition = "The role the health professional fulfils in the healthcare process. For health professionals, this could be for example attender, referrer or performer."
* participant[kt2healthcareProfessional].role[healthProfessionalRole] ^comment = "Roles may sometimes be inferred by type of Practitioner.  These are relationships that hold only within the context of the care team.  General relationships should be handled as properties of the Patient resource directly.\r\n\r\nFor more information see: [Koppeltaal Implementation Guide](https://simplifier.net/guide/koppeltaal/Home/Profile-Specific-Notes/CareTeam.page.md?version=current)"
* participant[kt2healthcareProfessional].role[healthProfessionalRole] ^alias = "ZorgverlenerRolCodelijst"
* participant[kt2healthcareProfessional].role[healthProfessionalRole] ^binding.description = "The role the health professional fulfils in the healthcare process."
* participant[kt2healthcareProfessional].member only Reference(KT2_Practitioner)
* participant[kt2healthcareProfessional].member ^comment = "This element is used in Koppeltaal 2.0 to refer to the Practitioner who is member of the team"
* participant[kt2healthcareProfessional].onBehalfOf ^comment = "This element is not used in the context of Koppeltaal 2.0"
* participant[kt2healthcareProfessional].period ^comment = "This element is not used in the context of Koppeltaal 2.0"

* reasonCode ..0
* reasonReference ..0
* managingOrganization ..1
* managingOrganization only Reference(KT2_Organization)
* telecom ..0
* note ..0
