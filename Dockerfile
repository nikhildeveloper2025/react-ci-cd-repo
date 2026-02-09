# Step 1: Use Node.js to build the app
FROM node:18-alpine AS build
WORKDIR /app

# Copy only package files first to leverage Docker's cache
COPY package*.json ./
RUN npm install

# Copy the rest of your code and build
COPY . .
RUN npm run build

# Step 2: Use Nginx to serve the build
FROM nginx:stable-alpine
# Copy the built files from the 'build' stage to Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]