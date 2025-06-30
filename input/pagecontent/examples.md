
# Examples

This project contains several examples that should clarify the way the various elements of the relevant profile are used.
We strive to make sure all the examples validate without errors or warnings, but some cannot be avoided. We will keep a list of known issues below.

## Example ids

A true `id` will usually be a uuid or similar system. In the examples however, every `id` is a string that is more descriptive to explain what makes this example different for the other examples for the profile. The ids are used by Simplifier to list the files in the overview. Using descriptive `id`s makes it easier to select the example you are interested in.

Every example has an `id` even when the instance should be used in a `create` operation where no `id` is present. This is also done for easier reference in Simplifier.

## Resolvable references

The examples in this project are created in such a way that all instance references are resolvable. This means that a reference to `Patient/patient-managingOrganization-telefoonnummer` will refer to an example of a Patient instance following the [KT2Patient](StructureDefinition-KT2Patient.html) profile. 

In this case that would be [patient-managingOrganization-telefoonnummer](Patient-patient-managingOrganization-telefoonnummer.html).
