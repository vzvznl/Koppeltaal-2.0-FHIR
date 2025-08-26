FROM mcr.microsoft.com/dotnet/sdk:8.0

# Build argument for IG Publisher version
ARG PUBLISHER_VERSION=2.0.15

RUN dotnet tool install -g firely.terminal && apt-get update && apt install -y make jq default-jdk python3 python3-pip python3-yaml graphviz jekyll nodejs npm

RUN npm install -g fsh-sushi

RUN mkdir "/src"
WORKDIR /src

RUN curl -L https://github.com/HL7/fhir-ig-publisher/releases/download/${PUBLISHER_VERSION}/publisher.jar -o /usr/local/publisher.jar

# FHIR_EMAIL can stay as ENV since it's not sensitive
ENV FHIR_EMAIL=roland@headease.nl
# FHIR_PASSWORD will be provided via secret mount at build time
ENV saxonPath=/root/.ant/lib/
RUN mkdir -p ${saxonPath}
RUN wget https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/11.4/Saxon-HE-11.4.jar -O ${saxonPath}/saxon-he-11.4.jar
RUN wget https://repo1.maven.org/maven2/org/xmlresolver/xmlresolver/5.3.0/xmlresolver-5.3.0.jar -O ${saxonPath}/xmlresolver-5.3.0.jar

ENV DEBUG=1

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
