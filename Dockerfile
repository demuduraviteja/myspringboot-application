# Use a distroless image as the base
FROM gcr.io/distroless/java17

# Set working directory
WORKDIR /app

# Define ARGs for build time
ARG NEXUS_URL="http://13.234.225.16:8081/repository/maven-snapshots"
ARG GROUP_ID="org.ravi.springboot"
ARG ARTIFACT_ID="my-springboot"
ARG VERSION="1.0.0"
ARG JAR_NAME="${ARTIFACT_ID}-${VERSION}.jar"

# Install curl to fetch JAR at runtime
RUN apt-get update && apt-get install -y curl

# Expose the application port
EXPOSE 8085

# Set environment variables for runtime
ENV SERVER_PORT=8085

# Download JAR at container runtime and run it
ENTRYPOINT ["/bin/sh", "-c", "curl -u $NEXUS_USERNAME:$NEXUS_PASSWORD -O $NEXUS_URL/${GROUP_ID//./\/}/$ARTIFACT_ID/$VERSION/$JAR_NAME && java -jar $JAR_NAME"]
