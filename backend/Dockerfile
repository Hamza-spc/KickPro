# Stage 1: Build the Spring Boot JAR with Maven
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

COPY src src
RUN ./mvnw package -DskipTests -B

# Stage 2: Run the app with a smaller JRE image
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

# Tuned for ~4 GB Docker Desktop on an 8 GB Mac (see docker-compose.yml mem limits).
ENTRYPOINT ["java", "-Xms512m", "-Xmx1024m", "-XX:+UseG1GC", "-XX:MaxMetaspaceSize=256m", "-XX:+UseStringDeduplication", "-jar", "app.jar"]
