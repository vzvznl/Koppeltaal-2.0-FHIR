# Country codes

## List of country codes
The link to the list of country codes is hard to find, therefore they are referenced here:


[ValueSet 'LandCodelijsten'](https://simplifier.net/nictiz-r4-zib2020/2.16.840.1.113883.2.4.3.11.60.121.11.10--20200901000000) references two other ValueSets:
* [ValueSet 'LandGBACodelijst'](https://simplifier.net/nictiz-r4-zib2020/2.16.840.1.113883.2.4.3.11.60.40.2.20.5.1--20200901000000) which references a CodeSystem:
    * GBATabel34Landen: [urn:oid:2.16.840.1.113883.2.4.4.16.34](https://simplifier.net/nictiz-r4-zib2020/2.16.840.1.113883.2.4.4.16.34)
* [ValueSet 'LandISOCodelijst'](https://simplifier.net/nictiz-r4-zib2020/2.16.840.1.113883.2.4.3.11.60.40.2.20.5.2--20200901000000) which references a CodeSystem that is described here:
    * [ValueSet: CountryEntityType](https://terminology.hl7.org/4.0.0/ValueSet-v3-CountryEntityType.html)

## National or international?
General guidance: use the international CodeSystem unless there is an explicit use case for using the national CodeSystem.

## Exception on country codes
<div class="dragon">
For Koppeltaal we make the exception that 3-digit country codes, as defined in the ISO list are excluded from usage.
</div>