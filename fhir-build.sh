#!/bin/zsh
export PATH=$PATH:$HOME/.dotnet/tools
fhir login email=$FHIR_EMAIL password=$FHIR_PASSWORD
fhir install nictiz.fhir.nl.r4.zib2020 0.11.0-beta.1
fhir install nictiz.fhir.nl.r4.nl-core 0.11.0-beta.1
fhir pack

