
#### Identifier

The `identifier` element is mandatory and should contain at least one identifier for the patient.

#### Active

The `active` element is required and indicates whether the patient's record is in active use.

#### Name

The `name` element is mandatory and follows Dutch naming conventions as defined in the zib NameInformation. The profile supports:
- Official names with proper Dutch family name construction
- Given names for everyday use
- Extensions for Dutch-specific name components

#### Demographics

Required demographic elements include:
- `gender` - Patient's gender (mandatory)
- `birthDate` - Patient's birth date (mandatory)

#### Managing Organization

When specified, the `managingOrganization` element must reference a KT2_Organization resource, indicating which organization is responsible for the patient's care.

#### Country Codes

The section on country codes is [moved](country-codes.html) because it is equally relevant for Providers and Healthcare professionals.
