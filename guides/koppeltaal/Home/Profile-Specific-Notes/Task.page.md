---
topic: kt2task
---
# {{page-title}}

{{tree:http://koppeltaal.nl/fhir/StructureDefinition/KT2Task}}

## Reference to ActivityDefinition

<div class="warning">
<p><span>⚠️ Warning</span>&nbsp;As of 2023-11-02 the way the ActivityDefinition is referenced is changed!
</div>

A Task should refer to the ActivityDefinition it instantiates. This provides the possibility to search for Tasks that instantiate a specific instance of an ActivityDefinition, which in turn can be found based on its publisherId.

Using the element `instantiatesCanonical` does not however allow chaining of the search parameters. Therefore this profile contains an extension `instantiates` which should hold the reference to the instantiated ActivityDefinition.

The element `instantiatesCanonical` should not be used for this reference. Receivers of a Task instance can ignore any value in the `instantiatesCanonical` and should look for the referred ActivityDefinition in the `instantiates` extension.