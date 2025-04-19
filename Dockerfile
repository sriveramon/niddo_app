# Step 1: Use the official Flutter image with Dart SDK 3.x
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Step 2: Get dependencies and build the app
RUN flutter pub get
RUN flutter build web

# Step 3: Use Nginx to serve the web app
FROM nginx:alpine

# Copy the Flutter build output into Nginx's HTML directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 for serving
EXPOSE 80

# Step 4: Start the Nginx server
CMD ["nginx", "-g", "daemon off;"]
