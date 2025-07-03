Profile: KT2_Practitioner
Parent: NlcoreHealthProfessionalPractitioner
Id: KT2Practitioner
Description: "The (FHIR) Practitioner (resource) is a representation of a person who is directly or indirectly involved in the provision of health care."
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* insert Origin
* identifier 1..
* active 1..
* name 1..
* name obeys kt2pnu-1
* name[nameInformation] ^sliceName = "nameInformation"
* name[nameInformation] ^comment = "This `.name` element represents a Dutch name according to the [zib NameInformation (v1.1, 2020)](https://zibs.nl/wiki/NameInformation-v1.1(2020EN)) (except for the GivenName concept). A Dutch name is represented in FHIR as an ordinary international name, but is augmented using extensions to specify how the last name is built up according to the Dutch rules. See the guidance on `.family` and on `.extension:nameUsage` for more information. Systems that need to work in a Dutch context **MUST** support these extensions as specified here. In addition, systems **MUST** use the core elements according to the FHIR specifications to provide compatibility outside Dutch contexts. It is encouraged to provide a representation of the full name in the `.text` element.\r\n\r\n**Note 1**: The zib cannot be represented straightforward in FHIR. Especially note the guidance on `.given` on how to map the FirstNames and Initials concepts, and on `.prefix`/`.suffix` on how to map the Titles concept.\r\n\r\n**Note 2**: This element should only contain a person's _official_ names. The GivenName concept is represented in another `.name` element with `.name.use` = _usual_.\r\n\r\n**Note 3**: The examples illustrate how the zib is mapped to FHIR."
  * extension[nameUsage] ^sliceName = "nameUsage"
    * insert notUsedKT2
  * text 
    * insert notUsedKT2
  * family 1..
  * given 1..
  * prefix 
    * insert notUsedKT2
  * suffix 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* name[nameInformation-GivenName]
  * text 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* telecom[telephoneNumbers]
  * extension[comment] ^sliceName = "comment"
    * insert notUsedKT2
  * use 
    * insert notUsedKT2
  * rank 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* telecom[emailAddresses] 1..
  * use 
    * insert notUsedKT2
  * rank 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* address ..0
* photo ..0
* qualification ..0
* communication ..0