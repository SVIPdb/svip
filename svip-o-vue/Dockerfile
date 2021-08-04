# install-deps: just installs node module dependencies
FROM node:12.18.2-stretch-slim as install-deps
WORKDIR /app

RUN apt-get update && apt-get install -y git

COPY package.json package-lock.json ./
RUN npm install
RUN npx browserslist@latest --update-db

# mask out the host's node_modules from being included in the container, even when bind-mounting
VOLUME /app/node_modules/

COPY . ./
