# Use Amazon Linux 2 as the base image for build
FROM amazonlinux:2 AS build

# Set working directory
WORKDIR /app

# Define ARGs for build time
ARG NEXUS_URL="http://13.234.225.16:8081/repository/maven-snapshots"
ARG GROUP_ID="org.ravi.springboot"
ARG ARTIFACT_ID="my-springboot"
ARG VERSION="1.0.0"
ARG JAR_NAME="${ARTIFACT_ID}-${VERSION}.jar"

# Install Java and curl using yum
RUN yum update -y && \
    yum install -y java-17-amazon-corretto curl

# Download JAR at build time
RUN curl -u $NEXUS_USERNAME:$NEXUS_PASSWORD -O $NEXUS_URL/${GROUP_ID//./\/}/$ARTIFACT_ID/$VERSION/$JAR_NAME

# Use Amazon Linux for final runtime
FROM amazonlinux:2

WORKDIR /app

# Install Java runtime only (no curl needed in the final image)
RUN yum install -y java-17-amazon-corretto && yum clean all

# Copy the JAR from the build stage
COPY --from=build /app/${ARTIFACT_ID}-${VERSION}.jar /app/app.jar

# Expose the application port
EXPOSE 8085
# Run the JAR file
ENTRYPOINT ["java", "-jar", "/app/app.jar"]