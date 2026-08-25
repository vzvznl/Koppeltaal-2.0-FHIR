Invariant: kt2-dpt-grace-deadline
Description: "The grace deadline must lie after the announcement, since the grace period starts at authoredOn"
Severity: #error
Expression: "restriction.period.end > authoredOn"
