# Use a lightweight JRE
FROM eclipse-temurin:8-jre-alpine

# Copy the built JAR into the image
COPY target/shopping-cart-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8070

# Launch the app
ENTRYPOINT ["java", "-jar", "/app.jar"]
