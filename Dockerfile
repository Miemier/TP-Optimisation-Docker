#1.1
#FROM node:latest
#3.1
#FROM node:22-alpine
#FROM node:latest -> FROM node:22-alpine

#2
#---- builder (jetable) ----
FROM node:22-alpine AS builder
WORKDIR /app
#COPY node_modules ./node_modules
#COPY . /app
#RUN npm install
#Suppression de COPY node_modules + .dockerignore : les dépendances sont
#reconstruites DANS l'image (compatibilité garantie), package.json copié
#en premier pour profiter du cache des layers
COPY package*.json ./
#3.2
#RUN npm ci
RUN npm ci && npm cache clean --force
COPY . .
#3.3
RUN npm run build

# ---- runtime (image finale) ----
#3.4
FROM node:22-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Seul le nécessaire pour exécuter :

#4.1
#COPY --from=builder /app/server.js ./server.js
COPY --from=builder --chown=node:node /app/server.js ./server.js

#4.2
#USER root -> USER node (uid 1000, fourni par l'image officielle)
USER node



#1.2
#RUN apt-get update && apt-get install -y build-essential ca-certificates locales && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
#Suppression de RUN apt-get update && apt-get install -y build-essential

EXPOSE 3000 4000 5000
#3.5
#ENV NODE_ENV=development
#RUN npm run build
#USER root
CMD ["node", "server.js"]