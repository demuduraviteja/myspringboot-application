# Use Amazon Linux 2 as the base image for building the app
FROM amazonlinux:2 AS build

WORKDIR /appCode

# Install Java and curl using yum
RUN yum update -y && \
    yum install -y java-17-amazon-corretto curl

# Define build arguments (Passed from Jenkins Pipeline)
ARG NEXUS_URL
ARG GROUP_ID
ARG ARTIFACT_ID
ARG VERSION
ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD

# Print Nexus Username for debugging (Remove after testing)
RUN echo "Nexus Username: $NEXUS_USERNAME"

# Download the JAR file from Nexus
RUN export NEXUS_USERNAME=$NEXUS_USERNAME && \
    export NEXUS_PASSWORD=$NEXUS_PASSWORD && \
    curl -u $NEXUS_USERNAME:$NEXUS_PASSWORD -O $NEXUS_URL/${GROUP_ID//./\/}/$ARTIFACT_ID/$VERSION/${ARTIFACT_ID}-${VERSION}.jar

# Use a minimal runtime image
FROM amazonlinux:2

WORKDIR /appCode

# Install only Java runtime (not curl)
RUN yum install -y java-17-amazon-corretto && yum clean all

# Copy the JAR from the build stage
COPY --from=build /appCode/${ARTIFACT_ID}-${VERSION}.jar /appCode/app.jar

EXPOSE 8085

# Run the JAR file
ENTRYPOINT ["java", "-jar", "/appCode/app.jar"]