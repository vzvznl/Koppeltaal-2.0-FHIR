Invariant: kt2-dpt-delete-flow-marker
Description: "The Task must carry the server-owned kt2-delete-flow security label, because that marker is what grants applications access to the deletion flow"
Severity: #error
Expression: "meta.security.where(system = 'http://vzvz.nl/fhir/CodeSystem/koppeltaal-security-label' and code = 'kt2-delete-flow').exists()"
