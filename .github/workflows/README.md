# GitHub Actions Workflows

This repository contains several GitHub Actions workflows for building, testing, and deploying Koppeltaal 2.0 FHIR resources.

## Workflows

### 1. Build and Deploy FHIR Packages (`build_deploy.yml`)
**Purpose:** Builds FHIR packages and optionally deploys to Simplifier.net and GitHub Pages.

**Triggers:**
- Push to any branch
- Manual workflow dispatch with optional Simplifier publication

**Outputs:**
- FHIR packages (full and minimal)
- GitHub Pages deployment
- Optional Simplifier.net publication

### 2. Generate Test Suite and Postman Collection (`generate-test-suite.yml`)
**Purpose:** Automatically generates Koppeltaal 2.0 test resources and Postman collection for API testing.

**Triggers:**
- Push to main/develop branches when test scripts or profiles change
- Manual workflow dispatch with customization options

**Inputs (manual trigger):**
- `request_delay`: Delay in milliseconds between Postman requests (default: 500ms)
- `include_auth`: Include Bearer token authentication in collection (default: false)

**Outputs:**
- Test resources for all Koppeltaal 2.0 profiles
- Postman collection (`koppeltaal-tests.postman_collection.json`)
- Newman runner script (`run-newman-tests.sh`)
- Artifacts available for 30 days
- Release assets on tags

**Features:**
- Generates minimal, maximal, and invalid test variants
- Handles resource dependencies automatically
- Configurable request delays to avoid rate limiting
- Validates collection structure

### 3. Run FHIR Tests with Newman (`run-fhir-tests.yml`)
**Purpose:** Executes the generated test suite against a live FHIR server.

**Triggers:**
- Manual workflow dispatch only (requires FHIR server)

**Required Inputs:**
- `fhir_server_url`: FHIR Server Base URL (e.g., https://server.fire.ly/r4)

**Optional Inputs:**
- `auth_token`: Bearer token for authentication
- `stop_on_failure`: Stop on first test failure (default: false)
- `test_filter`: Filter tests by resource type (e.g., Patient, Organization)

**Outputs:**
- Newman test results (JSON, HTML, JUnit formats)
- Test summary in GitHub Actions
- Downloadable HTML report
- Pass/fail status for CI/CD pipelines

## Usage Examples

### Generate Test Suite Locally
```bash
# Generate test resources
python scripts/generate_test_resources.py

# Generate Postman collection with 1 second delay
python scripts/generate_postman_collection.py --delay 1000

# Generate with authentication headers
python scripts/generate_postman_collection.py --include-auth
```

### Run Tests with Newman Locally
```bash
# Install Newman
npm install -g newman

# Run tests against local FHIR server
./run-newman-tests.sh http://localhost:8080/fhir

# Or use Newman directly
newman run koppeltaal-tests.postman_collection.json \
  --env-var "fhir_base_url=http://localhost:8080/fhir" \
  --reporters cli,json \
  --reporter-json-export results.json
```

### Trigger Workflows via GitHub CLI
```bash
# Generate test suite with custom delay
gh workflow run generate-test-suite.yml \
  -f request_delay=1000 \
  -f include_auth=true

# Run tests against FHIR server
gh workflow run run-fhir-tests.yml \
  -f fhir_server_url=https://server.fire.ly/r4 \
  -f auth_token=your-token-here \
  -f stop_on_failure=true \
  -f test_filter=Patient
```

## Test Resource Types

The test suite includes the following Koppeltaal 2.0 resource types:
- Patient
- Practitioner
- Organization
- RelatedPerson
- Device
- ActivityDefinition
- Task
- AuditEvent

Each resource type includes:
- Minimal variant (only required fields)
- Maximal variant (all possible fields)
- Invalid variants (missing required fields for validation testing)

## Resource Dependencies

Resources are created and deleted in dependency order:
1. Organization (no dependencies)
2. Practitioner (no dependencies)
3. Patient (references Organization)
4. RelatedPerson (references Patient)
5. Device (references Organization)
6. ActivityDefinition (references Endpoint)
7. Task (references Patient, Practitioner, ActivityDefinition)
8. AuditEvent (references Device, Patient)

Cleanup occurs in reverse order with cascade delete to handle dependencies.

## Artifacts

### Generated Artifacts
- `koppeltaal-test-resources`: All JSON test resources
- `postman-collection`: Postman collection and Newman script
- `newman-test-results`: Test execution results
- `newman-html-report`: Interactive HTML test report

### Release Assets (on tags)
- `koppeltaal-test-resources.zip`: Complete test resource bundle
- `postman-test-suite.zip`: Postman collection and Newman script bundle
- Individual files for direct download

## Configuration

### Request Delays
To avoid rate limiting on FHIR servers, configure delays between requests:
- Default: 500ms
- Recommended for production servers: 1000ms
- Disable for local testing: 0ms

### Authentication
When testing against secured FHIR servers:
1. Generate collection with `--include-auth` flag
2. Set `access_token` variable in Postman or environment
3. Token will be included as `Authorization: Bearer {token}` header

## Troubleshooting

### Common Issues
1. **Rate limiting errors**: Increase request delay
2. **Authentication failures**: Verify token and include-auth flag
3. **Resource not found**: Check dependency order and ID references
4. **Validation failures**: Ensure FHIR server supports Koppeltaal 2.0 profiles

### Debug Tips
- Check workflow run logs in GitHub Actions
- Download and inspect newman-results.json for detailed errors
- Use test_filter to isolate problematic resource types
- Run locally with verbose output for debugging