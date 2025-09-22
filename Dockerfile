# ---- build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy full repo so Maven sees all modules
COPY . .

# Build shop module and all its deps
RUN mvn -q -DskipTests -pl sm-shop -am clean package

# Sanity check: show what got produced (helps debug Render logs)
RUN ls -la sm-shop/target

# ---- run stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the entire target directory so we don't depend on exact filename
COPY --from=build /app/sm-shop/target /app/target

EXPOSE 8080

# Pick WAR if present, else JAR
ENTRYPOINT ["/bin/sh","-c","exec java -Xms256m -Xmx512m -jar \"$(ls /app/target/*.war 2>/dev/null || ls /app/target/*.jar 2>/dev/null)\""]
