#!/bin/bash

# test using the official validator_cli.jar

# Location of the script
ME_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# assume we are in scripts
ROOT_DIR="$( dirname "$ME_DIR" )"

vjar=${ROOT_DIR}/../profielen/validator/validator_cli.jar

project=${1}
rebuild=${2:-'rebuild'}

if [[ "${project}" == '' ]]; then
  echo "$( basename "${0}" )" '<projectnaam: aof, mitz of nl-vzvz-core> <optional: file/files to validate'
  exit 1
fi

if [[ "$rebuild" == 'rebuild' ]]; then
  "${ROOT_DIR}"/scripts/make-packages.sh
fi

projectIG=$( ls -1 "${ROOT_DIR}"/packages/"${project}"*.tgz )
coreIG='vzvz.fhir.nl-vzvz-core'
nictiz_coreIG='nictiz.fhir.nl.r4.nl-core'
nictiz_zibIG='nictiz.fhir.nl.r4.zib2020'

if [[ ! -f "${projectIG}" ]]; then
  echo "maak eerst het package voor ${project} en voor nl-vzvz-core"
  exit 2
fi

# date (now)
DT=$(date +"%Y-%m-%d %H:%M:%S")

echo
echo "${DT}" '-----------------------------------'
echo

fhir='-version 4.0.1'

shift 2
files=${*:-"${ROOT_DIR}/examples/*.json"}

java -jar "${vjar}" ${fhir} -ig "${projectIG}" -ig "${coreIG}" -ig ${nictiz_coreIG} -ig ${nictiz_zibIG} \
  -no-extensible-binding-warnings -advisor-file "${ROOT_DIR}"/suppress_warnings.txt \
  ${files} \
  -output "${ROOT_DIR}/${project}_tmp_validate_result.txt" \
  -output-style compact >> /dev/null

grep -v \
        -e 'Information - .* has no Display Names for the language en' \
        -e 'Information - None of the codings provided are in the value set' \
        -e 'Information - This element does not match any known slice defined in the profile http://vzvz.nl/fhir/StructureDefinition/nl-vzvz-Device' \
        -e 'Information - This element does not match any known slice defined in the profile http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-Practitioner' \
        -e 'Information - This element does not match any known slice defined in the profile http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthcareProvider-Organization' \
        -e 'Information - No types could be determined from the search string, so the types can.t be checked' \
        -e 'Information - The definition for the Code System with URI .* doesn.t provide any codes so the code cannot be validated' \
        -e 'Information - A definition for CodeSystem .*aorta-datareference-update-reason.* could not be found, so the code cannot be validated' \
        -e 'Information - Reference to experimental CodeSystem .*request-intent.*' \
        -e 'Information - Binding for path Bundle.entry.*resource.*Task.*input.*type has no source, so can.t be checked' \
        -e 'Information - Binding for path Task.input.*type has no source, so can.t be checked' \
        -e 'Information - Reference to draft CodeSystem' \
        -e 'Information - This element does not match any known slice defined in the profile http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient' \
        -e 'Information - .* is the default display; the code system' \
        -e 'Warning - A definition for CodeSystem .* could not be found, so the code cannot be validated' \
        -e 'Warning - De definitie voor CodeSystem .* is niet gevonden, dus kan de code niet worden gevalideerd' \
        -e 'Warning - Kan niet controleren of de code in de waardelijst .* staat, omdat het codesysteem .* niet is gevonden' \
        -e 'Warning - Unable to check whether the code is in the value set .* because the code system .* was not found' \
        -e 'Warning - Resolved system .*, but the definition doesn.t include any codes, so the code has not been validated' \
        -e 'Warning - Resolved system urn:ietf:bcp:47, but the definition is not complete, so assuming value set include is correct' \
        -e 'Warning - ValueSet .*medicationrequest-status.* not found' \
        -e 'Warning - ValueSet .*medicationrequest-intent.* not found' \
        -e 'Warning - ValueSet .*administrative-gender.* not found' \
        -e 'Warning - ValueSet .*name-assembly-order.* not found' \
        -e 'Warning - ValueSet .*address-use.* not found' \
        -e 'Warning - ValueSet .*address-type.* not found' \
        -e 'Warning - ValueSet .*operation-outcome.* not found' \
        -e 'Warning - ValueSet .*c80-doc-typecodes.* not found' \
        -e 'Warning - ValueSet .*mimetypes.* not found' \
        -e 'Warning - Found multiple matching profiles for' \
        -e 'Warning - Resolved system urn:ietf:bcp:47, but the definition is not complete, so assuming value set include is correct' \
        -e 'Error - Wrong Display Name .* (for the language(s) .en.)' \
        -e 'Error - None of the codings provided are in the value set .LandCodelijsten' \
        -e '^$' \
        "${ROOT_DIR}/${project}_tmp_validate_result.txt"
        # 2>&1 > tmp/"${h}.result.txt"
