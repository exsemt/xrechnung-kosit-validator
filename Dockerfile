# Dockerfile for KoSIT Validator Service with built-in daemon mode
FROM eclipse-temurin:25-jre-alpine

ARG VALIDATOR_VERSION=1.6.3
ARG CONFIG_VERSION=2026-08-31
ARG XRECHNUNG_VERSION=3.0.2

LABEL maintainer="xsatz"
LABEL description="KoSIT Validator for XRechnung and ZUGFeRD"
LABEL validator.version="${VALIDATOR_VERSION}"
LABEL xrechnung.version="${XRECHNUNG_VERSION}"
LABEL xrechnung.config.date="${CONFIG_VERSION}"
LABEL org.opencontainers.image.source="https://github.com/exsemt/xrechnung-kosit-validator"

WORKDIR /validator

# Install dependencies, download artifacts, and create non-root user
# hadolint ignore=DL3018
RUN apk add --no-cache curl wget unzip && \
    wget --progress=dot:giga "https://repo1.maven.org/maven2/org/kosit/validator/${VALIDATOR_VERSION}/validator-${VALIDATOR_VERSION}-standalone.jar" -O /validator/validator.jar && \
    wget --progress=dot:giga "https://github.com/itplr-kosit/validator-configuration-xrechnung/releases/download/v${CONFIG_VERSION}/xrechnung-${XRECHNUNG_VERSION}-validator-configuration-${CONFIG_VERSION}.zip" && \
    unzip -q "xrechnung-${XRECHNUNG_VERSION}-validator-configuration-${CONFIG_VERSION}.zip" -d /validator/config && \
    rm "xrechnung-${XRECHNUNG_VERSION}-validator-configuration-${CONFIG_VERSION}.zip" && \
    apk del wget unzip && \
    addgroup -g 1000 -S validator && \
    adduser -u 1000 -S -G validator -h /validator -s /sbin/nologin validator && \
    chown -R validator:validator /validator

USER 1000:1000

EXPOSE 8080

# Health Check
# hadolint ignore=DL3025
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/server/health || exit 1

# Environment variables
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Start KoSIT Validator in daemon mode
CMD ["sh", "-c", "java $JAVA_OPTS -jar /validator/validator.jar -s /validator/config/scenarios.xml -D -H 0.0.0.0 -P 8080 --disable-gui"]
