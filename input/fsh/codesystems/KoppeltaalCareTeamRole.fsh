CodeSystem: KoppeltaalCareTeamRole
Id: koppeltaal-careteam-role
Title: "Koppeltaal CareTeam Participant Role"
Description: """
CodeSystem voor het vastleggen van rollen binnen een CareTeam in Koppeltaal 2.0.

Deze rollen worden gebruikt voor autorisatiedoeleinden en bepalen welke permissies
een deelnemer heeft binnen de context van een specifiek CareTeam. De permissies per
rol zijn beschreven in de autorisatiematrices:
- [Practitioner autorisaties](autorisaties-practitioner.html)
- [RelatedPerson autorisaties](autorisaties-relatedperson.html)

**Let op:** Deze codes representeren autorisatierollen, niet beroepen of klinische functies.
Een verpleegkundige kan bijvoorbeeld de rol 'behandelaar' hebben in het ene CareTeam
en 'zorgondersteuner' in een ander CareTeam.

Wanneer een deelnemer geen code uit dit CodeSystem heeft, vallen de permissies terug
op minimale rechten (zie de autorisatiematrices).
"""
* ^status = #active
* ^content = #complete
* ^date = 2026-02-12T12:00:00+01:00
* insert ContactAndPublisher
* ^url = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-careteam-role"
* ^version = "0.2.0"
* ^experimental = false
* ^caseSensitive = true
* ^hierarchyMeaning = #grouped-by
* ^property[+].code = #notSelectable
* ^property[=].type = #boolean
* ^property[=].description = "Indicates that the code is not intended to be chosen as a value by the user"

// =============================================================================
// Practitioner rollen
// =============================================================================

* #practitioner "Practitioner rollen" "Parent categorie voor alle Practitioner rollen binnen een CareTeam"
  * ^property[0].code = #notSelectable
  * ^property[=].valueBoolean = true

* #practitioner #behandelaar "Behandelaar"
    "Behandelend zorgverlener met volledige toegang tot patiënten in hun CareTeams.
    Heeft CRUD rechten op taken van patiënten en kan taken starten."

* #practitioner #zorgondersteuner "Zorgondersteuner"
    "Ondersteunende rol (inclusief administratief medewerkers).
    Kan taken klaarzetten voor patiënten maar kan deze niet zelf starten."

* #practitioner #case-manager "Case Manager"
    "Organisatie-breed overzicht en coördinatie.
    Heeft leestoegang tot taken van alle patiënten binnen de organisatie en kan taken starten."

// =============================================================================
// RelatedPerson relaties
// =============================================================================

* #relatedperson "RelatedPerson relaties" "Parent categorie voor alle RelatedPerson relaties binnen een CareTeam"
  * ^property[0].code = #notSelectable
  * ^property[=].valueBoolean = true

* #relatedperson #naaste "Naaste"
    "Algemene naaste of verwant van de patiënt.
    Kan meekijken, ondersteunen en communiceren. Heeft alleen toegang tot eigen taken."

* #relatedperson #mantelzorger "Mantelzorger"
    "Structurele informele zorgverlener.
    Kan meekijken, beperkt uitvoeren, ondersteunen en communiceren.
    Heeft leestoegang tot taken van de patiënt."

* #relatedperson #wettelijk-vertegenwoordiger "Wettelijk vertegenwoordiger"
    "Juridisch gemachtigd persoon om namens de patiënt te handelen bij wilsonbekwaamheid.
    Heeft volledige toegang tot taken van de patiënt en kan deze starten."

* #relatedperson #buddy "Buddy"
    "Ervaringsdeskundige begeleider.
    Kan meekijken, ondersteunen en communiceren. Heeft alleen toegang tot eigen taken."
