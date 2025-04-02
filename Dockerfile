# Use Amazon Linux 2 as the base image
FROM amazonlinux:2 AS build

WORKDIR /app

# Install Java and curl using yum
RUN yum update -y && \
    yum install -y java-17-amazon-corretto curl

# Define build arguments
ARG NEXUS_URL="http://13.234.225.16:8081/repository/maven-snapshots"
ARG GROUP_ID="org.ravi.springboot"
ARG ARTIFACT_ID="my-springboot"
ARG VERSION="1.0.0"
ARG JAR_NAME="${ARTIFACT_ID}-${VERSION}.jar"

RUN echo "Nexus Username: $NEXUS_USERNAME"

# Download the JAR file at build time
RUN curl -u $NEXUS_USERNAME:$NEXUS_PASSWORD -O $NEXUS_URL/${GROUP_ID//./\/}/$ARTIFACT_ID/$VERSION/$JAR_NAME

# Use a minimal runtime image
FROM amazonlinux:2

WORKDIR /app

# Install Java runtime only (not curl)
RUN yum install -y java-17-amazon-corretto && yum clean all

# Copy the JAR from the build stage
COPY --from=build /app/${ARTIFACT_ID}-${VERSION}.jar /app/app.jar

EXPOSE 8085

# Run the JAR
ENTRYPOINT ["java", "-jar", "/app/app.jar"]