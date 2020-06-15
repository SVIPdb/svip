# install-deps: just installs node module dependencies
FROM node:8.11.0 as install-deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . ./
