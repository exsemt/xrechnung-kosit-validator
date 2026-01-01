# Dockerfile für KoSIT Validator Service mit eingebautem Daemon-Modus
FROM eclipse-temurin:17-jre

LABEL maintainer="xsatz"
LABEL description="KoSIT Validator für XRechnung und ZUGFeRD"

WORKDIR /validator

# Install curl, wget und unzip
RUN apt-get update && \
    apt-get install -y curl wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Download KoSIT Validator standalone JAR
ARG VALIDATOR_VERSION=1.5.2
RUN wget https://repo1.maven.org/maven2/org/kosit/validator/${VALIDATOR_VERSION}/validator-${VALIDATOR_VERSION}-standalone.jar -O /validator/validator.jar

# Download XRechnung Configuration
ARG CONFIG_VERSION=2025-07-10
RUN wget https://github.com/itplr-kosit/validator-configuration-xrechnung/releases/download/release-${CONFIG_VERSION}/validator-configuration-xrechnung_3.0.2_${CONFIG_VERSION}.zip && \
    unzip validator-configuration-xrechnung_3.0.2_${CONFIG_VERSION}.zip -d /validator/config && \
    rm validator-configuration-xrechnung_3.0.2_${CONFIG_VERSION}.zip && \
    apt-get remove -y wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8080

# Health Check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/server/health || exit 1

# Umgebungsvariablen
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Start KoSIT Validator im Daemon-Modus
CMD java $JAVA_OPTS -jar /validator/validator.jar \
    -s /validator/config/scenarios.xml \
    -D \
    -H 0.0.0.0 \
    -P 8080
