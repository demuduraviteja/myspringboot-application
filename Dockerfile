# Use a minimal base image for building
FROM alpine:latest AS build
WORKDIR /appCode

RUN apk add --no-cache openjdk17 curl

# Arguments for Nexus
ARG NEXUS_URL
ARG ARTIFACT_ID
ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD
ARG SNAPSHOT_JAR  # Passed from Jenkins Groovy script

# Construct the correct download URL and download the JAR file
RUN echo "Downloading JAR from: $NEXUS_URL/$ARTIFACT_ID/1.0-SNAPSHOT/$SNAPSHOT_JAR" && \
    curl -u "$NEXUS_USERNAME:$NEXUS_PASSWORD" -f -o "/appCode/app.jar" \
    "$NEXUS_URL/$ARTIFACT_ID/1.0-SNAPSHOT/$SNAPSHOT_JAR"

# Minimal runtime image
FROM alpine:latest
WORKDIR /appCode

RUN apk add --no-cache openjdk17

COPY --from=build /appCode/app.jar /appCode/app.jar

EXPOSE 8085
ENTRYPOINT ["java", "-jar", "/appCode/app.jar"]