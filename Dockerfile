# Use a minimal base image for building
FROM alpine:latest AS build
WORKDIR /appCode

RUN apk add --no-cache openjdk17 curl

# Arguments for Nexus
ARG NEXUS_URL
ARG GROUP_ID
ARG ARTIFACT_ID
ARG VERSION
ARG SNAPSHOT_JAR
ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD

# Convert ARGs to ENV
ENV NEXUS_URL=${NEXUS_URL%/}  # Remove trailing slash from NEXUS_URL
ENV GROUP_ID=$GROUP_ID
ENV ARTIFACT_ID=$ARTIFACT_ID
ENV VERSION=$VERSION
ENV SNAPSHOT_JAR=$SNAPSHOT_JAR
ENV NEXUS_USERNAME=$NEXUS_USERNAME
ENV NEXUS_PASSWORD=$NEXUS_PASSWORD

# Convert Maven group ID to directory structure and construct correct URL
RUN GROUP_PATH=$(echo $GROUP_ID | sed 's/\./\//g') && \
    CLEAN_NEXUS_URL=$(echo $NEXUS_URL | sed 's:/*$::') && \
    DOWNLOAD_URL="${CLEAN_NEXUS_URL}/${GROUP_PATH}/${ARTIFACT_ID}/${VERSION}/${SNAPSHOT_JAR}" && \
    echo "Downloading JAR from: ${DOWNLOAD_URL}" && \
    curl -u "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" -f -o "/appCode/app.jar" "${DOWNLOAD_URL}"

# Minimal runtime image
FROM alpine:latest
WORKDIR /appCode

RUN apk add --no-cache openjdk17

COPY --from=build /appCode/app.jar /appCode/app.jar

EXPOSE 8085
ENTRYPOINT ["java", "-jar", "/appCode/app.jar"]