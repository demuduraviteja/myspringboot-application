# Use a minimal base image for building
FROM alpine:latest AS build
WORKDIR /appCode

RUN apk add --no-cache openjdk17 curl

ARG NEXUS_URL
ARG GROUP_ID
ARG ARTIFACT_ID
ARG VERSION
ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD

# Fetch latest snapshot JAR from Nexus metadata
RUN latest_version=$(curl -s -u "$NEXUS_USERNAME:$NEXUS_PASSWORD" "$NEXUS_URL/${GROUP_ID//./\/}/$ARTIFACT_ID/$VERSION/maven-metadata.xml" | \
    grep '<value>' | tail -1 | sed 's/.*<value>\(.*\)<\/value>.*/\1/') \
    && echo "Latest Snapshot Version: $latest_version" \
    && curl -u "$NEXUS_USERNAME:$NEXUS_PASSWORD" -f -o "/appCode/${ARTIFACT_ID}-${latest_version}.jar" \
    "$NEXUS_URL/${GROUP_ID//./\/}/$ARTIFACT_ID/$VERSION/${ARTIFACT_ID}-${latest_version}.jar"

# Minimal runtime image
FROM alpine:latest
WORKDIR /appCode

RUN apk add --no-cache openjdk17

COPY --from=build /appCode/${ARTIFACT_ID}-*.jar /appCode/app.jar

EXPOSE 8085
ENTRYPOINT ["java", "-jar", "/appCode/app.jar"]