ValueSet: KoppeltaalPractitionerRoleValueSet
Id: koppeltaal-practitioner-role
Title: "Koppeltaal Practitioner Role ValueSet"
Description: """
ValueSet voor Practitioner rollen binnen een CareTeam.

Breidt de ZorgverlenerRolCodelijst uit met SNOMED CT codes voor Koppeltaal
autorisatierollen. Zie [Practitioner autorisaties](autorisaties-practitioner.html).

De SNOMED codes zijn gereviewd door Nictiz.
"""
* ^status = #active
* ^experimental = false
* ^date = 2026-02-17T12:00:00+01:00
* insert ContactAndPublisher
* ^url = "http://vzvz.nl/fhir/ValueSet/koppeltaal-practitioner-role"
* ^version = "0.3.0"

// Include bestaande ZorgverlenerRolCodelijst voor backwards compatibility
* include codes from valueset ZorgverlenerRolCodelijst

// SNOMED CT codes voor Koppeltaal autorisatierollen (gereviewd door Nictiz)
* $sct#405623001 "Assigned practitioner (occupation)"
* $sct#224608005 "Administrative healthcare staff (occupation)"
* $sct#768821004 "Care team coordinator (occupation)"


ValueSet: KoppeltaalRelatedPersonRoleValueSet
Id: koppeltaal-relatedperson-role
Title: "Koppeltaal RelatedPerson Role ValueSet"
Description: """
ValueSet voor RelatedPerson relaties binnen een CareTeam.

Bevat SNOMED CT codes die de autorisaties bepalen voor naasten van de patiënt.
Zie [RelatedPerson autorisaties](autorisaties-relatedperson.html).

De SNOMED codes zijn gereviewd door Nictiz.
"""
* ^status = #active
* ^experimental = false
* ^date = 2026-02-17T12:00:00+01:00
* insert ContactAndPublisher
* ^url = "http://vzvz.nl/fhir/ValueSet/koppeltaal-relatedperson-role"
* ^version = "0.3.0"

// SNOMED CT codes voor RelatedPerson autorisatierollen (gereviewd door Nictiz)
* $sct#407542009 "Informal carer (person)"
* $sct#310391000146105 "Legal representative (person)"
* $sct#125677006 "Relative (person)"
* $sct#62071000 "Buddy (person)"
