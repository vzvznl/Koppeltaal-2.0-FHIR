Invariant: kt2-dpt-status-reason
Description: "statusReason is mandatory when status is on-hold and must be absent for every other status"
Severity: #error
Expression: "(status = 'on-hold' implies statusReason.exists()) and (statusReason.exists() implies status = 'on-hold')"
