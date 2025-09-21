# ---- build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy only files needed to resolve deps first (better cache)
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw
RUN ./mvnw -q -DskipTests dependency:go-offline

# Now copy the rest and build
COPY . .
RUN ./mvnw -q -DskipTests clean package

# ---- run stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# Use wildcard because the WAR is versioned (e.g., sm-shop-3.x.x.war)
COPY --from=build /app/sm-shop/target/*.war /app/sm-shop.war

EXPOSE 8080
ENTRYPOINT ["java","-Xms256m","-Xmx512m","-jar","/app/sm-shop.war"]
