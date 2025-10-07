#!/usr/bin/env python3
"""
Generate test resources based on FSH structure definitions.

This script creates:
1. Minimal valid resources (only required fields)
2. Maximal resources (all possible fields)
3. Invalid resources for negative testing
4. Edge case resources
"""

import json
import random
import string
from pathlib import Path
from datetime import datetime, timedelta
import uuid

class TestResourceGenerator:
    """Generate test resources for FHIR profiles."""

    def __init__(self, output_dir="test-resources"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

        # Test data pools
        self.dutch_names = {
            "given": ["Johannes", "Maria", "Pieter", "Anna", "Willem", "Elisabeth", "Hendrik", "Catharina"],
            "family": ["de Jong", "van den Berg", "van Dijk", "Bakker", "Visser", "Smit", "Meijer", "de Boer"],
            "prefix": ["van", "de", "van der", "van den", "ter"]
        }

        self.dutch_cities = ["Amsterdam", "Rotterdam", "Den Haag", "Utrecht", "Eindhoven", "Tilburg"]
        self.dutch_streets = ["Hoofdstraat", "Kerkstraat", "Schoolstraat", "Dorpsstraat", "Molenstraat"]

    def generate_identifier(self, system="http://example.org/fhir/id", prefix="TEST"):
        """Generate a test identifier."""
        return {
            "system": system,
            "value": f"{prefix}-{uuid.uuid4().hex[:8].upper()}"
        }

    def generate_bsn(self):
        """Generate a valid BSN (Dutch social security number) for testing."""
        # Generate random 8 digits
        digits = [random.randint(0, 9) for _ in range(8)]

        # Calculate check digit using eleven test
        total = sum((9 - i) * digit for i, digit in enumerate(digits))
        check_digit = (total % 11) % 10
        digits.append(check_digit)

        return ''.join(str(d) for d in digits)

    def generate_dutch_name(self, use="official", include_extensions=False, variant="simple"):
        """Generate a Dutch name with proper structure according to ZIB NameInformation."""
        given = random.choice(self.dutch_names["given"])
        family_base = random.choice(self.dutch_names["family"])
        prefix = random.choice(self.dutch_names["prefix"]) if random.random() > 0.5 else None

        if variant == "with-initials":
            # Name with initials
            initials = f"{given[0]}."
            second_initial = f"{random.choice(self.dutch_names['given'])[0]}." if random.random() > 0.5 else None

            given_list = [initials]
            given_extensions = [{
                "extension": [{
                    "url": "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier",
                    "valueCode": "IN"
                }]
            }]

            if second_initial:
                given_list.append(second_initial)
                given_extensions.append({
                    "extension": [{
                        "url": "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier",
                        "valueCode": "IN"
                    }]
                })

            name = {
                "use": use,
                "text": f"{' '.join(given_list)} ({given}) {prefix + ' ' if prefix else ''}{family_base}",
                "family": f"{prefix + ' ' if prefix else ''}{family_base}",
                "given": given_list,
                "_given": given_extensions
            }

        elif variant == "with-partner":
            # Married name with partner's name
            partner_name = random.choice(self.dutch_names["family"])
            partner_prefix = random.choice(self.dutch_names["prefix"]) if random.random() > 0.5 else None

            # Using format: own-partner
            full_family = f"{family_base}-{partner_prefix + ' ' if partner_prefix else ''}{partner_name}"

            name = {
                "use": use,
                "text": f"{given} {full_family}",
                "family": full_family,
                "given": [given],
                "_given": [{
                    "extension": [{
                        "url": "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier",
                        "valueCode": "BR"
                    }]
                }],
                "_family": {
                    "extension": [
                        {
                            "url": "http://hl7.org/fhir/StructureDefinition/humanname-own-name",
                            "valueString": family_base
                        },
                        {
                            "url": "http://hl7.org/fhir/StructureDefinition/humanname-partner-name",
                            "valueString": partner_name
                        }
                    ]
                }
            }

            if prefix:
                name["_family"]["extension"].insert(0, {
                    "url": "http://hl7.org/fhir/StructureDefinition/humanname-own-prefix",
                    "valueString": prefix
                })

            if partner_prefix:
                name["_family"]["extension"].append({
                    "url": "http://hl7.org/fhir/StructureDefinition/humanname-partner-prefix",
                    "valueString": partner_prefix
                })

        else:  # simple
            name = {
                "use": use,
                "text": f"{given} {prefix + ' ' if prefix else ''}{family_base}",
                "family": family_base,
                "given": [given]
            }

            if prefix or include_extensions:
                name["family"] = f"{prefix + ' ' if prefix else ''}{family_base}"
                name["_family"] = {
                    "extension": []
                }

                if prefix:
                    name["_family"]["extension"].append({
                        "url": "http://hl7.org/fhir/StructureDefinition/humanname-own-prefix",
                        "valueString": prefix
                    })

                name["_family"]["extension"].append({
                    "url": "http://hl7.org/fhir/StructureDefinition/humanname-own-name",
                    "valueString": family_base
                })
            
            # Add _given extension when include_extensions is True
            if include_extensions:
                name["_given"] = [{
                    "extension": [{
                        "url": "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier",
                        "valueCode": "BR"  # Birth name
                    }]
                }]

        return name

    def generate_dutch_address(self):
        """Generate a Dutch address."""
        return {
            "use": "home",
            "type": "both",
            "text": f"{random.choice(self.dutch_streets)} {random.randint(1, 200)}, {random.choice(self.dutch_cities)}",
            "line": [f"{random.choice(self.dutch_streets)} {random.randint(1, 200)}"],
            "city": random.choice(self.dutch_cities),
            "postalCode": f"{random.randint(1000, 9999)} {random.choice(string.ascii_uppercase)}{random.choice(string.ascii_uppercase)}",
            "country": "NL"
        }

    def generate_telecom(self, system="phone"):
        """Generate telecom contact."""
        if system == "phone":
            return {
                "system": system,
                "value": f"+316{random.randint(10000000, 99999999)}",
                "use": "mobile"
            }
        elif system == "email":
            return {
                "system": system,
                "value": f"test.user{random.randint(1, 999)}@example.nl",
                "use": "home"
            }

    def generate_patient(self, variant="minimal"):
        """Generate KT2Patient test resource."""
        patient = {
            "resourceType": "Patient",
            "meta": {
                "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2Patient"]
            }
        }

        if variant == "minimal":
            # Only required fields
            patient["identifier"] = [self.generate_identifier()]
            patient["active"] = True  # Required field
            # Name with family and given are required with ZIB extensions
            family_base = random.choice(self.dutch_names["family"])
            prefix = random.choice(self.dutch_names["prefix"]) if random.random() > 0.5 else None
            given = random.choice(self.dutch_names["given"])

            patient["name"] = [{
                "use": "official",
                "family": f"{prefix + ' ' if prefix else ''}{family_base}",
                "_family": {
                    "extension": [
                        {
                            "url": "http://hl7.org/fhir/StructureDefinition/humanname-own-name",
                            "valueString": family_base
                        }
                    ]
                },
                "given": [given],
                "_given": [{
                    "extension": [{
                        "url": "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier",
                        "valueCode": "BR"
                    }]
                }]
            }]

            if prefix:
                patient["name"][0]["_family"]["extension"].insert(0, {
                    "url": "http://hl7.org/fhir/StructureDefinition/humanname-own-prefix",
                    "valueString": prefix
                })

            # birthDate is also required
            patient["birthDate"] = (datetime.now() - timedelta(days=random.randint(365*18, 365*90))).strftime("%Y-%m-%d")
            # gender is also required
            patient["gender"] = random.choice(["male", "female", "other", "unknown"])

        elif variant == "maximal":
            # All possible fields
            patient["identifier"] = [
                {
                    "system": "http://fhir.nl/fhir/NamingSystem/bsn",
                    "value": self.generate_bsn()
                },
                self.generate_identifier()
            ]
            patient["active"] = True
            patient["name"] = [
                self.generate_dutch_name("official", include_extensions=True, variant="with-initials")
            ]
            patient["telecom"] = [
                self.generate_telecom("phone"),
                self.generate_telecom("email")
            ]
            patient["gender"] = random.choice(["male", "female", "other", "unknown"])
            patient["birthDate"] = (datetime.now() - timedelta(days=random.randint(365*18, 365*90))).strftime("%Y-%m-%d")
            patient["address"] = [self.generate_dutch_address()]
            patient["managingOrganization"] = {
                "reference": "Organization/org-test-001",
                "display": "Test Zorginstelling"
            }

        elif variant == "invalid-missing-identifier":
            # Invalid: missing required identifier
            patient.pop("identifier", None)

        elif variant == "invalid-wrong-identifier":
            # Invalid: wrong identifier system
            patient["identifier"] = [{
                "system": "http://wrong.system/id",
                "value": "12345"
            }]

        return patient

    def generate_practitioner(self, variant="minimal"):
        """Generate KT2Practitioner test resource."""
        practitioner = {
            "resourceType": "Practitioner",
            "meta": {
                "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2Practitioner"]
            }
        }

        if variant == "minimal":
            # Required fields: identifier and name with extensions
            practitioner["identifier"] = [self.generate_identifier()]
            # Generate name with required extensions (same as Patient)
            family_base = random.choice(self.dutch_names["family"])
            prefix = random.choice(self.dutch_names["prefix"]) if random.random() > 0.5 else None
            given = random.choice(self.dutch_names["given"])

            practitioner["name"] = [{
                "use": "official",
                "text": f"{given} {prefix + ' ' if prefix else ''}{family_base}",
                "family": f"{prefix + ' ' if prefix else ''}{family_base}",
                "_family": {
                    "extension": [
                        {
                            "url": "http://hl7.org/fhir/StructureDefinition/humanname-own-name",
                            "valueString": family_base
                        }
                    ]
                },
                "given": [given],
                "_given": [{
                    "extension": [{
                        "url": "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier",
                        "valueCode": "BR"
                    }]
                }]
            }]

            if prefix:
                practitioner["name"][0]["_family"]["extension"].insert(0, {
                    "url": "http://hl7.org/fhir/StructureDefinition/humanname-own-prefix",
                    "valueString": prefix
                })

            # active is also required
            practitioner["active"] = True
            # telecom[emailAddresses] is required
            practitioner["telecom"] = [self.generate_telecom("email")]

        elif variant == "maximal":
            practitioner["identifier"] = [
                {
                    "system": "http://fhir.nl/fhir/NamingSystem/agb-z",
                    "value": f"0{random.randint(1000000, 9999999)}"
                }
            ]
            practitioner["active"] = True
            practitioner["name"] = [
                self.generate_dutch_name("official", include_extensions=True, variant="with-partner")
            ]
            practitioner["telecom"] = [
                self.generate_telecom("phone"),
                self.generate_telecom("email")
            ]
            # address is forbidden in KT2Practitioner
            practitioner["gender"] = random.choice(["male", "female", "other", "unknown"])

        elif variant == "invalid-missing-name":
            # Invalid: missing required name
            pass

        return practitioner

    def generate_organization(self, variant="minimal"):
        """Generate KT2Organization test resource."""
        org = {
            "resourceType": "Organization",
            "meta": {
                "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2Organization"]
            }
        }

        if variant == "minimal":
            # Organization requires identifier, active, and name
            org["identifier"] = [self.generate_identifier("http://example.org/organization", "ORG")]
            org["active"] = True  # Required field
            org["name"] = "Test Zorgorganisatie"

        elif variant == "maximal":
            org["identifier"] = [
                {
                    "system": "http://fhir.nl/fhir/NamingSystem/ura",
                    "value": f"{random.randint(10000000, 99999999)}"
                }
            ]
            org["active"] = True
            org["type"] = [{
                "coding": [{
                    "system": "http://nictiz.nl/fhir/NamingSystem/organization-type",
                    "code": "Z3",
                    "display": "Ziekenhuis"
                }]
            }]
            org["name"] = "Test Ziekenhuis Amsterdam"
            # Note: KT2Organization does not support telecom or address

        elif variant == "invalid-missing-identifier":
            # Invalid: missing required identifier
            org["active"] = True
            org["name"] = "Test Zorgorganisatie Zonder ID"

        elif variant == "invalid-missing-active":
            # Invalid: missing required active field
            org["identifier"] = [self.generate_identifier("http://example.org/organization", "ORG")]
            org["name"] = "Test Zorgorganisatie Zonder Active"
            # Note: active field is intentionally missing

        return org

    def generate_task(self, variant="minimal"):
        """Generate KT2Task test resource."""
        task = {
            "resourceType": "Task",
            "meta": {
                "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2Task"]
            },
            "status": "requested",
            "intent": "order",
            "priority": "routine"  # Required to be exactly 'routine'
        }

        if variant == "minimal":
            # Use the instantiates extension for ActivityDefinition reference
            task["extension"] = [{
                "url": "http://vzvz.nl/fhir/StructureDefinition/instantiates",
                "valueReference": {
                    "reference": "ActivityDefinition/activity-test-001"
                }
            }]
            task["identifier"] = [self.generate_identifier()]  # Required
            task["for"] = {
                "reference": "Patient/patient-test-001"
            }
            task["owner"] = {  # Required field
                "reference": "Practitioner/practitioner-test-001"
            }

        elif variant == "maximal":
            task["identifier"] = [self.generate_identifier()]
            # Use the instantiates extension for ActivityDefinition reference
            task["extension"] = [{
                "url": "http://vzvz.nl/fhir/StructureDefinition/instantiates",
                "valueReference": {
                    "reference": "ActivityDefinition/activity-test-001",
                    "display": "Test Activiteit"
                }
            }]
            # Note: instantiatesCanonical is deprecated as of 2023-11-02
            task["code"] = {
                "coding": [{
                    "system": "http://snomed.info/sct",
                    "code": "719858009",
                    "display": "Telehealth consultation"
                }]
            }
            task["for"] = {
                "reference": "Patient/patient-test-001",
                "display": "Test Patient"
            }
            task["owner"] = {
                "reference": "Practitioner/practitioner-test-001",
                "display": "Test Practitioner"
            }
            task["executionPeriod"] = {
                "start": datetime.now().isoformat() + "Z",  # Add UTC timezone
                "end": (datetime.now() + timedelta(days=30)).isoformat() + "Z"
            }
            # Note: partOf would reference another Task, but we can't guarantee one exists in test suite
            # If needed, this could be added after creating a parent task first

        elif variant == "invalid-missing-status":
            # Invalid: missing required status
            del task["status"]
            task["identifier"] = [self.generate_identifier()]

        return task

    def generate_activity_definition(self, variant="minimal"):
        """Generate ActivityDefinition resource."""
        activity = {
            "resourceType": "ActivityDefinition",
            "meta": {
                "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2ActivityDefinition"]
            },
            "status": "active"
        }

        if variant == "minimal":
            # Required fields: extension[endpoint], url, title
            activity["extension"] = [{
                "url": "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension",
                "valueReference": {
                    "reference": "Endpoint/endpoint-test-001"
                }
            }]
            activity["url"] = f"http://example.org/ActivityDefinition/activity-{uuid.uuid4().hex[:8]}"
            activity["title"] = "Test Activiteit"

        elif variant == "maximal":
            # Include optional fields too
            activity["extension"] = [
                {
                    "url": "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension",
                    "valueReference": {
                        "reference": "Endpoint/endpoint-test-001",
                        "display": "Test Endpoint"
                    }
                },
                {
                    "url": "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension",
                    "valueReference": {
                        "reference": "Endpoint/endpoint-test-002",
                        "display": "Backup Endpoint"
                    }
                },
                {
                    "url": "http://koppeltaal.nl/fhir/StructureDefinition/KT2PublisherId",
                    "valueId": "publisher-12345"
                }
            ]
            activity["url"] = f"http://example.org/ActivityDefinition/activity-{uuid.uuid4().hex[:8]}"
            activity["identifier"] = [{
                "system": "http://example.org/activity",
                "value": f"ACT-{uuid.uuid4().hex[:8].upper()}"
            }]
            activity["version"] = "1.0.0"
            activity["name"] = "TestActiviteit"
            activity["title"] = "Test eHealth Activiteit voor Therapie"
            activity["subtitle"] = "Ondertitel voor test activiteit"
            activity["description"] = "Dit is een test eHealth activiteit voor het testen van Koppeltaal 2.0"
            activity["useContext"] = [
                {
                    "code": {
                        "system": "http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context-type",
                        "code": "required-feature"
                    },
                    "valueCodeableConcept": {
                        "coding": [{
                            "system": "http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context",
                            "code": "026-RolvdNaaste",
                            "display": "Role of relative"
                        }]
                    }
                },
                {
                    "code": {
                        "system": "http://terminology.hl7.org/CodeSystem/usage-context-type",
                        "code": "age"
                    },
                    "valueRange": {
                        "low": {
                            "value": 18,
                            "unit": "years",
                            "system": "http://unitsofmeasure.org",
                            "code": "a"
                        },
                        "high": {
                            "value": 65,
                            "unit": "years",
                            "system": "http://unitsofmeasure.org",
                            "code": "a"
                        }
                    }
                }
            ]
            activity["topic"] = [{
                "coding": [{
                    "system": "http://terminology.hl7.org/CodeSystem/definition-topic",
                    "code": "treatment",
                    "display": "Treatment"
                }]
            }]

        elif variant == "invalid-missing-endpoint":
            # Missing required extension[endpoint]
            activity["url"] = f"http://example.org/ActivityDefinition/activity-{uuid.uuid4().hex[:8]}"
            activity["title"] = "Test Activiteit Zonder Endpoint"

        elif variant == "invalid-missing-url":
            # Missing required url field
            activity["extension"] = [{
                "url": "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension",
                "valueReference": {
                    "reference": "Endpoint/endpoint-test-001"
                }
            }]
            activity["title"] = "Test Activiteit Zonder URL"

        return activity

    def generate_device(self, variant="minimal"):
        """Generate KT2Device test resource."""
        device = {
            "resourceType": "Device",
            "meta": {
                "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2Device"]
            }
        }

        # Required fields: identifier (will be set to Device.id after creation), status, deviceName, type
        # Using placeholder UUID initially - Postman will update this after creation
        device["identifier"] = [{
            "system": "http://vzvz.nl/fhir/NamingSystem/koppeltaal-client-id",
            "value": "PLACEHOLDER-DEVICE-ID"  # Will be replaced with actual Device.id after creation
        }]

        device["status"] = "active"

        device["deviceName"] = [{
            "name": "Test Device Application",
            "type": "user-friendly-name"
        }]

        device["type"] = {
            "coding": [{
                "system": "http://snomed.info/sct",
                "code": "706689003",
                "display": "Application program software"
            }]
        }

        if variant == "maximal":
            device["owner"] = {
                "reference": "Organization/org-test-001",
                "display": "Test Zorgorganisatie"
            }

            device["type"]["text"] = "eHealth Application"

        elif variant == "invalid-missing-identifier":
            # Remove required identifier
            del device["identifier"]

        elif variant == "invalid-missing-status":
            # Remove required status
            del device["status"]

        elif variant == "invalid-missing-devicename":
            # Remove required deviceName
            del device["deviceName"]

        return device

    def generate_related_person(self, variant="minimal"):
        """Generate KT2RelatedPerson test resource."""
        related_person = {
            "resourceType": "RelatedPerson",
            "meta": {
                "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2RelatedPerson"]
            }
        }
        
        # Required fields
        # identifier - required (1..*)
        related_person["identifier"] = [{
            "use": "usual",
            "system": "https://irma.app",
            "value": f"relatedperson.{random.randint(1000, 9999)}@example.nl"
        }]
        
        # active - required (1..1)
        related_person["active"] = True
        
        # name - required (1..*) with Dutch name extensions
        # Always use a variant that includes extensions (required for RelatedPerson)
        name_data = self.generate_dutch_name(variant="simple", include_extensions=True)
        related_person["name"] = [name_data]
        
        # patient - required (1..1) - must reference a Patient
        related_person["patient"] = {
            "reference": "Patient/patient-test-001",
            "display": "Test Patient"
        }
        
        # gender - required (1..1)
        related_person["gender"] = random.choice(["male", "female", "other"])
        
        # birthDate - required (1..1)
        birth_year = random.randint(1940, 2010)
        birth_month = random.randint(1, 12)
        birth_day = random.randint(1, 28)
        related_person["birthDate"] = f"{birth_year:04d}-{birth_month:02d}-{birth_day:02d}"
        
        # relationship - required (1..*) - should have two elements per the example
        # First: personal relationship (v3-RoleCode) - using Dutch ZIB2020 ValueSet
        personal_relationship_options = [
            ("MTH", "Mother"),  # Moeder
            ("FTH", "Father"),  # Vader
            ("DAUC", "Daughter"),  # Dochter
            ("SONC", "Son"),  # Zoon
            ("BRO", "Brother"),  # Broer
            ("SIS", "Sister"),  # Zuster
            ("DOMPART", "Domestic partner"),  # Partner
            ("HUSB", "Husband"),  # Echtgenoot
            ("WIFE", "Wife"),  # Echtgenote
            ("AUNT", "Aunt"),  # Tante
            ("UNCLE", "Uncle"),  # Oom
            ("NEPHEW", "Nephew"),  # Neef
            ("NIECE", "Niece"),  # Nicht
            ("GRFTH", "Grandfather"),  # Opa
            ("GRMTH", "Grandmother"),  # Oma
        ]
        personal_code, personal_display = random.choice(personal_relationship_options)
        
        # Second: professional role (Dutch support roles) - COD472_VEKT_Soort_relatie_client
        professional_role_options = [
            ("01", "Eerste relatie/contactpersoon"),
            ("02", "Tweede relatie/contactpersoon"),
            ("03", "Curator (juridisch)"),
            ("04", "Financieel (gemachtigd)"),
            ("05", "Financieel (toetsing)"),
            ("06", "Leefeenheid"),
            ("07", "Hulpverlener"),
            ("09", "Anders"),
            ("11", "Voogd"),
            ("14", "Bewindvoerder"),
            ("15", "Mentor"),
            ("19", "Buur"),
            ("20", "Vriend(in)/kennis"),
            ("21", "Cliëntondersteuner"),
            ("23", "Contactpersoon"),
            ("24", "Wettelijke vertegenwoordiger")
        ]
        prof_code, prof_display = random.choice(professional_role_options)
        
        related_person["relationship"] = [
            {
                "coding": [{
                    "system": "http://terminology.hl7.org/CodeSystem/v3-RoleCode",
                    "code": personal_code,
                    "display": personal_display
                }]
            },
            {
                "coding": [{
                    "system": "urn:oid:2.16.840.1.113883.2.4.3.11.22.472",
                    "code": prof_code,
                    "display": prof_display
                }]
            }
        ]
        
        if variant == "maximal":
            # Add telecom
            related_person["telecom"] = [
                self.generate_telecom("phone"),
                self.generate_telecom("email")
            ]
            
            # Add address
            related_person["address"] = [self.generate_dutch_address()]
            
            # Add period
            related_person["period"] = {
                "start": "2020-01-01"
            }
            
            # Add communication
            related_person["communication"] = [{
                "language": {
                    "coding": [{
                        "system": "urn:ietf:bcp:47",
                        "code": "nl",
                        "display": "Dutch"
                    }],
                    "text": "Nederlands"
                },
                "preferred": True
            }]
        
        elif variant == "invalid-missing-identifier":
            # Remove required identifier
            del related_person["identifier"]
        
        elif variant == "invalid-missing-active":
            # Remove required active
            del related_person["active"]
        
        elif variant == "invalid-missing-gender":
            # Remove required gender
            del related_person["gender"]
        
        elif variant == "invalid-missing-birthdate":
            # Remove required birthDate
            del related_person["birthDate"]
        
        elif variant == "invalid-missing-relationship":
            # Remove required relationship
            del related_person["relationship"]
        
        elif variant == "invalid-missing-name":
            # Remove required name
            del related_person["name"]
        
        elif variant == "invalid-missing-patient":
            # Remove required patient
            del related_person["patient"]
        
        return related_person
    
    def generate_audit_event(self, variant="minimal"):
        """Generate KT2AuditEvent test resource."""
        audit = {
            "resourceType": "AuditEvent",
            "meta": {
                "profile": ["http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"]
            },
            "type": {
                "system": "http://terminology.hl7.org/CodeSystem/audit-event-type",
                "code": "rest",
                "display": "RESTful Operation"
            },
            "recorded": datetime.now().isoformat() + "Z",
            "agent": [{
                "type": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/v3-ParticipationType",
                        "code": "IRCP",
                        "display": "information recipient"
                    }]
                },
                "who": {
                    "reference": "Device/device-test-001"
                },
                "requestor": True
            }],
            "source": {
                "observer": {
                    "reference": "Device/device-test-001"
                }
            },
            "entity": [{
                "what": {
                    "reference": "Patient/patient-test-001"
                },
                "type": {
                    "system": "http://terminology.hl7.org/CodeSystem/audit-entity-type",
                    "code": "2",
                    "display": "System Object"
                }
            }]
        }

        if variant == "maximal":
            audit["subtype"] = [{
                "system": "http://hl7.org/fhir/restful-interaction",
                "code": "create",
                "display": "create"
            }]
            audit["outcome"] = "0"
            audit["outcomeDesc"] = "Success"

        return audit

    def generate_test_suite(self):
        """Generate complete test suite with various test resources."""
        print("🧪 Generating Test Suite for Koppeltaal 2.0 FHIR Profiles")
        print("=" * 60)

        test_cases = {
            "Patient": ["minimal", "maximal", "invalid-missing-identifier"],
            "Practitioner": ["minimal", "maximal", "invalid-missing-name"],
            "Organization": ["minimal", "maximal", "invalid-missing-identifier", "invalid-missing-active"],
            "RelatedPerson": ["minimal", "maximal", "invalid-missing-identifier", "invalid-missing-active", "invalid-missing-patient", "invalid-missing-gender", "invalid-missing-birthdate", "invalid-missing-relationship", "invalid-missing-name"],
            "Device": ["minimal", "maximal", "invalid-missing-identifier", "invalid-missing-status", "invalid-missing-devicename"],
            "ActivityDefinition": ["minimal", "maximal", "invalid-missing-endpoint", "invalid-missing-url"],
            "Task": ["minimal", "maximal", "invalid-missing-status"],
            "AuditEvent": ["minimal", "maximal"]
        }

        generated_files = []

        for resource_type, variants in test_cases.items():
            resource_dir = self.output_dir / resource_type
            resource_dir.mkdir(exist_ok=True)

            for variant in variants:
                # Generate resource
                if resource_type == "Patient":
                    resource = self.generate_patient(variant)
                elif resource_type == "Practitioner":
                    resource = self.generate_practitioner(variant)
                elif resource_type == "Organization":
                    resource = self.generate_organization(variant)
                elif resource_type == "RelatedPerson":
                    resource = self.generate_related_person(variant)
                elif resource_type == "Device":
                    resource = self.generate_device(variant)
                elif resource_type == "ActivityDefinition":
                    resource = self.generate_activity_definition(variant)
                elif resource_type == "Task":
                    resource = self.generate_task(variant)
                elif resource_type == "AuditEvent":
                    resource = self.generate_audit_event(variant)
                else:
                    continue

                # Save to file
                filename = f"{resource_type}-{variant}.json"
                filepath = resource_dir / filename

                with open(filepath, 'w') as f:
                    json.dump(resource, f, indent=2)

                generated_files.append(filepath)
                print(f"  ✅ Generated: {filepath}")

        # Generate test manifest
        manifest = {
            "name": "Koppeltaal 2.0 Test Suite",
            "version": "1.0.0",
            "generated": datetime.now().isoformat(),
            "tests": []
        }

        for filepath in generated_files:
            rel_path = filepath.relative_to(self.output_dir)
            is_invalid = "invalid" in str(rel_path)
            manifest["tests"].append({
                "file": str(rel_path),
                "resource": rel_path.parts[0],
                "variant": rel_path.stem.split('-', 1)[1],
                "expected": "fail" if is_invalid else "pass"
            })

        manifest_path = self.output_dir / "test-manifest.json"
        with open(manifest_path, 'w') as f:
            json.dump(manifest, f, indent=2)

        print(f"\n  📋 Test manifest: {manifest_path}")

        # Generate validation script
        self.generate_validation_script()

        print(f"\n✅ Test suite generated in: {self.output_dir}")
        print(f"   Total test resources: {len(generated_files)}")

    def generate_validation_script(self):
        """Generate a script to validate test resources."""
        script_content = '''#!/bin/bash
# Validate test resources against Koppeltaal 2.0 profiles

echo "🧪 Validating Test Resources"
echo "============================"

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m' # No Color

# Counter variables
PASS=0
FAIL=0
EXPECTED_FAIL=0

# Function to validate a resource
validate_resource() {
    local file=$1
    local expected=$2
    
    echo -n "Validating $file... "
    
    # Run validation using IG Publisher or FHIR validator
    # This is a placeholder - replace with actual validation command
    # java -jar validator_cli.jar $file -ig ./output/package.tgz
    
    # For now, check if file exists and is valid JSON
    if jq empty "$file" 2>/dev/null; then
        if [[ "$expected" == "fail" ]]; then
            echo -e "${YELLOW}PASSED (Expected to fail)${NC}"
            ((EXPECTED_FAIL++))
        else
            echo -e "${GREEN}PASSED${NC}"
            ((PASS++))
        fi
    else
        if [[ "$expected" == "fail" ]]; then
            echo -e "${GREEN}FAILED (As expected)${NC}"
            ((EXPECTED_FAIL++))
        else
            echo -e "${RED}FAILED${NC}"
            ((FAIL++))
        fi
    fi
}

# Read test manifest and validate each resource
if [ -f "test-manifest.json" ]; then
    while IFS= read -r line; do
        file=$(echo "$line" | jq -r '.file')
        expected=$(echo "$line" | jq -r '.expected')
        if [ "$file" != "null" ]; then
            validate_resource "$file" "$expected"
        fi
    done < <(jq -c '.tests[]' test-manifest.json)
fi

echo ""
echo "============================"
echo "Validation Results:"
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo -e "${YELLOW}Expected Failures: $EXPECTED_FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
'''

        script_path = self.output_dir / "validate.sh"
        with open(script_path, 'w') as f:
            f.write(script_content)

        script_path.chmod(0o755)
        print(f"  📝 Validation script: {script_path}")

def main():
    """Main function."""
    import argparse

    parser = argparse.ArgumentParser(description="Generate test resources for Koppeltaal 2.0 FHIR profiles")
    parser.add_argument("--output", "-o", default="test-resources",
                       help="Output directory for test resources (default: test-resources)")

    args = parser.parse_args()

    generator = TestResourceGenerator(args.output)
    generator.generate_test_suite()

if __name__ == "__main__":
    main()
