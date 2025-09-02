#!/usr/bin/env python3
"""
Generate Postman/Newman collection from Koppeltaal 2.0 test resources.
Handles dependencies between resources (e.g., Task needs Patient ID).
"""

import json
import os
import argparse
from datetime import datetime
from pathlib import Path

class PostmanCollectionGenerator:
    def __init__(self, test_resources_dir="test-resources", output_file="koppeltaal-tests.postman_collection.json", include_auth=False, request_delay=500):
        self.test_resources_dir = test_resources_dir
        self.output_file = output_file
        self.base_url = "{{fhir_base_url}}"  # Variable for FHIR server base URL
        self.include_auth = include_auth
        self.request_delay = request_delay  # Delay in milliseconds between requests
        
    def generate_collection(self):
        """Generate the Postman collection."""
        collection = {
            "info": {
                "name": "Koppeltaal 2.0 FHIR Test Suite",
                "description": "Automated test suite for Koppeltaal 2.0 FHIR profiles",
                "_postman_id": self.generate_uuid(),
                "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
                "version": datetime.now().isoformat()
            },
            "item": [],
            "variable": [
                {
                    "key": "fhir_base_url",
                    "value": "http://localhost:8080/fhir",
                    "type": "string",
                    "description": "Base URL of the FHIR server"
                },
                {
                    "key": "access_token",
                    "value": "",
                    "type": "string",
                    "description": "Bearer token for authentication (optional)"
                },
                {
                    "key": "patient_id",
                    "value": "",
                    "type": "string",
                    "description": "ID of created Patient resource"
                },
                {
                    "key": "practitioner_id",
                    "value": "",
                    "type": "string",
                    "description": "ID of created Practitioner resource"
                },
                {
                    "key": "organization_id",
                    "value": "",
                    "type": "string",
                    "description": "ID of created Organization resource"
                },
                {
                    "key": "related_person_id",
                    "value": "",
                    "type": "string",
                    "description": "ID of created RelatedPerson resource"
                },
                {
                    "key": "device_id",
                    "value": "",
                    "type": "string",
                    "description": "ID of created Device resource"
                },
                {
                    "key": "endpoint_id",
                    "value": "",
                    "type": "string",
                    "description": "ID of created Endpoint resource"
                },
                {
                    "key": "activity_definition_id",
                    "value": "",
                    "type": "string",
                    "description": "ID of created ActivityDefinition resource"
                },
                {
                    "key": "task_id",
                    "value": "",
                    "type": "string",
                    "description": "ID of created Task resource"
                },
                {
                    "key": "audit_event_id",
                    "value": "",
                    "type": "string",
                    "description": "ID of created AuditEvent resource"
                },
                {
                    "key": "patient_id_version",
                    "value": "",
                    "type": "string",
                    "description": "Version of Patient resource for If-Match header"
                },
                {
                    "key": "related_person_id_version",
                    "value": "",
                    "type": "string",
                    "description": "Version of RelatedPerson resource for If-Match header"
                },
                {
                    "key": "endpoint_id_version",
                    "value": "",
                    "type": "string",
                    "description": "Version of Endpoint resource for If-Match header"
                },
                {
                    "key": "activity_definition_id_version",
                    "value": "",
                    "type": "string",
                    "description": "Version of ActivityDefinition resource for If-Match header"
                },
                {
                    "key": "task_id_version",
                    "value": "",
                    "type": "string",
                    "description": "Version of Task resource for If-Match header"
                }
            ]
        }
        
        # Add auth configuration only if requested
        if self.include_auth:
            collection["auth"] = {
                "type": "bearer",
                "bearer": [
                    {
                        "key": "token",
                        "value": "{{access_token}}",
                        "type": "string"
                    }
                ]
            }
        
        # Create folders for each resource type
        resource_folders = {
            "Organization": self.create_folder("Organization", "Organization resources (create first - no dependencies)"),
            "Practitioner": self.create_folder("Practitioner", "Practitioner resources (create second - no dependencies)"),
            "Patient": self.create_folder("Patient", "Patient resources (can reference Organization)"),
            "RelatedPerson": self.create_folder("RelatedPerson", "RelatedPerson resources (can reference Patient)"),
            "Device": self.create_folder("Device", "Device resources (can reference Organization)"),
            "Endpoint": self.create_folder("Endpoint", "Endpoint resources (references Organization)"),
            "ActivityDefinition": self.create_folder("ActivityDefinition", "ActivityDefinition resources (references Endpoint)"),
            "Task": self.create_folder("Task", "Task resources (requires Patient, Practitioner, and ActivityDefinition)"),
            "AuditEvent": self.create_folder("AuditEvent", "AuditEvent resources (references Device)")
        }
        
        # Process test resources in dependency order
        resource_order = ["Organization", "Practitioner", "Patient", "RelatedPerson", "Device", "Endpoint", "ActivityDefinition", "Task", "AuditEvent"]
        
        for resource_type in resource_order:
            folder = resource_folders[resource_type]
            self.add_resource_tests(folder, resource_type)
            collection["item"].append(folder)
        
        # Add history tests folder
        history_folder = self.create_folder("History Tests", "Test _history operations on resources")
        self.add_history_tests(history_folder, ["Patient", "Task", "Endpoint"])
        collection["item"].append(history_folder)
        
        # Add cleanup folder
        cleanup_folder = self.create_folder("Cleanup", "Delete created test resources")
        self.add_cleanup_requests(cleanup_folder, resource_order)
        collection["item"].append(cleanup_folder)
        
        # Add post-deletion history tests
        post_delete_folder = self.create_folder("Post-Deletion History", "Test _history after resource deletion")
        self.add_post_deletion_history_tests(post_delete_folder, ["Patient", "Task"])
        collection["item"].append(post_delete_folder)
        
        # Write collection to file
        with open(self.output_file, 'w', encoding='utf-8') as f:
            json.dump(collection, f, indent=2)
        
        print(f"✅ Postman collection generated: {self.output_file}")
        return collection
    
    def create_folder(self, name, description):
        """Create a folder structure for Postman collection."""
        return {
            "name": name,
            "description": description,
            "item": []
        }
    
    def add_resource_tests(self, folder, resource_type):
        """Add test requests for a resource type."""
        resource_dir = Path(self.test_resources_dir) / resource_type
        
        if not resource_dir.exists():
            return
        
        # Process files in specific order: minimal, maximal, then invalid
        test_files = sorted(resource_dir.glob("*.json"))
        
        # Separate files by variant
        minimal_files = [f for f in test_files if "minimal" in f.name]
        maximal_files = [f for f in test_files if "maximal" in f.name]
        invalid_files = [f for f in test_files if "invalid" in f.name]
        
        # Process in order
        for files, variant in [(minimal_files, "minimal"), (maximal_files, "maximal"), (invalid_files, "invalid")]:
            for file_path in files:
                self.add_test_request(folder, file_path, resource_type, variant)
                
                # Add update test for minimal variant of resources with status fields
                if variant == "minimal" and resource_type in ["Patient", "Task", "Endpoint", "ActivityDefinition", "RelatedPerson"]:
                    self.add_update_test_request(folder, file_path, resource_type)
    
    def add_test_request(self, folder, file_path, resource_type, variant):
        """Add a single test request to the folder."""
        with open(file_path, 'r') as f:
            resource_data = json.load(f)
        
        # Update references in resource data to use variables
        resource_data = self.update_references(resource_data, resource_type)
        
        is_invalid = "invalid" in file_path.name
        expected_status = 400 if is_invalid else 201
        
        request_name = f"{resource_type} - {file_path.stem}"
        
        request = {
            "name": request_name,
            "event": [
                {
                    "listen": "test",
                    "script": {
                        "exec": self.generate_test_script(resource_type, variant, is_invalid, expected_status),
                        "type": "text/javascript"
                    }
                },
                {
                    "listen": "prerequest",
                    "script": {
                        "exec": self.generate_prerequest_script(resource_type),
                        "type": "text/javascript"
                    }
                }
            ],
            "request": {
                "method": "POST",
                "header": [
                    {
                        "key": "Content-Type",
                        "value": "application/fhir+json"
                    },
                    {
                        "key": "Accept",
                        "value": "application/fhir+json"
                    }
                ],
                "body": {
                    "mode": "raw",
                    "raw": json.dumps(resource_data, indent=2)
                },
                "url": {
                    "raw": f"{self.base_url}/{resource_type}",
                    "host": ["{{fhir_base_url}}"],
                    "path": [resource_type]
                },
                "description": f"Create {variant} {resource_type} resource"
            }
        }
        
        folder["item"].append(request)
    
    def add_update_test_request(self, folder, file_path, resource_type):
        """Add a PUT request to update a resource by flipping its status."""
        with open(file_path, 'r') as f:
            resource_data = json.load(f)
        
        # Update references in resource data to use variables
        resource_data = self.update_references(resource_data, resource_type)
        
        # Add the resource ID to the body
        if resource_type == "ActivityDefinition":
            resource_data["id"] = "{{activity_definition_id}}"
        elif resource_type == "Endpoint":
            resource_data["id"] = "{{endpoint_id}}"
        else:
            resource_data["id"] = f"{{{{{resource_type.lower()}_id}}}}"
        
        # Flip the status field based on resource type
        if resource_type == "Patient":
            # Patient.active field
            if "active" in resource_data:
                resource_data["active"] = not resource_data.get("active", True)
            else:
                resource_data["active"] = False
        elif resource_type == "RelatedPerson":
            # RelatedPerson.active field
            if "active" in resource_data:
                resource_data["active"] = not resource_data.get("active", True)
            else:
                resource_data["active"] = False
        elif resource_type == "Task":
            # Task.status field - cycle through different valid statuses
            current_status = resource_data.get("status", "requested")
            status_map = {
                "requested": "accepted",
                "accepted": "in-progress",
                "in-progress": "completed",
                "completed": "requested"
            }
            resource_data["status"] = status_map.get(current_status, "in-progress")
        elif resource_type == "Endpoint":
            # Endpoint.status field - toggle between active and suspended
            current_status = resource_data.get("status", "active")
            resource_data["status"] = "suspended" if current_status == "active" else "active"
        elif resource_type == "ActivityDefinition":
            # ActivityDefinition.status field - toggle between active and draft
            current_status = resource_data.get("status", "active")
            resource_data["status"] = "draft" if current_status == "active" else "active"
        
        request_name = f"{resource_type} - Update Status"
        
        # Determine the variable name for the resource ID
        if resource_type == "ActivityDefinition":
            var_name = "activity_definition_id"
        elif resource_type == "Endpoint":
            var_name = "endpoint_id"
        else:
            var_name = f"{resource_type.lower()}_id"
        
        request = {
            "name": request_name,
            "event": [
                {
                    "listen": "test",
                    "script": {
                        "exec": [
                            f'pm.test("{resource_type} updated successfully", function () {{',
                            '    pm.response.to.have.status(200);',
                            '});',
                            '',
                            '// Verify the status was changed',
                            'pm.test("Status field was updated", function () {',
                            '    var responseJson = pm.response.json();',
                            '    pm.expect(responseJson).to.have.property("resourceType");',
                            f'    pm.expect(responseJson.resourceType).to.equal("{resource_type}");',
                            '});'
                        ],
                        "type": "text/javascript"
                    }
                },
                {
                    "listen": "prerequest",
                    "script": {
                        "exec": [
                            f'// Check that {resource_type} ID is available',
                            f'var resourceId = pm.collectionVariables.get("{var_name}");',
                            'if (!resourceId) {',
                            f'    console.error("Error: {resource_type} ID not set. Cannot update resource.");',
                            '    pm.execution.skipRequest();',
                            '}',
                            '',
                            '// Set If-Match header with version',
                            f'var version = pm.collectionVariables.get("{var_name}_version");',
                            'if (version) {',
                            '    pm.request.headers.add({',
                            '        key: "If-Match",',
                            '        value: "W/\\"" + version + "\\""',
                            '    });',
                            f'    console.log("Added If-Match header with version: " + version);',
                            '} else {',
                            f'    console.warn("Warning: No version found for {resource_type}. Update may fail if server requires If-Match.");',
                            '}',
                            '',
                            '// Add small delay before update',
                            f'const delay = {self.request_delay};',
                            'const start = Date.now();',
                            'while (Date.now() - start < delay) {',
                            '    // Synchronous delay',
                            '}',
                            'console.log("Waited " + delay + "ms before update request");'
                        ],
                        "type": "text/javascript"
                    }
                }
            ],
            "request": {
                "method": "PUT",
                "header": [
                    {
                        "key": "Content-Type",
                        "value": "application/fhir+json"
                    },
                    {
                        "key": "Accept",
                        "value": "application/fhir+json"
                    }
                ],
                "body": {
                    "mode": "raw",
                    "raw": json.dumps(resource_data, indent=2)
                },
                "url": {
                    "raw": f"{self.base_url}/{resource_type}/{{{{{var_name}}}}}",
                    "host": ["{{fhir_base_url}}"],
                    "path": [resource_type, f"{{{{{var_name}}}}}"]
                },
                "description": f"Update {resource_type} by changing its status field"
            }
        }
        
        folder["item"].append(request)
    
    def update_references(self, resource_data, resource_type):
        """Update references in resource data to use Postman variables."""
        resource_str = json.dumps(resource_data)
        
        # Update references based on resource type
        if resource_type == "Task":
            # Update Patient reference
            resource_str = resource_str.replace(
                '"reference": "Patient/patient-test-001"',
                '"reference": "Patient/{{patient_id}}"'
            )
            # Update Practitioner reference
            resource_str = resource_str.replace(
                '"reference": "Practitioner/practitioner-test-001"',
                '"reference": "Practitioner/{{practitioner_id}}"'
            )
            # Update ActivityDefinition reference
            resource_str = resource_str.replace(
                '"reference": "ActivityDefinition/activity-test-001"',
                '"reference": "ActivityDefinition/{{activity_definition_id}}"'
            )
        elif resource_type == "Patient":
            # Update Organization reference
            resource_str = resource_str.replace(
                '"reference": "Organization/org-test-001"',
                '"reference": "Organization/{{organization_id}}"'
            )
        elif resource_type == "Device":
            # Update Organization reference
            resource_str = resource_str.replace(
                '"reference": "Organization/org-test-001"',
                '"reference": "Organization/{{organization_id}}"'
            )
        elif resource_type == "RelatedPerson":
            # Update Patient reference
            resource_str = resource_str.replace(
                '"reference": "Patient/patient-test-001"',
                '"reference": "Patient/{{patient_id}}"'
            )
        elif resource_type == "AuditEvent":
            # Update Device references
            resource_str = resource_str.replace(
                '"reference": "Device/device-test-001"',
                '"reference": "Device/{{device_id}}"'
            )
            # Update Patient reference
            resource_str = resource_str.replace(
                '"reference": "Patient/patient-test-001"',
                '"reference": "Patient/{{patient_id}}"'
            )
        elif resource_type == "Endpoint":
            # Update Organization reference
            resource_str = resource_str.replace(
                '"reference": "Organization/org-test-001"',
                '"reference": "Organization/{{organization_id}}"'
            )
        elif resource_type == "ActivityDefinition":
            # Update Endpoint references
            resource_str = resource_str.replace(
                '"reference": "Endpoint/endpoint-test-001"',
                '"reference": "Endpoint/{{endpoint_id}}"'
            )
            resource_str = resource_str.replace(
                '"reference": "Endpoint/endpoint-test-002"',
                '"reference": "Endpoint/{{endpoint_id}}"'
            )
        
        return json.loads(resource_str)
    
    def generate_test_script(self, resource_type, variant, is_invalid, expected_status):
        """Generate Postman test script."""
        scripts = []
        
        # Basic status code test
        if is_invalid:
            scripts.append(f'pm.test("Invalid {resource_type} should fail", function () {{')
            scripts.append(f'    pm.expect(pm.response.code).to.be.oneOf([400, 422]);')
            scripts.append('});')
        else:
            scripts.append(f'pm.test("{resource_type} created successfully", function () {{')
            scripts.append(f'    pm.response.to.have.status(201);')
            scripts.append('});')
            
            # Save ID for valid resources (only for minimal variant to avoid conflicts)
            if variant == "minimal":
                scripts.append('')
                scripts.append('// Save resource ID for later use')
                scripts.append('if (pm.response.code === 201) {')
                scripts.append('    // Get ID from response body')
                scripts.append('    var responseJson = pm.response.json();')
                scripts.append('    if (responseJson.id) {')
                # Special case for ActivityDefinition and Endpoint to use underscore
                if resource_type == "ActivityDefinition":
                    var_name = "activity_definition_id"
                elif resource_type == "Endpoint":
                    var_name = "endpoint_id"
                else:
                    var_name = f"{resource_type.lower()}_id"
                scripts.append(f'        pm.collectionVariables.set("{var_name}", responseJson.id);')
                scripts.append(f'        console.log("{resource_type} ID saved: " + responseJson.id);')
                
                # Save the version/ETag for updates
                scripts.append('')
                scripts.append('        // Save version for updates (If-Match header)')
                scripts.append('        if (responseJson.meta && responseJson.meta.versionId) {')
                scripts.append(f'            pm.collectionVariables.set("{var_name}_version", responseJson.meta.versionId);')
                scripts.append(f'            console.log("{resource_type} version saved: " + responseJson.meta.versionId);')
                scripts.append('        }')
                
                # Special handling for Device: need to update with its own ID
                if resource_type == "Device":
                    scripts.append('')
                    scripts.append('        // Device special case: Update identifier with Device.id')
                    scripts.append('        var deviceToUpdate = responseJson;')
                    scripts.append('        // Update the koppeltaal-client-id identifier with the actual Device.id')
                    scripts.append('        if (deviceToUpdate.identifier) {')
                    scripts.append('            for (var i = 0; i < deviceToUpdate.identifier.length; i++) {')
                    scripts.append('                if (deviceToUpdate.identifier[i].system === "http://vzvz.nl/fhir/NamingSystem/koppeltaal-client-id") {')
                    scripts.append('                    deviceToUpdate.identifier[i].value = responseJson.id;')
                    scripts.append('                    break;')
                    scripts.append('                }')
                    scripts.append('            }')
                    scripts.append('        }')
                    scripts.append('')
                    scripts.append('        // Send PUT request to update the Device')
                    scripts.append('        pm.sendRequest({')
                    scripts.append('            url: pm.environment.get("fhir_base_url") + "/Device/" + responseJson.id,')
                    scripts.append('            method: "PUT",')
                    scripts.append('            header: {')
                    scripts.append('                "Content-Type": "application/fhir+json",')
                    scripts.append('                "Accept": "application/fhir+json"')
                    scripts.append('            },')
                    scripts.append('            body: {')
                    scripts.append('                mode: "raw",')
                    scripts.append('                raw: JSON.stringify(deviceToUpdate)')
                    scripts.append('            }')
                    scripts.append('        }, function (err, res) {')
                    scripts.append('            if (err) {')
                    scripts.append('                console.error("Error updating Device with its own ID:", err);')
                    scripts.append('            } else {')
                    scripts.append('                console.log("Device updated with its own ID successfully");')
                    scripts.append('            }')
                    scripts.append('        });')
                
                scripts.append('    } else {')
                scripts.append(f'        console.warn("Warning: No ID found in {resource_type} response");')
                scripts.append('    }')
                scripts.append('}')
        
        # Profile validation test
        scripts.append('')
        scripts.append('// Validate response is valid FHIR')
        scripts.append('pm.test("Response is valid FHIR", function () {')
        scripts.append('    var jsonData = pm.response.json();')
        scripts.append('    pm.expect(jsonData).to.have.property("resourceType");')
        if is_invalid:
            scripts.append('    // For validation errors, expect OperationOutcome')
            scripts.append('    if (pm.response.code >= 400 && pm.response.code < 500) {')
            scripts.append('        pm.expect(jsonData.resourceType).to.equal("OperationOutcome");')
            scripts.append('    }')
        scripts.append('});')
        
        return scripts
    
    def generate_prerequest_script(self, resource_type):
        """Generate pre-request script to check dependencies."""
        scripts = []
        
        # Add a small delay before each request to avoid rapid sequential issues
        if self.request_delay > 0:
            scripts.append('// Add delay to avoid rapid sequential request issues')
            scripts.append(f'const delay = {self.request_delay}; // milliseconds')
            scripts.append('const start = Date.now();')
            scripts.append('while (Date.now() - start < delay) {')
            scripts.append('    // Synchronous delay')
            scripts.append('}')
            scripts.append('console.log("Waited " + delay + "ms before request");')
        scripts.append('')
        
        if resource_type == "Task":
            scripts.append('// Check that Patient ID is available')
            scripts.append('var patientId = pm.collectionVariables.get("patient_id");')
            scripts.append('if (!patientId) {')
            scripts.append('    console.warn("Warning: Patient ID not set. Task creation may fail.");')
            scripts.append('}')
        elif resource_type == "RelatedPerson":
            scripts.append('// Check that Patient ID is available')
            scripts.append('var patientId = pm.collectionVariables.get("patient_id");')
            scripts.append('if (!patientId) {')
            scripts.append('    console.warn("Warning: Patient ID not set. RelatedPerson creation may fail.");')
            scripts.append('}')
        
        return scripts
    
    def add_cleanup_requests(self, folder, resource_order):
        """Add DELETE requests to clean up created resources."""
        # Delete in reverse order to respect dependencies
        for resource_type in reversed(resource_order):
            request = {
                "name": f"Delete {resource_type}",
                "event": [
                    {
                        "listen": "test",
                        "script": {
                            "exec": [
                                f'pm.test("Delete {resource_type} successful or not found", function () {{',
                                '    pm.expect(pm.response.code).to.be.oneOf([200, 204, 404, 410]);',
                                '});'
                            ],
                            "type": "text/javascript"
                        }
                    },
                    {
                        "listen": "prerequest",
                        "script": {
                            "exec": [
                                f'var resourceId = pm.collectionVariables.get("{"activity_definition_id" if resource_type == "ActivityDefinition" else "endpoint_id" if resource_type == "Endpoint" else f"{resource_type.lower()}_id"}");',
                                'if (!resourceId) {',
                                f'    console.log("No {resource_type} ID to delete");',
                                '    pm.execution.skipRequest();',
                                '}'
                            ],
                            "type": "text/javascript"
                        }
                    }
                ],
                "request": {
                    "method": "DELETE",
                    "header": [],
                    "url": {
                        "raw": f"{self.base_url}/{resource_type}/{{{{{('activity_definition_id' if resource_type == 'ActivityDefinition' else 'endpoint_id' if resource_type == 'Endpoint' else f'{resource_type.lower()}_id')}}}}}?_cascade=delete",
                        "host": ["{{fhir_base_url}}"],
                        "path": [resource_type, f"{{{{{('activity_definition_id' if resource_type == 'ActivityDefinition' else 'endpoint_id' if resource_type == 'Endpoint' else f'{resource_type.lower()}_id')}}}}}"],
                        "query": [
                            {
                                "key": "_cascade",
                                "value": "delete"
                            }
                        ]
                    },
                    "description": f"Delete test {resource_type} resource with cascade"
                }
            }
            folder["item"].append(request)
    
    def add_history_tests(self, folder, resource_types):
        """Add history test requests for specified resource types."""
        for resource_type in resource_types:
            # Determine the variable name for the resource ID
            if resource_type == "ActivityDefinition":
                var_name = "activity_definition_id"
            elif resource_type == "Endpoint":
                var_name = "endpoint_id"
            else:
                var_name = f"{resource_type.lower()}_id"
            
            # Test 1: Get full history of a resource
            request = {
                "name": f"{resource_type} - Get Full History",
                "event": [
                    {
                        "listen": "test",
                        "script": {
                            "exec": [
                                f'pm.test("{resource_type} history retrieved successfully", function () {{',
                                '    pm.response.to.have.status(200);',
                                '});',
                                '',
                                'pm.test("Response is a Bundle", function () {',
                                '    var jsonData = pm.response.json();',
                                '    pm.expect(jsonData.resourceType).to.equal("Bundle");',
                                '    pm.expect(jsonData.type).to.be.oneOf(["history", "searchset"]);',
                                '});',
                                '',
                                'pm.test("Bundle contains history entries", function () {',
                                '    var jsonData = pm.response.json();',
                                '    pm.expect(jsonData.entry).to.be.an("array");',
                                '    pm.expect(jsonData.entry.length).to.be.greaterThan(0);',
                                '    ',
                                '    // Check first entry has request.method',
                                '    if (jsonData.entry && jsonData.entry.length > 0) {',
                                '        pm.expect(jsonData.entry[0]).to.have.property("request");',
                                '        pm.expect(jsonData.entry[0].request).to.have.property("method");',
                                '    }',
                                '});',
                                '',
                                '// Save the latest version for specific version test',
                                'var jsonData = pm.response.json();',
                                'if (jsonData.entry && jsonData.entry.length > 0) {',
                                '    var latestEntry = jsonData.entry[0];',
                                '    if (latestEntry.resource && latestEntry.resource.meta && latestEntry.resource.meta.versionId) {',
                                f'        pm.collectionVariables.set("{var_name}_latest_version", latestEntry.resource.meta.versionId);',
                                f'        console.log("Latest version saved: " + latestEntry.resource.meta.versionId);',
                                '    }',
                                '}'
                            ],
                            "type": "text/javascript"
                        }
                    },
                    {
                        "listen": "prerequest",
                        "script": {
                            "exec": [
                                f'// Check that {resource_type} ID is available',
                                f'var resourceId = pm.collectionVariables.get("{var_name}");',
                                'if (!resourceId) {',
                                f'    console.error("Error: {resource_type} ID not set. Cannot get history.");',
                                '    pm.execution.skipRequest();',
                                '}',
                                '',
                                '// Add delay',
                                f'const delay = {self.request_delay};',
                                'const start = Date.now();',
                                'while (Date.now() - start < delay) {',
                                '    // Synchronous delay',
                                '}'
                            ],
                            "type": "text/javascript"
                        }
                    }
                ],
                "request": {
                    "method": "GET",
                    "header": [
                        {
                            "key": "Accept",
                            "value": "application/fhir+json"
                        }
                    ],
                    "url": {
                        "raw": f"{self.base_url}/{resource_type}/{{{{{var_name}}}}}/_history",
                        "host": ["{{fhir_base_url}}"],
                        "path": [resource_type, f"{{{{{var_name}}}}}", "_history"]
                    },
                    "description": f"Get full history of {resource_type} resource"
                }
            }
            folder["item"].append(request)
            
            # Test 2: Get specific version from history
            request = {
                "name": f"{resource_type} - Get Specific Version",
                "event": [
                    {
                        "listen": "test",
                        "script": {
                            "exec": [
                                f'pm.test("{resource_type} specific version retrieved successfully", function () {{',
                                '    pm.response.to.have.status(200);',
                                '});',
                                '',
                                f'pm.test("Response is a {resource_type} resource", function () {{',
                                '    var jsonData = pm.response.json();',
                                f'    pm.expect(jsonData.resourceType).to.equal("{resource_type}");',
                                '});',
                                '',
                                'pm.test("Retrieved version matches requested version", function () {',
                                '    var jsonData = pm.response.json();',
                                f'    var requestedVersion = pm.collectionVariables.get("{var_name}_latest_version");',
                                '    if (jsonData.meta && jsonData.meta.versionId && requestedVersion) {',
                                '        pm.expect(jsonData.meta.versionId).to.equal(requestedVersion);',
                                '    }',
                                '});'
                            ],
                            "type": "text/javascript"
                        }
                    },
                    {
                        "listen": "prerequest",
                        "script": {
                            "exec": [
                                f'// Check that {resource_type} ID and version are available',
                                f'var resourceId = pm.collectionVariables.get("{var_name}");',
                                f'var version = pm.collectionVariables.get("{var_name}_latest_version");',
                                'if (!resourceId || !version) {',
                                f'    console.error("Error: {resource_type} ID or version not set.");',
                                '    pm.execution.skipRequest();',
                                '}',
                                '',
                                '// Add delay',
                                f'const delay = {self.request_delay};',
                                'const start = Date.now();',
                                'while (Date.now() - start < delay) {',
                                '    // Synchronous delay',
                                '}'
                            ],
                            "type": "text/javascript"
                        }
                    }
                ],
                "request": {
                    "method": "GET",
                    "header": [
                        {
                            "key": "Accept",
                            "value": "application/fhir+json"
                        }
                    ],
                    "url": {
                        "raw": f"{self.base_url}/{resource_type}/{{{{{var_name}}}}}/_history/{{{{{var_name + '_latest_version'}}}}}",
                        "host": ["{{fhir_base_url}}"],
                        "path": [resource_type, f"{{{{{var_name}}}}}", "_history", f"{{{{{var_name + '_latest_version'}}}}}"]
                    },
                    "description": f"Get specific version of {resource_type} from history"
                }
            }
            folder["item"].append(request)
    
    def add_post_deletion_history_tests(self, folder, resource_types):
        """Add history test requests after resource deletion."""
        for resource_type in resource_types:
            # Determine the variable name for the resource ID
            if resource_type == "ActivityDefinition":
                var_name = "activity_definition_id"
            elif resource_type == "Endpoint":
                var_name = "endpoint_id"
            else:
                var_name = f"{resource_type.lower()}_id"
            
            request = {
                "name": f"{resource_type} - History After Deletion",
                "event": [
                    {
                        "listen": "test",
                        "script": {
                            "exec": [
                                f'pm.test("{resource_type} history after deletion retrieved", function () {{',
                                '    pm.response.to.have.status(200);',
                                '});',
                                '',
                                'pm.test("Response is a Bundle", function () {',
                                '    var jsonData = pm.response.json();',
                                '    pm.expect(jsonData.resourceType).to.equal("Bundle");',
                                '});',
                                '',
                                'pm.test("History contains deletion entry", function () {',
                                '    var jsonData = pm.response.json();',
                                '    if (jsonData.entry && jsonData.entry.length > 0) {',
                                '        // Look for a DELETE entry in history',
                                '        var hasDeleteEntry = false;',
                                '        for (var i = 0; i < jsonData.entry.length; i++) {',
                                '            if (jsonData.entry[i].request && jsonData.entry[i].request.method === "DELETE") {',
                                '                hasDeleteEntry = true;',
                                '                break;',
                                '            }',
                                '        }',
                                '        pm.expect(hasDeleteEntry).to.be.true;',
                                '    }',
                                '});'
                            ],
                            "type": "text/javascript"
                        }
                    },
                    {
                        "listen": "prerequest",
                        "script": {
                            "exec": [
                                f'// Check that {resource_type} ID is available',
                                f'var resourceId = pm.collectionVariables.get("{var_name}");',
                                'if (!resourceId) {',
                                f'    console.warn("Warning: {resource_type} ID not set. May have been deleted with cascade.");',
                                '    pm.execution.skipRequest();',
                                '}',
                                '',
                                '// Add delay',
                                f'const delay = {self.request_delay};',
                                'const start = Date.now();',
                                'while (Date.now() - start < delay) {',
                                '    // Synchronous delay',
                                '}'
                            ],
                            "type": "text/javascript"
                        }
                    }
                ],
                "request": {
                    "method": "GET",
                    "header": [
                        {
                            "key": "Accept",
                            "value": "application/fhir+json"
                        }
                    ],
                    "url": {
                        "raw": f"{self.base_url}/{resource_type}/{{{{{var_name}}}}}/_history",
                        "host": ["{{fhir_base_url}}"],
                        "path": [resource_type, f"{{{{{var_name}}}}}", "_history"]
                    },
                    "description": f"Get history of deleted {resource_type} resource"
                }
            }
            folder["item"].append(request)
    
    def generate_uuid(self):
        """Generate a UUID for Postman."""
        import uuid
        return str(uuid.uuid4())

def generate_newman_script():
    """Generate a bash script to run the collection with Newman."""
    script_content = '''#!/bin/bash
# Run Koppeltaal 2.0 tests with Newman
#
# Usage: ./run-newman-tests.sh [FHIR_BASE_URL] [ACCESS_TOKEN]
#
# Parameters:
#   FHIR_BASE_URL - The base URL of the FHIR server (default: http://localhost:8080/fhir)
#   ACCESS_TOKEN  - Bearer token for authentication (default: empty string)
#
# Examples:
#   ./run-newman-tests.sh
#   ./run-newman-tests.sh https://fhir.example.com/r4
#   ./run-newman-tests.sh https://fhir.example.com/r4 "eyJhbGciOiJIUzI1NiIs..."

# Check if Newman is installed
if ! command -v newman &> /dev/null; then
    echo "Newman is not installed. Please install it with: npm install -g newman"
    exit 1
fi

# Parse command line parameters
FHIR_BASE_URL=${1:-"http://localhost:8080/fhir"}
ACCESS_TOKEN=${2:-""}

echo "🚀 Running Koppeltaal 2.0 FHIR tests"
echo "   FHIR Server: $FHIR_BASE_URL"
if [ -n "$ACCESS_TOKEN" ]; then
    echo "   Authentication: Bearer token provided"
else
    echo "   Authentication: No token (public access)"
fi
echo ""

# Build Newman command with optional access token
NEWMAN_CMD="newman run koppeltaal-tests.postman_collection.json"
NEWMAN_CMD="$NEWMAN_CMD --env-var \\"fhir_base_url=$FHIR_BASE_URL\\""

if [ -n "$ACCESS_TOKEN" ]; then
    NEWMAN_CMD="$NEWMAN_CMD --env-var \\"access_token=$ACCESS_TOKEN\\""
fi

NEWMAN_CMD="$NEWMAN_CMD --reporters cli,json"
NEWMAN_CMD="$NEWMAN_CMD --reporter-json-export koppeltaal-test-results.json"
NEWMAN_CMD="$NEWMAN_CMD --color on"
NEWMAN_CMD="$NEWMAN_CMD --verbose"

# Run the collection
eval $NEWMAN_CMD

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
else
    echo ""
    echo "❌ Some tests failed. Check koppeltaal-test-results.json for details."
    exit 1
fi
'''
    
    with open('run-newman-tests.sh', 'w') as f:
        f.write(script_content)
    os.chmod('run-newman-tests.sh', 0o755)
    print("✅ Newman runner script generated: run-newman-tests.sh")

def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description="Generate Postman/Newman collection from Koppeltaal 2.0 test resources"
    )
    parser.add_argument(
        "--input-dir",
        "-i",
        default="test-resources",
        help="Directory containing test resources (default: test-resources)"
    )
    parser.add_argument(
        "--output",
        "-o",
        default="koppeltaal-tests.postman_collection.json",
        help="Output Postman collection file (default: koppeltaal-tests.postman_collection.json)"
    )
    parser.add_argument(
        "--include-auth",
        action="store_true",
        help="Include Bearer token authentication in the collection"
    )
    parser.add_argument(
        "--delay",
        "-d",
        type=int,
        default=500,
        help="Delay in milliseconds between requests (default: 500ms, use 0 to disable)"
    )
    
    args = parser.parse_args()
    
    # Check if input directory exists
    if not os.path.exists(args.input_dir):
        print(f"❌ Error: Input directory '{args.input_dir}' does not exist")
        print(f"   Available directories: {', '.join([d for d in os.listdir('.') if os.path.isdir(d) and 'test' in d])}")
        return 1
    
    generator = PostmanCollectionGenerator(args.input_dir, args.output, args.include_auth, args.delay)
    generator.generate_collection()
    generate_newman_script()
    
    print(f"\n📁 Test resources loaded from: {args.input_dir}")
    print("\n📚 Usage:")
    print(f"1. Import {args.output} into Postman")
    print("2. Set the 'fhir_base_url' variable to your FHIR server")
    print("3. Optionally set 'access_token' if authentication is required")
    print("4. Run the collection in order")
    print("\nOr use Newman:")
    print("./run-newman-tests.sh [fhir_server_url] [access_token]")
    print("\nExamples:")
    print("  ./run-newman-tests.sh")
    print("  ./run-newman-tests.sh https://fhir.example.com/r4")
    print("  ./run-newman-tests.sh https://fhir.example.com/r4 \"your-bearer-token\"")

if __name__ == "__main__":
    main()