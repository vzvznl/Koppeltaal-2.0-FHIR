Profile: KT2_Patient
Parent: NlcorePatient
Id: KT2Patient
Description: "The (FHIR) Patient (resource) is a representation of a person who is being treated by the Healthcare Provider to whom eHealth activities are assigned."
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* insert Origin
* extension[nationality] ..0
* identifier 1..
* active 1..
* name 1..
* name obeys kt2pnu-2
* name[nameInformation] ^sliceName = "nameInformation"
* name[nameInformation] ^comment = "This `.name` element represents a Dutch name according to the [zib NameInformation (v1.1, 2020)](https://zibs.nl/wiki/NameInformation-v1.1(2020EN)) (except for the GivenName concept). A Dutch name is represented in FHIR as an ordinary international name, but is augmented using extensions to specify how the last name is built up according to the Dutch rules. See the guidance on `.family` and on `.extension:nameUsage` for more information. Systems that need to work in a Dutch context **MUST** support these extensions as specified here. In addition, systems **MUST** use the core elements according to the FHIR specifications to provide compatibility outside Dutch contexts. It is encouraged to provide a representation of the full name in the `.text` element.\r\n\r\n**Note 1**: The zib cannot be represented straightforward in FHIR. Especially note the guidance on `.given` on how to map the FirstNames and Initials concepts, and on `.prefix`/`.suffix` on how to map the Titles concept.\r\n\r\n**Note 2**: This element should only contain a person's _official_ names. The GivenName concept is represented in another `.name` element with `.name.use` = _usual_.\r\n\r\n**Note 3**: The examples illustrate how the zib is mapped to FHIR."
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
* name[nameInformation-GivenName] ^sliceName = "nameInformation-GivenName"
  * text 
    * insert notUsedKT2
* telecom[telephoneNumbers]
  * rank 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* telecom[emailAddresses]
  * rank 
    * insert notUsedKT2
  * period 
    * insert notUsedKT2
* gender 1..
* birthDate 1..
* deceased[x] ..0
* address
  * extension[addressType]
    * insert notUsedKT2
  * type 
    * insert notUsedKT2
  * text 
    * insert notUsedKT2
  * district 
    * insert notUsedKT2
  * state 
    * insert notUsedKT2
  * country.extension[countryCode]
    * insert docCountryCodes
    * value[x] 
      * insert docCountryCodes
  * period 
    * insert notUsedKT2
* maritalStatus ..0
* multipleBirth[x] ..0
* photo ..0
* contact ..0
* communication ..0
* generalPractitioner ..0
* managingOrganization only Reference(KT2_Organization)
* link ..0