# Step 1: Use the official Flutter image
FROM dart:stable AS build

# Install Flutter dependencies and setup
RUN apt-get update && \
    apt-get install -y unzip xz-utils curl git && \
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 /flutter && \
    /flutter/bin/flutter config --enable-web && \
    /flutter/bin/flutter pub get && \
    /flutter/bin/flutter build web

# Step 2: Use Nginx to serve the web app
FROM nginx:alpine

# Copy the Flutter build output into Nginx's HTML directory
COPY --from=build /flutter/build/web /usr/share/nginx/html

# Expose port 80 for serving
EXPOSE 80

# Step 3: Start the Nginx server
CMD ["nginx", "-g", "daemon off;"]
