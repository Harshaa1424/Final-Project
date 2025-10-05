# Build stage (for Node / static build). If you have no build step, you can use only the runtime stage.
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --production || true
COPY . .
# If your app needs a build step (uncomment):
# RUN npm run build

# Runtime stage: use a lightweight server (nginx)
FROM nginx:stable-alpine
# Remove default nginx html and copy app (adjust path if your build output is in dist/)
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/public /usr/share/nginx/html
# If using build output:
# COPY --from=build /app/dist /usr/share/nginx/html

# expose port 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

