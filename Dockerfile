# ---- build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy EVERYTHING first so Maven can see all child modules
COPY . .
# Make wrapper executable
RUN chmod +x mvnw
# Build (only shop module + dependencies)
RUN ./mvnw -q -DskipTests -pl sm-shop -am clean package

# ---- run stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app
# WAR name is versioned, so use wildcard
COPY --from=build /app/sm-shop/target/*.war /app/sm-shop.war
EXPOSE 8080
ENTRYPOINT ["java","-Xms256m","-Xmx512m","-jar","/app/sm-shop.war"]
