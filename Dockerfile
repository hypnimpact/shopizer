# ---- build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy everything first so Maven sees all modules
COPY . .

# Make sure wrapper is executable and has LF line endings
RUN sed -i 's/\r$//' mvnw && chmod +x mvnw

# Critical: neutralize the MAVEN_CONFIG set by the Maven image
ENV MAVEN_CONFIG=

# Build only the shop module and its deps
RUN ./mvnw -q -DskipTests -pl sm-shop -am clean package

# ---- run stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/sm-shop/target/*.war /app/sm-shop.war
EXPOSE 8080
ENTRYPOINT ["java","-Xms256m","-Xmx512m","-jar","/app/sm-shop.war"]
