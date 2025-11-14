# GitHub Copilot Instructions for Koppeltaal 2.0 FHIR

This file provides context to GitHub Copilot when working on the Koppeltaal 2.0 FHIR Implementation Guide.

## Project Overview

This is a FHIR R4 Implementation Guide for Koppeltaal 2.0, built using:
- **FHIR Shorthand (FSH)** - Domain-specific language for defining FHIR resources
- **SUSHI** - FSH compiler that generates FHIR resources
- **HL7 FHIR IG Publisher** - Generates the complete Implementation Guide

## File Structure

```
input/
├── fsh/                    # FHIR Shorthand definitions (EDIT THESE)
│   ├── profiles/          # Profile definitions
│   ├── extensions/        # Extension definitions
│   ├── valuesets/         # ValueSet definitions
│   ├── codesystems/       # CodeSystem definitions
│   └── instances/         # Example instances
├── pagecontent/           # Markdown documentation pages
└── images/                # Images for documentation

output/                    # Generated files (DO NOT EDIT)
fsh-generated/             # SUSHI-generated files (DO NOT EDIT)
```

## FHIR Shorthand (FSH) Conventions

### Profile Definitions

When creating or modifying FHIR profiles:

```fsh
// Use KT2 prefix for all Koppeltaal 2.0 profiles
Profile: KT2Patient
Parent: Patient
Id: KT2Patient
Title: "KT2 Patient"
Description: "Patient profile for Koppeltaal 2.0"

// Always include Dutch nl-core profiles when available
* insert NLCorePatientRules

// Use proper cardinality constraints
* identifier 1..*  // At least one identifier required
* name 1..*        // At least one name required

// Reference other KT2 profiles when needed
* generalPractitioner only Reference(KT2Practitioner or KT2Organization)
```

### Extension Definitions

When creating extensions:

```fsh
// Use lowercase kebab-case for extension IDs
Extension: CorrelationId
Id: correlation-id
Title: "Correlation ID"
Description: "Unique identifier for correlating related resources"

// Always specify context where extension can be used
* ^context[+].type = #element
* ^context[=].expression = "Resource"

// Use appropriate data types
* value[x] only string
* valueString 1..1  // Make it required
```

### ValueSet and CodeSystem Definitions

```fsh
// Use koppeltaal prefix for code systems
CodeSystem: KoppeltaalTaskCode
Id: koppeltaal-task-code
Title: "Koppeltaal Task Codes"
Description: "Codes for Koppeltaal task types"

* #launch-application "Launch Application"
* #create-resource "Create Resource"

// Reference the code system in value sets
ValueSet: KoppeltaalTaskCodeVS
Id: koppeltaal-task-code
Title: "Koppeltaal Task Codes ValueSet"
* include codes from system KoppeltaalTaskCode
```

### Example Instances

```fsh
// Provide meaningful examples that demonstrate usage
Instance: patient-example
InstanceOf: KT2Patient
Usage: #example
Title: "Example Patient"
Description: "Example of a Koppeltaal 2.0 Patient"

* identifier[0].system = "http://example.org/patient-id"
* identifier[0].value = "12345"
* name[0].family = "Jansen"
* name[0].given[0] = "Jan"
```

## Naming Conventions

### Profile Names
- Prefix: `KT2` (e.g., `KT2Patient`, `KT2Organization`)
- Use PascalCase
- Be descriptive but concise

### Extension Names
- ID: lowercase kebab-case (e.g., `correlation-id`, `request-id`)
- Title: Title Case with spaces (e.g., "Correlation ID")

### ValueSet and CodeSystem IDs
- Use lowercase kebab-case with `koppeltaal-` prefix
- Examples: `koppeltaal-task-code`, `koppeltaal-endpoint-connection-type`

### Instance IDs
- Use lowercase kebab-case
- Be descriptive (e.g., `patient-volledig-adres`, `task-minimaal`)

## Common Patterns

### Dutch Healthcare Context

This IG builds on Dutch national profiles (nl-core):

```fsh
// Always reference nl-core profiles when available
Profile: KT2Patient
Parent: nl-core-Patient  // Use Dutch base profile, not base FHIR

// Include nl-core rules using insert statements
* insert NLCorePatientRules
```

### Resource References

```fsh
// Always reference KT2 profiles, not base FHIR resources
* subject only Reference(KT2Patient)
* requester only Reference(KT2Practitioner or KT2Organization or KT2Device)

// Use meaningful reference descriptions
* subject ^short = "The patient this task relates to"
```

### Must Support Elements

```fsh
// Mark elements that systems must support
* identifier MS
* status MS
* intent MS

// Add clear documentation for must-support elements
* identifier ^definition = "Systems must be able to capture and store patient identifiers"
```

### Slicing

```fsh
// Use clear slice names and discriminators
* telecom ^slicing.discriminator.type = #value
* telecom ^slicing.discriminator.path = "system"
* telecom ^slicing.rules = #open

* telecom contains
    phone 0..* and
    email 0..*

* telecom[phone].system = #phone
* telecom[email].system = #email
```

## Build and Test Guidelines

### Before Committing

1. **Always test your FSH files** using Docker:
   ```bash
   docker run -v ${PWD}:/src koppeltaal-builder
   ```

2. **Check for errors** in the build output:
   - SUSHI errors (red) must be fixed
   - Warnings (yellow) should be reviewed
   - Validate that your resources compile correctly

### Common Errors to Avoid

❌ **Don't:**
- Edit files in `output/` or `fsh-generated/` - these are auto-generated
- Use base FHIR resources when KT2 profiles exist
- Forget to test before committing
- Update version numbers in feature branches
- Add generated files to git

✅ **Do:**
- Edit only files in `input/fsh/` and `input/pagecontent/`
- Reference KT2 profiles instead of base FHIR
- Test builds locally before pushing
- Use descriptive commit messages
- Follow existing code patterns

## Version Control

### Git Operations

```bash
# Use git commands for file operations
git rm file.fsh          # Instead of: rm file.fsh
git mv old.fsh new.fsh   # Instead of: mv old.fsh new.fsh
git add input/fsh/new-profile.fsh  # Always add new files
```

### What NOT to Commit

Never commit these directories/files:
- `output/` - Generated IG output
- `fsh-generated/` - SUSHI-generated resources
- `temp/` - Temporary build files
- `*.tgz` - Package archives
- `qa.html` - QA report
- `package-list.json` - Auto-generated

## Dependencies

This IG depends on:
- `nictiz.fhir.nl.r4.zib2020@0.12.0-beta.4` - Dutch ZIB profiles
- `nictiz.fhir.nl.r4.nl-core@0.12.0-beta.4` - Dutch core profiles
- `hl7.fhir.r4.core@4.0.1` - FHIR R4 base

Dependencies are defined in `sushi-config.yaml` and installed automatically during build.

## Documentation

### Markdown Pages

When adding documentation in `input/pagecontent/`:

```markdown
# Use proper heading hierarchy
## Second level
### Third level

<!-- Reference profiles using their canonical URLs -->
See the [KT2 Patient](StructureDefinition-KT2Patient.html) profile.

<!-- Include examples -->
{% include example-patient.md %}
```

### Inline Documentation

```fsh
// Provide clear descriptions for all profiles
Profile: KT2Patient
Title: "KT2 Patient"
Description: """
This profile defines the requirements for Patient resources in Koppeltaal 2.0.
It builds on the Dutch nl-core-Patient profile and adds Koppeltaal-specific
requirements such as mandatory identifiers and correlation tracking.
"""

// Document constraints
* identifier 1..* MS
* identifier ^short = "Patient identifiers (required)"
* identifier ^definition = "At least one patient identifier must be provided. This typically includes the BSN (Dutch citizen service number) or other local identifiers."
```

## Testing Examples

When creating test instances:

```fsh
// Minimal valid example
Instance: patient-minimal
InstanceOf: KT2Patient
Usage: #example
Title: "Minimal Patient Example"
Description: "Demonstrates the minimum required elements for a KT2 Patient"
* identifier.system = "http://example.org/patient-id"
* identifier.value = "MIN001"
* name.family = "Minimal"

// Complete example
Instance: patient-complete
InstanceOf: KT2Patient
Usage: #example
Title: "Complete Patient Example"
Description: "Demonstrates all possible elements for a KT2 Patient"
* identifier[0].system = "http://fhir.nl/fhir/NamingSystem/bsn"
* identifier[0].value = "123456789"
* identifier[1].system = "http://example.org/patient-id"
* identifier[1].value = "COMP001"
* name[0].family = "Jansen"
* name[0].given = "Jan"
* telecom[0].system = #phone
* telecom[0].value = "+31612345678"
* telecom[1].system = #email
* telecom[1].value = "jan.jansen@example.nl"
* gender = #male
* birthDate = "1980-01-01"
```

## Common FHIR Patterns in Koppeltaal

### AuditEvent for Tracking

```fsh
// Use AuditEvent to track application launches and resource creation
Instance: auditevent-launch-application
InstanceOf: KT2AuditEvent
* type = http://dicom.nema.org/resources/ontology/DCM#110100 "Application Activity"
* action = #E "Execute"
* recorded = "2024-01-01T10:00:00Z"
* agent.who = Reference(device-example)
```

### Task for Workflow

```fsh
// Use Task resources for workflow management
Instance: task-example
InstanceOf: KT2Task
* status = #ready
* intent = #order
* code = koppeltaal-task-code#launch-application
* for = Reference(patient-example)
* requester = Reference(practitioner-example)
```

### Extensions for Correlation

```fsh
// Always include correlation-id extension for tracking
* extension[correlation-id].valueString = "550e8400-e29b-41d4-a716-446655440000"
```

## Help and Resources

- **Build issues**: See CONTRIBUTING.md for troubleshooting
- **FSH syntax**: https://build.fhir.org/ig/HL7/fhir-shorthand/
- **Dutch profiles**: https://simplifier.net/packages/nictiz.fhir.nl.r4.nl-core
- **FHIR R4 spec**: https://hl7.org/fhir/R4/

## Summary for Copilot

When suggesting code:
1. Use KT2 prefix for all new profiles
2. Reference Dutch nl-core profiles when available
3. Use lowercase kebab-case for IDs
4. Include clear documentation and examples
5. Follow existing patterns in the codebase
6. Test suggestions against FHIR R4 specification
7. Ensure all references use KT2 profiles, not base FHIR
8. Add meaningful descriptions and short text for all elements
