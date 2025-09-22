# ---- run stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the entire build output of sm-shop
COPY --from=build /app/sm-shop/target /app/target

EXPOSE 8080

# Pick one artifact: prefer WAR, else JAR (exclude sources/javadoc)
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
