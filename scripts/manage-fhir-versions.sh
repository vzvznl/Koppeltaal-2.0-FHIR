#!/bin/bash
# Manage FHIR resource versions on a HAPI FHIR server
#
# Usage: ./manage-fhir-versions.sh <command> <fhir_base_url>
#
# Commands:
#   detect - Detect unexpected versions of profiles
#   clean  - Remove old/unexpected versions (interactive confirmation)
#   list   - List all versions of Koppeltaal profiles
#
# Parameters:
#   fhir_base_url - The base URL of the FHIR server
#
# Examples:
#   ./manage-fhir-versions.sh detect http://localhost:8080/fhir/DEFAULT
#   ./manage-fhir-versions.sh clean https://staging-fhir-server.koppeltaal.headease.nl/fhir/DEFAULT
#   ./manage-fhir-versions.sh list http://localhost:8080/fhir/DEFAULT

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments
COMMAND=${1:-"detect"}
FHIR_BASE_URL=${2:-"http://localhost:8080/fhir/DEFAULT"}

# Validate command
if [[ ! "$COMMAND" =~ ^(detect|clean|list)$ ]]; then
    echo -e "${RED}Error: Invalid command '$COMMAND'${NC}"
    echo "Valid commands: detect, clean, list"
    exit 1
fi

# Get expected version from sushi-config.yaml
get_expected_version() {
    if [ -f "sushi-config.yaml" ]; then
        grep "^version:" sushi-config.yaml | awk '{print $2}'
    else
        echo "unknown"
    fi
}

EXPECTED_VERSION=$(get_expected_version)

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Koppeltaal FHIR Version Management${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "Command:          ${COMMAND}"
echo -e "FHIR Server:      ${FHIR_BASE_URL}"
echo -e "Expected Version: ${EXPECTED_VERSION}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# List of Koppeltaal profiles to check
PROFILES=(
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2ActivityDefinition"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2AuditEvent"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2CareTeam"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2Device"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2Endpoint"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2Organization"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2Patient"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2Practitioner"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2RelatedPerson"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2Subscription"
    "http://koppeltaal.nl/fhir/StructureDefinition/KT2Task"
)

# CodeSystems and ValueSets to check
CODESYSTEMS=(
    "http://vzvz.nl/fhir/CodeSystem/koppeltaal-expansion"
    "http://vzvz.nl/fhir/CodeSystem/koppeltaal-usage-context-type"
)

VALUESETS=(
    "http://vzvz.nl/fhir/ValueSet/koppeltaal-expansion"
    "http://vzvz.nl/fhir/ValueSet/koppeltaal-use-context-type"
)

# Function to query FHIR server for a specific canonical URL
query_resource() {
    local url=$1
    local resource_type=$2

    curl -s "${FHIR_BASE_URL}/${resource_type}?url=${url}" \
        -H "Accept: application/fhir+json" 2>/dev/null || echo '{"total": 0, "entry": []}'
}

# Function to delete a resource by ID
delete_resource() {
    local resource_type=$1
    local resource_id=$2

    curl -s -X DELETE "${FHIR_BASE_URL}/${resource_type}/${resource_id}" \
        -H "Accept: application/fhir+json" 2>/dev/null
}

# Function to process resources
process_resources() {
    local resource_type=$1
    shift
    local urls=("$@")

    local total_issues=0
    local resources_to_clean=()

    for url in "${urls[@]}"; do
        local response=$(query_resource "$url" "$resource_type")
        local total=$(echo "$response" | jq -r '.total // 0')

        if [ "$total" -gt 1 ]; then
            echo -e "${YELLOW}⚠ Found ${total} versions of ${resource_type}: ${url}${NC}" >&2

            # Get all versions
            local versions=$(echo "$response" | jq -r '.entry[] | "\(.resource.version)|\(.resource.id)|\(.resource.date // "unknown")"')

            # Use process substitution to avoid subshell issue
            while IFS='|' read -r version id date; do
                if [ "$version" = "$EXPECTED_VERSION" ]; then
                    echo -e "  ${GREEN}✓ Keep${NC} Version: ${version}, ID: ${id}, Date: ${date}" >&2
                else
                    echo -e "  ${RED}✗ Remove${NC} Version: ${version}, ID: ${id}, Date: ${date}" >&2
                    if [ "$COMMAND" = "clean" ]; then
                        # Write directly to temp file to avoid subshell issue
                        echo "${resource_type}|${id}|${url}|${version}" >> /tmp/resources_to_clean_$$.txt
                    fi
                fi
            done <<< "$versions"

            total_issues=$((total_issues + 1))
            echo "" >&2

        elif [ "$total" -eq 1 ]; then
            local version=$(echo "$response" | jq -r '.entry[0].resource.version // "unknown"')
            local id=$(echo "$response" | jq -r '.entry[0].resource.id // "unknown"')

            if [ "$version" != "$EXPECTED_VERSION" ]; then
                echo -e "${YELLOW}⚠ Unexpected version of ${resource_type}: ${url}${NC}" >&2
                echo -e "  Found: ${version}, Expected: ${EXPECTED_VERSION}, ID: ${id}" >&2
                echo "" >&2
                total_issues=$((total_issues + 1))

                if [ "$COMMAND" = "clean" ]; then
                    # Write directly to temp file
                    echo "${resource_type}|${id}|${url}|${version}" >> /tmp/resources_to_clean_$$.txt
                fi
            elif [ "$COMMAND" = "list" ]; then
                echo -e "${GREEN}✓${NC} ${resource_type}: ${url##*/} - Version: ${version}" >&2
            fi
        elif [ "$total" -eq 0 ] && [ "$COMMAND" = "list" ]; then
            echo -e "${RED}✗${NC} ${resource_type}: ${url##*/} - Not found" >&2
        fi
    done

    echo "$total_issues"
}

# Detect or list resources
echo -e "${BLUE}Checking StructureDefinitions...${NC}"
sd_issues=$(process_resources "StructureDefinition" "${PROFILES[@]}")

echo -e "${BLUE}Checking CodeSystems...${NC}"
cs_issues=$(process_resources "CodeSystem" "${CODESYSTEMS[@]}")

echo -e "${BLUE}Checking ValueSets...${NC}"
vs_issues=$(process_resources "ValueSet" "${VALUESETS[@]}")

total_issues=$((sd_issues + cs_issues + vs_issues))

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

if [ "$COMMAND" = "detect" ]; then
    if [ "$total_issues" -eq 0 ]; then
        echo -e "${GREEN}✓ No version issues detected!${NC}"
        echo -e "All resources have the expected version: ${EXPECTED_VERSION}"
    else
        echo -e "${RED}✗ Found ${total_issues} resource(s) with version issues${NC}"
        echo -e "Run with 'clean' command to remove old versions"
    fi
elif [ "$COMMAND" = "clean" ]; then
    if [ -f "/tmp/resources_to_clean_$$.txt" ]; then
        mapfile -t resources_to_clean < /tmp/resources_to_clean_$$.txt
        rm -f /tmp/resources_to_clean_$$.txt

        echo -e "${YELLOW}Found ${#resources_to_clean[@]} resource(s) to clean${NC}"
        echo ""

        # Show what will be deleted
        echo "The following resources will be deleted:"
        for resource_info in "${resources_to_clean[@]}"; do
            IFS='|' read -r resource_type id url version <<< "$resource_info"
            echo "  - ${resource_type}/${id} (${url##*/} version ${version})"
        done
        echo ""

        # Confirm deletion
        read -p "Do you want to proceed with deletion? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo -e "${BLUE}Deleting old versions...${NC}"

            for resource_info in "${resources_to_clean[@]}"; do
                IFS='|' read -r resource_type id url version <<< "$resource_info"
                echo -e "Deleting ${resource_type}/${id} (version ${version})..."

                result=$(delete_resource "$resource_type" "$id")

                if echo "$result" | jq -e '.resourceType == "OperationOutcome"' > /dev/null 2>&1; then
                    severity=$(echo "$result" | jq -r '.issue[0].severity // "unknown"')
                    if [ "$severity" = "information" ]; then
                        echo -e "  ${GREEN}✓ Deleted successfully${NC}"
                    else
                        echo -e "  ${RED}✗ Error deleting: $(echo "$result" | jq -r '.issue[0].diagnostics // "Unknown error"')${NC}"
                    fi
                else
                    echo -e "  ${GREEN}✓ Deleted successfully${NC}"
                fi
            done

            echo ""
            echo -e "${GREEN}✓ Cleanup completed!${NC}"
        else
            echo -e "${YELLOW}Cleanup cancelled${NC}"
        fi
    else
        echo -e "${GREEN}✓ No resources to clean!${NC}"
    fi
elif [ "$COMMAND" = "list" ]; then
    echo -e "Listed all Koppeltaal resources"
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
