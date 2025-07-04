#!/bin/zsh

ME_DIR="$( cd "$( dirname "${(%):-%x}" )" && pwd )"

# assume we are in scripts
ROOT_DIR="$( dirname "$ME_DIR" )"

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
ORANGE='\033[0;33m'

. "${ROOT_DIR}/scripts/make-packages.sh"

function validate {

    h=${1}
    validator=${2:-''}

    if [[ "${validator}" == "" ]]; then
        echo -n --- normal validator 
    else
        echo -n ------ new validator
    fi
    echo ' -------------------' "${h}"
    fhir --fail validate "${h}" ${validator}  > tmp/"${h}.txt"
    RETURN_CODE=$?

    RESULT=$(grep -v 'INVALID' tmp/"${h}.txt" | grep 'VALID' | cut -d' ' -f2)

    if [[ "$RESULT" == "VALID" ]]; then
        # display a green something
        echo -e "${GREEN}${RESULT}${NC} ${h}"
        RETURN_CODE=0
    else
        grep -v \
        -e 'does not exist in the value set .MedicatieToedieningswegCodelijst' \
        -e 'does not exist in the value set .Aanvullende Informatie voor MA' \
        -e 'does not exist in the value set .Aanvullende gebruiksinstructie' \
        -e 'does not exist in the value set .MedicatieToedieningToedieningswegCodelijst' \
        -e 'does not exist in the value set .NHG tabel 14v7' \
        -e 'does not exist in valueset .http://decor.nictiz.nl/fhir/ValueSet/2.16.840.1.113883.2.4.3.11.60.103.11.3--20110902000000' \
        -e 'from system .urn:oid:2.16.840.1.113883.2.4.4.9. does not exist in valueset' \
        -e 'from system .urn:oid:2.16.840.1.113883.2.4.4.7. does not exist in the value set' \
        -e 'from system .urn:oid:2.16.840.1.113883.2.4.3.11.60.20.77.5.2.14.2050. does not exist in valueset' \
        -e 'from system .https://referentiemodel.nhg.org/tabellen/nhg-tabel-25-gebruiksvoorschrift#aanvullend-numeriek. does not exist in valueset' \
        -e 'Cannot resolve canonical reference .http://www.nanda.org/. to CodeSystem' \
        -e 'Cannot resolve canonical reference .urn.iso.std.iso.3166. to CodeSystem' \
        -e 'Cannot resolve canonical reference .http://fhir.nl/fhir/NamingSystem/uzi-rolcode' \
        -e 'Cannot resolve canonical reference .urn:oid:2.16.840.1.113883.2.4.4.1' \
        -e 'Cannot resolve canonical reference .urn:oid:2.16.840.1.113883.2.4.4.1.750' \
        -e 'Cannot resolve canonical reference .urn:oid:2.16.840.1.113883.2.4.4.1.900.2' \
        -e 'Cannot resolve canonical reference .urn:oid:2.16.840.1.113883.2.4.4.1.902.122' \
        -e 'Cannot resolve canonical reference .urn:oid:2.16.840.1.113883.2.4.6.7' \
        -e 'Cannot resolve canonical reference .urn:oid:2.16.840.1.113883.2.4.4.7' \
        -e 'Cannot resolve canonical reference .urn:oid:2.16.840.1.113883.2.4.4.10' \
        -e 'Cannot retrieve valueset .http://www.rfc-editor.org/bcp/bcp13.txt' \
        -e 'No code found in CodeableConcept with a required binding.' \
        -e 'Instance count for .Bundle.entry.* is 0, which is not within the specified cardinality of' \
        -e 'has incorrect display' \
        -e 'fatal: Internal logic failure: Unknown symbol .resolve' \
        -e 'Terminology service failed while validating code .NL.'  \
        -e 'Terminology service failed while validating code .6030.' \
        -e 'Code .nl. from system 'urn:oid:1.0.639.1' does not exist in valueset' \
        -e 'does not exist in the value set .CommunicatieTaalCodelijst' \
        -e 'using the Resolver SDK failed. The method or operation is not implemented' \
        -e 'Found a slice discriminator of type .* which is not yet supported by this validator' \
        -e 'which is not yet supported by this validator' \
        -e 'Validating resource' \
        -e 'Result. INVALID' \
        -e '^$' \
        tmp/"${h}.txt" \
        > tmp/"${h}.result.txt" 2>&1
                
        length=$(grep -v '^[[:blank:]]*$' tmp/"${h}.result.txt" | grep -v 'INVALID' | grep -v 'ERROR' | wc -l)
        if [[ "$length" == '       0' ]]; then
            echo -e "${ORANGE}IGNORED${NC} ${h}"
        else
            # some other error
            echo -e "${RED}ERROR${NC} ${h}"
            cat "tmp/${h}.result.txt"
        fi
    fi
    return $RETURN_CODE
}


function run-quality-control {
  echo
  echo
  echo
  echo ---------------------------------------
  echo "$STAMP" Quality Control
  echo ---------------------------------------

  fhir check vzvz
}

function remove-packages-dir {
  rm -rf "${ROOT_DIR}/packages"
}

cd "${ROOT_DIR}" || exit

"${ROOT_DIR}/scripts/make-packages.sh"

mkdir -p tmp/examples

echo Reloading the packages

reload_packages

STAMP=$(date +"%Y-%m-%d_%H-%M-%S")
echo
echo
echo
echo
echo ---------------------------------------
echo "$STAMP" De valide berichten
echo ---------------------------------------

for h in examples/**.xml ; do
    validate "${h}"
    # validate "${h}" --vnext
done

for h in examples/**.json ; do
    validate "${h}"
    # validate "${h}" --vnext
done


STAMP=$(date +"%Y-%m-%d_%H-%M-%S")
echo
echo
echo
echo
echo ------------------------------------
echo "$STAMP" De foutberichten
echo ------------------------------------

for h in examples/error-examples/*.xml ; do
    validate "${h}"
done

for h in examples/error-examples/*.json ; do
    validate "${h}"
done

echo
echo
echo
echo
echo ---------------------------------------
echo "$STAMP" Quality Control
echo ---------------------------------------

fhir check vzvz

# -------
# Verwijder de inhoud van de packages/koppeltaal directory
# die stoort alleen maar in Forge
# -------

# rm -rf packages/koppeltaal
