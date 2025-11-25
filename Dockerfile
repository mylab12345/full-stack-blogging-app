# Stage 1: Build the JAR with Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /usr/src/app

# Copy source code
COPY . .

# Build the application (skip tests for faster builds if desired)
RUN mvn clean package -DskipTests

# Stage 2: Create the runtime image
FROM eclipse-temurin:17-jdk-alpine
ENV APP_HOME=/usr/src/app
WORKDIR $APP_HOME

# Copy the JAR from the build stage
COPY --from=build /usr/src/app/target/*.jar app.jar

# Run the application
ENTRYPOINT ["java","-jar","app.jar"]
