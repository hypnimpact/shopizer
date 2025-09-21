# ---- build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN ./mvnw -q -DskipTests clean package

# ---- run stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY sm-shop/target/sm-shop.war /app/sm-shop.war
EXPOSE 8080
ENTRYPOINT ["java","-Xms256m","-Xmx512m","-jar","/app/sm-shop.war"]
