FROM alpine:latest AS build
WORKDIR /appCode

RUN apk add --no-cache openjdk17 curl

ARG NEXUS_URL
ARG GROUP_ID
ARG ARTIFACT_ID
ARG VERSION
ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD

RUN echo "Downloading: $NEXUS_URL/${GROUP_ID//./\/}/$ARTIFACT_ID/$VERSION/${ARTIFACT_ID}-${VERSION}.jar" \
    && curl -u "$NEXUS_USERNAME:$NEXUS_PASSWORD" -f -o "/appCode/${ARTIFACT_ID}-${VERSION}.jar" "$NEXUS_URL/${GROUP_ID//./\/}/$ARTIFACT_ID/$VERSION/${ARTIFACT_ID}-${VERSION}.jar"

FROM alpine:latest
WORKDIR /appCode

RUN apk add --no-cache openjdk17

COPY --from=build /appCode/${ARTIFACT_ID}-${VERSION}.jar /appCode/app.jar

EXPOSE 8085
ENTRYPOINT ["java", "-jar", "/appCode/app.jar"]