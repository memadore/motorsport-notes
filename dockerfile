FROM node:20 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY sources ./sources
COPY pages ./pages
COPY evidence.plugins.yaml ./
RUN npm run sources && \
    npm run build

FROM nginx:alpine AS final

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
