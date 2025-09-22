# ---- build stage ----
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy the full repo so Maven can see all modules
COPY . .

# Build the shop module and its dependencies
RUN mvn -q -DskipTests -pl sm-shop -am clean package

# Optional: list artifacts to confirm output in build logs
RUN ls -la sm-shop/target

# ---- run stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy artifacts from the *named* build stage (builder)
COPY --from=builder /app/sm-shop/target /app/target

EXPOSE 8080

# Prefer WAR, else pick a non-sources/non-javadoc JAR
ENTRYPOINT ["/bin/sh","-c", "\
set -e; \
ARTIFACT=$(ls -1 /app/target/*.war 2>/dev/null | head -n1); \
if [ -z \"$ARTIFACT\" ]; then \
  ARTIFACT=$(ls -1 /app/target/*.jar 2>/dev/null | grep -v -E '(sources|javadoc|tests)' | head -n1); \
fi; \
if [ -z \"$ARTIFACT\" ]; then \
  echo 'No runnable artifact found in /app/target'; \
  ls -la /app/target; \
  exit 1; \
fi; \
echo \"Starting: $ARTIFACT\"; \
exec java -Xms256m -Xmx512m -jar \"$ARTIFACT\" \
"]
