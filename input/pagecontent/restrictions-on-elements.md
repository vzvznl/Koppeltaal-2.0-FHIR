
# Element restrictions

Koppeltaal 2.0 adheres to the principle that elements of FHIR resources that are not used in the specifications __MUST NOT__ be used. 

Especially the profiles that based on the national nl-core profiles will contain elements that are not defined in the Koppeltaal 2.0 specifications. 

There are three ways this restrictuion on usage is expressed in the various profiles:

- cardinality set to 0
- marking with 'not to be used'
- description in the Implementation Guide

## Cardinality

Whenever possible the cardinality of elements that are not to be used are set to 0..0. Instances that still use some of these elements will generate an error when the instance is validated against the FHIR profile.

This method is used for all top level elements in a resource whenever applicable.

## Markup advice

Some elements consists of complex types. Especially when they are defined in the nl-core profiles it is not desirable to restrict the subelements of such element by setting the cardinality to 0.
These elements will be marked with a comment `This element is not used in the context of Koppeltaal 2.0`.
The intention is for senders not to fill these elements and receivers to ignore any content in these elements should they exist in the instance.

## Description in this Implementation Guide

Some general data types defined by FHIR contain more subelements than described in the specifications. It is not feasible to modify these types for every relevant element in every profile.

Therefore this section of the Implementation Guide lists all the elements in every applicable data type that should not be used:

### Identifier

The Identifier datatype restricts the use to the elements `use`, `system` and `value`. Other elements are not to be used.

![identifier-restrictions](assets/images/identifier-restrictions.png)



### CodeableConcept and Coding

The `userSelected` element of the Coding data type is not to be used. The Coding data type is also part of the CodeableConcept data type.

![coding-restrictions](assets/images/coding-restrictions.png)
