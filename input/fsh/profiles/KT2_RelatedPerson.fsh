Profile: KT2_RelatedPerson
Parent: NlcoreContactPerson
Description: "A related person is a person with a specific role and/or relationship to the patient to assist in the therapy"
Id: KT2RelatedPerson
* ^status = #draft
* insert ContactAndPublisher
* insert Origin
* identifier 1..
* active 1..
* patient only Reference(KT2_Patient)
* relationship 1..
* relationship ^slicing.discriminator.type = #value
* relationship ^slicing.discriminator.path = "$this"
* relationship ^slicing.rules = #closed
* relationship ^comment = "See [Koppeltaal Implementation Guide](https://simplifier.net/guide/koppeltaal/Home/Profile-Specific-Notes/RelatedPerson.page.md?version=current) for more information on the ValueSet"
* relationship[role] ^sliceName = "role"
* relationship[role] ^comment = "When using the `display` element of a code you __MUST__ use the content of the `display` element of the code from the __CodeSystem__. Otherwise, validation will result in errors. Note that the display of the code in the ValueSet can be different."
* name 1..
* name[nameInformation] ^sliceName = "nameInformation"
* name[nameInformation] ^comment = "This `.name` element represents a Dutch name according to the [zib NameInformation (v1.1, 2020)](https://zibs.nl/wiki/NameInformation-v1.1(2020EN)) (except for the GivenName concept). A Dutch name is represented in FHIR as an ordinary international name, but is augmented using extensions to specify how the last name is built up according to the Dutch rules. See the guidance on `.family` and on `.extension:nameUsage` for more information. Systems that need to work in a Dutch context **MUST** support these extensions as specified here. In addition, systems **MUST** use the core elements according to the FHIR specifications to provide compatibility outside Dutch contexts. It is encouraged to provide a representation of the full name in the `.text` element.\r\n\r\n**Note 1**: The zib cannot be represented straightforward in FHIR. Especially note the guidance on `.given` on how to map the FirstNames and Initials concepts, and on `.prefix`/`.suffix` on how to map the Titles concept.\r\n\r\n**Note 2**: This element should only contain a person's _official_ names. The GivenName concept is represented in another `.name` element with `.name.use` = _usual_.\r\n\r\n**Note 3**: The examples illustrate how the zib is mapped to FHIR."
* gender 1..
* birthDate 1..
* photo ..0
