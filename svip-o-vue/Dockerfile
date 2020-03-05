# install-deps: just installs node module dependencies
FROM node:8.11.0 as install-deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . ./

# builds the app using preinstalled libraries
FROM install-deps as build-deps
RUN npm run build

# runs a hot-module reloading (hmr) dev server within the installed directory
FROM install-deps as hmr-debug
CMD ["npm", "run", "serve"]
