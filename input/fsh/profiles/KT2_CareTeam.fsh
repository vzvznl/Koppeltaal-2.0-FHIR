Profile: KT2_CareTeam
Parent: NlcoreCareTeam
Description: "The CareTeam resource represents a group of healthcare professionals and related persons who collaborate to provide coordinated care and treatment for a patient. It defines the roles and participants involved in delivering healthcare services within the Koppeltaal ecosystem."
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
* participant[kt2contactperson].role ^slicing.discriminator.type = #value
* participant[kt2contactperson].role ^slicing.discriminator.path = "$this"
* participant[kt2contactperson].role ^slicing.rules = #open
* participant[kt2contactperson].role ^comment = "The role defines the authorization level for this RelatedPerson within the CareTeam. See [RelatedPerson autorisaties](autorisaties-relatedperson.html) for the permission matrix."
* participant[kt2contactperson].role contains kt2Role 0..1
* participant[kt2contactperson].role[kt2Role] from KoppeltaalRelatedPersonRoleValueSet (extensible)
* participant[kt2contactperson].role[kt2Role] ^definition = "The authorization role of the RelatedPerson within this CareTeam. Determines which actions this person may perform."
* participant[kt2contactperson].role[kt2Role] ^binding.description = "Koppeltaal authorization roles for RelatedPersons in a CareTeam."
* participant[kt2contactperson].member only Reference(KT2_RelatedPerson)
* participant[kt2contactperson].onBehalfOf ^comment = "This element is not used in the context of Koppeltaal 2.0"
* participant[kt2contactperson].period ^comment = "This element is not used in the context of Koppeltaal 2.0"
* participant[kt2healthcareProfessional].role ^slicing.discriminator.type = #value
* participant[kt2healthcareProfessional].role ^slicing.discriminator.path = "$this"
* participant[kt2healthcareProfessional].role ^slicing.rules = #open
* participant[kt2healthcareProfessional].role ^comment = "The role defines the authorization level for this Practitioner within the CareTeam. See [Practitioner autorisaties](autorisaties-practitioner.html) for the permission matrix."
* participant[kt2healthcareProfessional].role contains healthProfessionalRole 0..1
* participant[kt2healthcareProfessional].role[healthProfessionalRole] from KoppeltaalPractitionerRoleValueSet (extensible)
* participant[kt2healthcareProfessional].role[healthProfessionalRole] ^definition = "The authorization role of the Practitioner within this CareTeam. Determines which actions this person may perform. This ValueSet extends the ZorgverlenerRolCodelijst with Koppeltaal-specific authorization roles."
* participant[kt2healthcareProfessional].role[healthProfessionalRole] ^comment = "For authorization purposes, use the Koppeltaal-specific codes (behandelaar, zorgondersteuner, case-manager). The ZorgverlenerRolCodelijst codes are included for backwards compatibility.\r\n\r\nSee [Rol Code Mapping](autorisaties-rol-code-mapping.html) for more information."
* participant[kt2healthcareProfessional].role[healthProfessionalRole] ^alias = "KoppeltaalPractitionerRole"
* participant[kt2healthcareProfessional].role[healthProfessionalRole] ^binding.description = "Koppeltaal authorization roles for Practitioners in a CareTeam (extends ZorgverlenerRolCodelijst)."
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
