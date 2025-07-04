FROM mcr.microsoft.com/dotnet/sdk:8.0

RUN dotnet tool install -g firely.terminal && apt-get update && apt install -y zsh jq default-jdk
RUN PATH=$PATH:$HOME/.dotnet/tools && fhir install nictiz.fhir.nl.r4.zib2020 0.11.0-beta.1

RUN mkdir "/src"
WORKDIR /src

ENV FHIR_EMAIL=roland@headease.nl
ENV FHIR_PASSWORD=...
ENV saxonPath=/root/.ant/lib/
RUN mkdir -p ${saxonPath}
RUN wget https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/11.4/Saxon-HE-11.4.jar -O ${saxonPath}/saxon-he-11.4.jar
RUN wget https://repo1.maven.org/maven2/org/xmlresolver/xmlresolver/5.3.0/xmlresolver-5.3.0.jar -O ${saxonPath}/xmlresolver-5.3.0.jar


ENV DEBUG=1


ENTRYPOINT ["zsh", "./fhir-build.sh"]
