#!/bin/zsh

ME_DIR="$( cd "$( dirname "${(%):-%x}" )" && pwd )"

# assume we are in scripts
ROOT_DIR="$( dirname "$ME_DIR" )"

rm -rf "${ROOT_DIR}/packages"

# publish packages?

publish="${1:-0}"

. ${ME_DIR}/local-paths.sh

saxon_11="$saxonPath/saxon-he-11.4.jar"
saxon="${saxon_11}"


function resultMessage {
  r=$1
  shift
  msg=$*

  [[ $r -eq 0 ]] && result='SUCCESS' || result="$r"

  echo "$result : $msg"
}

function make_package() {
    project="$1"

    echo "Creating package directory for ${project}"
    echo ""

    mkdir -p "${ROOT_DIR}/packages/${project}/resources"
    # mkdir -p "${ROOT_DIR}/packages/${project}/ig"
    # mkdir -p "${ROOT_DIR}/packages/${project}/examples"
   
    if [[ -d "${ROOT_DIR}/resources/${project}" ]]; then 
        cp -R "${ROOT_DIR}/resources/${project}" "${ROOT_DIR}/packages/${project}"
    else
        cp -iR "${ROOT_DIR}"/resources/* "${ROOT_DIR}/packages/${project}/resources"
    fi

    if [[ -e "${ROOT_DIR}/package-${project}.json" ]]; then
        cp "${ROOT_DIR}/package-${project}.json" "${ROOT_DIR}/packages/${project}/package.json"
    else
        cp "${ROOT_DIR}/package.json" "${ROOT_DIR}/packages/${project}/package.json"
    fi

    if [[ -e "${ROOT_DIR}/fhirpkg.lock-${project}.json" ]]; then
        cp "${ROOT_DIR}/fhirpkg.lock-${project}.json" "${ROOT_DIR}/packages/${project}/fhirpkg.lock.json"
    else
        cp "${ROOT_DIR}/fhirpkg.lock.json" "${ROOT_DIR}/packages/${project}/fhirpkg.lock.json"
    fi
    cd "${ROOT_DIR}/packages/${project}"
    # # convert it to json outside of the bake app because somehow that doesn't seem to work
    # # note, fhir push only accepts relative paths
    # fhir push ./ig/*ImplementationGuide*.xml
    # fhir save ./ig/ImplementationGuide.json --json
    echo "Build package for ${project}"

    package_name=$(cat package.json| jq .name | cut -d '"' -f2)
    package_version=$(cat package.json| jq .version | cut -d '"' -f2)
    package_file="${package_name}-${package_version}"

    remove-installed-package "${package_name}" "${package_version}"

    # 2024-09-09 HvdL the bake package script does not do what is expected, but the default action does,
    # so no more bake script. But you need to 'disable' the script otherwise it's picked up automatically.

    # fhir bake "${ROOT_DIR}/package.bake.yaml" --input "." --output "${ROOT_DIR}/packages/${project}" --debug
    mkdir -p "${ROOT_DIR}/packages/${project}/tmp"

    fhir bake --input "." --output "${ROOT_DIR}/packages/${project}/tmp"

    if [[ -d package/examples ]]; then
        for f in $( grep -Fl '"NamingSystem"' package/examples/*); do
            mv $f package
        done
    fi

    # remove empty directories e.g. examples if this is left empty after the previous move
    find package -type d -empty -delete 2>&1 >> /dev/null

    # copy the IG resource here because bake refuses to do that
    # cp ./ig/*.json ./package/

    rm -rf ./examples ./resources ./ig
    
    # 2024-09-09 HvdL remove the name argument. Somehow it throws an error
    # while it also takes the package filename from the package.json information
    # fhir pack --name "${package_file}"
    cd "${ROOT_DIR}/packages/${project}/tmp"

    # 2025-02-19 HvdL copy the package.json because it's not added automatically any more
    cp ../package.json .
    cp ../fhir*lock*.json .
    fhir pack

    mv "${ROOT_DIR}"/packages/"${project}"/tmp/*.tgz "${ROOT_DIR}"/packages/
    mv "${ROOT_DIR}"/packages/"${project}"/tmp/* "${ROOT_DIR}"/packages/"${project}"

    reload-package "${package_name}" "${package_version}"
    echo ''
}

function remove-installed-package {
    package_name=${1}
    package_version=${2}

    fhir remove "${package_name}@${package_version}"
    resultMessage "$?" package removed
    rm -rf ~/.fhir/packages/"${package_name}@${package_version}"
    resultMessage "$?" package removed from ~/.fhir/packages
}

function remove-installed-packages {
  if [[ -d "${ROOT_DIR}/packages" ]]; then
    for d in "${ROOT_DIR}"/packages/*/package.json ; do
        package_name=$(cat "$d" | jq .name | cut -d '"' -f2)
        package_version=$(cat "$d" | jq .version | cut -d '"' -f2)

        remove-installed-package "${package_name}" "${package_version}"
    done
  else
    echo "No packages to remove"
  fi
}

function reload-package {
    package_name=${1}
    package_version=${2}

    remove-installed-package "${package_name}" "${package_version}"

    package_file="${package_name}.${package_version}"

    fhir install "${ROOT_DIR}/packages/${package_file}.tgz" --file
    resultMessage "$?" package installed
}

function reload_packages {
  if [[ -d "${ROOT_DIR}"/packages ]]; then
    for d in "${ROOT_DIR}"/packages/*/package.json ; do
        package_name=$(cat "$d" | jq .name | cut -d '"' -f2)
        package_version=$(cat "$d" | jq .version | cut -d '"' -f2)
        
        reload-package "${package_name}" "${package_version}"
    done
  else
    echo "No packages to reload"
  fi
}

function publish_package() {
    for p in "${ROOT_DIR}"/packages/*.tgz ; do
        package_name=$(basename ${p%.*} )
        echo "Publishing package $(basename ${p%.*} )"
        
        fhir publish-package "${p}"

        releasenotes_file="${ROOT_DIR}/packages/${package_name}_releasenotes.md"

        echo "# Releasenotes for ${package_name}
        " > "${releasenotes_file}"
        git log $(git tag --sort=creatordate | tail -n 2 | head -n 1)..HEAD --pretty=format:"- %s" | grep -v 'MAINT' >> "${releasenotes_file}"

        mail_file="${ROOT_DIR}/packages/${package_name}_mail.md"

        echo "package ${package_name} is gepubliceerd op Simplifier.net" > ${mail_file}

        echo "Update release notes through Simplifier > package > Administration > Edit release notes with ${releasenotes_file/$ROOT_DIR/.}"

        pbcopy < "${releasenotes_file}"

        echo "it's already in the clipboard"
    done
}



function transform {
    local inFile="$1"
    local xslFile="$2"
    local output="$3"
    shift 3
    local localParams=($@)
    local RESULT=0

    if [[ $DEBUG == 1 ]]; then
        echo "transform: local inFile = ${inFile}"
        echo "transform: local xslFile = ${xslFile}"
        echo "transform: local output = ${output}"
        echo "transform: local localParams = ${localParams}"
    fi

    TMPFILE=$(mktemp -t transform.XXXXXX)

    if [[ -z "$localParams" || "$localParams" == "" ]]; then
        if [[ $DEBUG == 1 ]]; then
            echo 'No params available'
            echo java -cp "${saxon}" net.sf.saxon.Transform \
            -s:"${inFile}" \
            -xsl:"${xslFile}" \
            -o:"${output}"
        fi
        java -cp "${saxon}" net.sf.saxon.Transform \
            -s:"${inFile}" \
            -xsl:"${xslFile}" \
            -o:"${output}" 2> $TMPFILE
        RESULT=$?
    else
        if [[ $DEBUG == 1 ]]; then
            echo 'With parameters'
            echo java -cp "${saxon}" net.sf.saxon.Transform \
            -s:"${inFile}" \
            -xsl:"${xslFile}" \
            -o:"${output}" \
            $localParams
        fi

        # Note: geen quotes rondom de parameters, 
        # want dan worden ze gezien als '1' parameter
        java -cp "${saxon}" net.sf.saxon.Transform \
            -s:"${inFile}" \
            -xsl:"${xslFile}" \
            -o:"${output}" \
            $localParams 2> $TMPFILE
        RESULT=$?
    fi

    grep -E 'WARNING|WARN|ERROR|Error' $TMPFILE > /dev/null
    grepResult=$?

    # grepResult = 0 when found and 1 when not found
    # we want the opposite, because a result means there is an error

    grepResult=$(($grepResult != 1))

    # if something happened, return a combined error, defaults to 0 when all is ok
    RESULT=$(( $grepResult * 100 + $RESULT ))

    if [[ $RESULT -ne 0 ]] ; then
        mkdir -p "${ROOT_DIR}/error"
        cp $TMPFILE "${ROOT_DIR}/error/$(basename $xslFile)-$(basename $inFile)-error.log"
    else
        # write other info to info file, just in case, but only if there is content
        if [[ $(( $(wc -c < $TMPFILE) + 0)) > 0 ]]; then
            mkdir -p "${ROOT_DIR}/error"
            cp $TMPFILE "${ROOT_DIR}/error/$(basename $xslFile)-$(basename $inFile)-info.log"
        fi

        mv ${ROOT_DIR}/KT2ImplementationGuide.xml ${output}
    fi

    return $RESULT
}

package_name=$(cat package.json| jq .name | cut -d '"' -f2)
package_version=$(cat package.json| jq .version | cut -d '"' -f2)

echo "package_version = ${package_version}"

transform ${ME_DIR}/ImplementationGuide.xml ${ME_DIR}/generateIG.xsl resources/KT2ImplementationGuide.xml version=$package_version

make_package koppeltaal

if [[ "$publish" == "publish" ]]; then 
    publish_package
fi
