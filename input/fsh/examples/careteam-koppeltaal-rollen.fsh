// =============================================================================
// CareTeam voorbeelden met Koppeltaal-specifieke autorisatierollen
// =============================================================================

Instance: careteam-behandelaar
InstanceOf: CareTeam
Description: "Example of CareTeam with a Practitioner in the 'behandelaar' authorization role"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>CareTeam met een behandelaar</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://myTeam/id"
  * value = "careteam-behandelaar-001"
* status = #active
* name = "Careteam met behandelaar"
* subject = Reference(Patient/patient-met-resource-origin) "Patient, Berta Botje"
  * type = "Patient"
* participant[0]
  * role
    * coding = $koppeltaal-careteam-role#behandelaar "Behandelaar"
    * text = "Behandelaar"
  * member = Reference(Practitioner/practitioner-volledig) "K. Jongen"
    * type = "Practitioner"
* managingOrganization = Reference(Organization/organization-naam-type)
  * type = "Organization"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"


Instance: careteam-alle-practitioner-rollen
InstanceOf: CareTeam
Description: "Example of CareTeam demonstrating all Koppeltaal Practitioner authorization roles"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>CareTeam met alle Practitioner autorisatierollen</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://myTeam/id"
  * value = "careteam-practitioner-rollen-001"
* status = #active
* name = "Careteam met alle practitioner rollen"
* subject = Reference(Patient/patient-met-resource-origin) "Patient, Berta Botje"
  * type = "Patient"
* participant[0]
  * role
    * coding = $koppeltaal-careteam-role#behandelaar "Behandelaar"
    * text = "Behandelaar"
  * member = Reference(Practitioner/practitioner-volledig) "K. Jongen"
    * type = "Practitioner"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#zorgondersteuner "Zorgondersteuner"
    * text = "Zorgondersteuner"
  * member = Reference(Practitioner/practitioner-minimaal) "M. Splinter"
    * type = "Practitioner"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#case-manager "Case Manager"
    * text = "Case Manager"
  * member = Reference(Practitioner/practitioner-minimaal) "A. Coordinator"
    * type = "Practitioner"
* managingOrganization = Reference(Organization/organization-naam-type)
  * type = "Organization"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"


Instance: careteam-mantelzorger
InstanceOf: CareTeam
Description: "Example of CareTeam with a RelatedPerson in the 'mantelzorger' authorization role"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>CareTeam met een mantelzorger</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://myTeam/id"
  * value = "careteam-mantelzorger-001"
* status = #active
* name = "Careteam met mantelzorger"
* subject = Reference(Patient/patient-met-resource-origin) "Patient, Berta Botje"
  * type = "Patient"
* participant[0]
  * role
    * coding = $koppeltaal-careteam-role#behandelaar "Behandelaar"
    * text = "Behandelaar"
  * member = Reference(Practitioner/practitioner-volledig) "K. Jongen"
    * type = "Practitioner"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#mantelzorger "Mantelzorger"
    * text = "Mantelzorger"
  * member = Reference(RelatedPerson/relatedperson-minimal) "M. Buurvrouw"
    * type = "RelatedPerson"
* managingOrganization = Reference(Organization/organization-naam-type)
  * type = "Organization"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"


Instance: careteam-wettelijk-vertegenwoordiger
InstanceOf: CareTeam
Description: "Example of CareTeam with a RelatedPerson as 'wettelijk vertegenwoordiger' (legal representative)"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>CareTeam met een wettelijk vertegenwoordiger</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://myTeam/id"
  * value = "careteam-wv-001"
* status = #active
* name = "Careteam met wettelijk vertegenwoordiger"
* subject = Reference(Patient/patient-met-resource-origin) "Patient, Berta Botje"
  * type = "Patient"
* participant[0]
  * role
    * coding = $koppeltaal-careteam-role#behandelaar "Behandelaar"
    * text = "Behandelaar"
  * member = Reference(Practitioner/practitioner-volledig) "K. Jongen"
    * type = "Practitioner"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#wettelijk-vertegenwoordiger "Wettelijk vertegenwoordiger"
    * text = "Wettelijk vertegenwoordiger"
  * member = Reference(RelatedPerson/relatedperson-minimal) "J. Voogd"
    * type = "RelatedPerson"
* managingOrganization = Reference(Organization/organization-naam-type)
  * type = "Organization"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"


Instance: careteam-alle-relatedperson-rollen
InstanceOf: CareTeam
Description: "Example of CareTeam demonstrating all Koppeltaal RelatedPerson authorization roles"
Usage: #example
* meta.profile = "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>CareTeam met alle RelatedPerson autorisatierollen</div>"
* insert NLlang
* identifier
  * use = #official
  * system = "http://myTeam/id"
  * value = "careteam-relatedperson-rollen-001"
* status = #active
* name = "Careteam met alle relatedperson rollen"
* subject = Reference(Patient/patient-met-resource-origin) "Patient, Berta Botje"
  * type = "Patient"
* participant[0]
  * role
    * coding = $koppeltaal-careteam-role#behandelaar "Behandelaar"
    * text = "Behandelaar"
  * member = Reference(Practitioner/practitioner-volledig) "K. Jongen"
    * type = "Practitioner"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#naaste "Naaste"
    * text = "Naaste"
  * member = Reference(RelatedPerson/relatedperson-minimal) "A. Familie"
    * type = "RelatedPerson"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#mantelzorger "Mantelzorger"
    * text = "Mantelzorger"
  * member = Reference(RelatedPerson/relatedperson-minimal) "B. Zorger"
    * type = "RelatedPerson"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#wettelijk-vertegenwoordiger "Wettelijk vertegenwoordiger"
    * text = "Wettelijk vertegenwoordiger"
  * member = Reference(RelatedPerson/relatedperson-minimal) "C. Voogd"
    * type = "RelatedPerson"
* participant[+]
  * role
    * coding = $koppeltaal-careteam-role#buddy "Buddy"
    * text = "Buddy"
  * member = Reference(RelatedPerson/relatedperson-minimal) "D. Maatje"
    * type = "RelatedPerson"
* managingOrganization = Reference(Organization/organization-naam-type)
  * type = "Organization"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
  * valueReference = Reference(Device/ba33314a-795a-4777-bef8-e6611f6be645)
    * type = "Device"
