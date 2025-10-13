Instance: Inline-no-matching-profile
InstanceOf: OperationOutcome
Description: "Example of an OperationOutcome indicating an invalid profile"
Usage: #inline
* id = "no-matching-profile"
* issue
  * code = #invalid
  * severity = #error
  * diagnostics = "No matching profile"