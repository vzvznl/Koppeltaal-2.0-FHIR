#### Required Extensions

##### Endpoint Extension

The `extension[endpoint]` is mandatory and contains one or more references to the service application (endpoint) that provides the eHealth activity. This ensures that the activity definition is properly linked to the system(s) that can execute it.

Example:
```json
{
  "extension": [{
    "url": "http://koppeltaal.nl/fhir/StructureDefinition/KT2-Endpoint",
    "valueReference": {
      "reference": "Endpoint/example-endpoint"
    }
  }]
}
```

##### PublisherId Extension

The `extension[publisherId]` is optional and can be used to identify the publisher of the activity definition.

#### Topic

The `topic` element uses the KoppeltaalDefinitionTopic ValueSet to categorize the activity. This is particularly important for indicating patient-initiated activities.

Common topics include:
- Self-Treatment
- Self-Assessment
- Education
- Exercise
- Monitoring

Example:
```json
{
  "topic": [{
    "coding": [{
      "system": "http://koppeltaal.nl/CodeSystem/definition-topic",
      "code": "self-treatment"
    }]
  }]
}
```

#### URL

The `url` element is required and should contain a unique identifier for the activity definition. This URL should be stable and globally unique.

#### Title

The `title` element is required and should provide a human-readable name for the activity that can be displayed in user interfaces.