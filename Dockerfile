# Dockerfile for KoSIT Validator Service with built-in daemon mode
FROM eclipse-temurin:25-jre

LABEL maintainer="xsatz"
LABEL description="KoSIT Validator for XRechnung and ZUGFeRD"

WORKDIR /validator

# Install curl, wget and unzip
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Download KoSIT Validator standalone JAR
ARG VALIDATOR_VERSION=1.6.3
RUN wget --progress=dot:giga https://repo1.maven.org/maven2/org/kosit/validator/${VALIDATOR_VERSION}/validator-${VALIDATOR_VERSION}-standalone.jar -O /validator/validator.jar

# Download XRechnung Configuration
ARG CONFIG_VERSION=2026-08-31
ARG XRECHNUNG_VERSION=3.0.2
RUN wget --progress=dot:giga https://github.com/itplr-kosit/validator-configuration-xrechnung/releases/download/v${CONFIG_VERSION}/xrechnung-${XRECHNUNG_VERSION}-validator-configuration-${CONFIG_VERSION}.zip && \
    unzip xrechnung-${XRECHNUNG_VERSION}-validator-configuration-${CONFIG_VERSION}.zip -d /validator/config && \
    rm xrechnung-${XRECHNUNG_VERSION}-validator-configuration-${CONFIG_VERSION}.zip && \
    apt-get remove -y wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r validator && \
    useradd -r -g validator -d /validator -s /sbin/nologin validator && \
    chown -R validator:validator /validator

USER validator

EXPOSE 8080

# Health Check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/server/health || exit 1

# Environment variables
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Start KoSIT Validator in daemon mode
CMD ["sh", "-c", "java $JAVA_OPTS -jar /validator/validator.jar -s /validator/config/scenarios.xml -D -H 0.0.0.0 -P 8080 --disable-gui"]
