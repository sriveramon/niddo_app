# Step 1: Use the official Flutter image with Dart SDK 3.x for building the app
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set the working directory in the container
WORKDIR /app

# Copy all project files into the container
COPY . .

# Get dependencies and build the web app
RUN flutter pub get
RUN flutter build web

# Step 2: Use Nginx to serve the built app
FROM nginx:alpine

# Copy the built Flutter web app into Nginx's HTML directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 for serving the app
EXPOSE 80

# Start the Nginx server
CMD ["nginx", "-g", "daemon off;"]
