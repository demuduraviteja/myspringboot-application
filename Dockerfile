# Use a minimal base image for building
FROM alpine:latest AS build
WORKDIR /appCode

RUN apk add --no-cache openjdk17 curl

# Arguments for Nexus
ARG NEXUS_URL
ARG GROUP_ID
ARG ARTIFACT_ID
ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD
ARG SNAPSHOT_JAR  

# Convert ARGs to ENV (Docker expands ARGs only in ENV, COPY, and RUN with shell expansion)
ENV NEXUS_URL=$NEXUS_URL
ENV GROUP_ID=$GROUP_ID
ENV ARTIFACT_ID=$ARTIFACT_ID
ENV NEXUS_USERNAME=$NEXUS_USERNAME
ENV NEXUS_PASSWORD=$NEXUS_PASSWORD
ENV SNAPSHOT_JAR=$SNAPSHOT_JAR

# Ensure there is no trailing slash in NEXUS_URL before using it
RUN NEXUS_URL=$(echo $NEXUS_URL | sed 's:/*$::') && \
    echo "Downloading JAR from: ${NEXUS_URL}/${GROUP_ID}/${ARTIFACT_ID}/1.0-SNAPSHOT/${SNAPSHOT_JAR}" && \
    curl -u "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" -f -o "/appCode/app.jar" \
    "${NEXUS_URL}/${GROUP_ID}/${ARTIFACT_ID}/1.0-SNAPSHOT/${SNAPSHOT_JAR}"

# Minimal runtime image
FROM alpine:latest
WORKDIR /appCode

RUN apk add --no-cache openjdk17

COPY --from=build /appCode/app.jar /appCode/app.jar

EXPOSE 8085
ENTRYPOINT ["java", "-jar", "/appCode/app.jar"]