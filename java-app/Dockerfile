# Use a lightweight JRE
FROM openjdk:8-jdk-alpine

# Copy the built JAR into the image
COPY target/shopping-cart-0.0.1-SNAPSHOT.jar app.jar

# Set working directory
WORKDIR target

# Ensure the JAR is executable
# RUN chmod +x app.jar

EXPOSE 8070

# Launch the app
ENTRYPOINT ["java", "-jar", "app.jar"]
