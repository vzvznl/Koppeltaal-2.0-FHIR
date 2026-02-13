ValueSet: KoppeltaalPractitionerRoleValueSet
Id: koppeltaal-practitioner-role
Title: "Koppeltaal Practitioner Role ValueSet"
Description: """
ValueSet voor Practitioner rollen binnen een CareTeam.

Breidt de ZorgverlenerRolCodelijst uit met Koppeltaal-specifieke autorisatierollen
voor Practitioners. Zie [Practitioner autorisaties](autorisaties-practitioner.html).
"""
* ^status = #active
* ^experimental = false
* ^date = 2026-02-12T12:00:00+01:00
* insert ContactAndPublisher
* ^url = "http://vzvz.nl/fhir/ValueSet/koppeltaal-practitioner-role"
* ^version = "0.2.0"

// Include bestaande ZorgverlenerRolCodelijst voor backwards compatibility
* include codes from valueset ZorgverlenerRolCodelijst

// Koppeltaal-specifieke Practitioner rollen
* $koppeltaal-careteam-role#behandelaar "Behandelaar"
* $koppeltaal-careteam-role#zorgondersteuner "Zorgondersteuner"
* $koppeltaal-careteam-role#case-manager "Case Manager"


ValueSet: KoppeltaalRelatedPersonRoleValueSet
Id: koppeltaal-relatedperson-role
Title: "Koppeltaal RelatedPerson Role ValueSet"
Description: """
ValueSet voor RelatedPerson relaties binnen een CareTeam.

Bevat Koppeltaal-specifieke relatie codes die de autorisaties bepalen voor
naasten van de patiënt. Zie [RelatedPerson autorisaties](autorisaties-relatedperson.html).
"""
* ^status = #active
* ^experimental = false
* ^date = 2026-02-12T12:00:00+01:00
* insert ContactAndPublisher
* ^url = "http://vzvz.nl/fhir/ValueSet/koppeltaal-relatedperson-role"
* ^version = "0.2.0"

// Koppeltaal-specifieke RelatedPerson relaties
* $koppeltaal-careteam-role#naaste "Naaste"
* $koppeltaal-careteam-role#mantelzorger "Mantelzorger"
* $koppeltaal-careteam-role#wettelijk-vertegenwoordiger "Wettelijk vertegenwoordiger"
* $koppeltaal-careteam-role#buddy "Buddy"
