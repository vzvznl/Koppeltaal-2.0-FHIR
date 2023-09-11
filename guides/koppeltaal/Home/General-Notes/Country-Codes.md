---
topic: country-codes
---

# {{page-title}}

The link to the list of country codes is hard to find, therefore they are referenced here:

[ValueSet 'LandCodelijsten'](https://simplifier.net/packages/nictiz.fhir.nl.r4.zib2020/0.7.0-beta.1/files/783891) references two other ValueSets:
* [ValueSet 'LandGBACodelijst'](https://simplifier.net/packages/nictiz.fhir.nl.r4.zib2020/0.7.0-beta.1/files/783960) which references a CodeSystem:
    * GBATabel34Landen: [urn:oid:2.16.840.1.113883.2.4.4.16.34](https://simplifier.net/packages/nictiz.fhir.nl.r4.zib2020/0.7.0-beta.1/files/784072)
* [ValueSet 'LandISOCodelijst'](https://simplifier.net/packages/nictiz.fhir.nl.r4.zib2020/0.7.0-beta.1/files/783961) which references a CodeSystem that is described here:
    * [ValueSet: CountryEntityType](https://terminology.hl7.org/4.0.0/ValueSet-v3-CountryEntityType.html)

General guidance: use the international CodeSystem unless there is an explicit use case for using the national CodeSystem.

<div class="warning">
<span>⚠️ Warning</span>
</div>
For Koppeltaal we make the exception that 3-digit country codes, as defined in the ISO list are excluded from usage.