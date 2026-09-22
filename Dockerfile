#1.1
#FROM node:latest
FROM node:22-alpine
#FROM node:latest -> FROM node:22-alpine

#2
WORKDIR /app
#COPY node_modules ./node_modules
#COPY . /app
#RUN npm install
#Suppression de COPY node_modules + .dockerignore : les dépendances sont
#reconstruites DANS l'image (compatibilité garantie), package.json copié
#en premier pour profiter du cache des layers
COPY package*.json ./
RUN npm ci
COPY . .

#1.2
#RUN apt-get update && apt-get install -y build-essential ca-certificates locales && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
#Suppression de RUN apt-get update && apt-get install -y build-essential

EXPOSE 3000 4000 5000
ENV NODE_ENV=development
RUN npm run build
USER root
CMD ["node", "server.js"]