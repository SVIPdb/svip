# install-deps: just installs node module dependencies
FROM node:12.18.2-stretch-slim as install-deps
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

# mask out the host's node_modules from being included in the container, even when bind-mounting
VOLUME /app/node_modules/

COPY . ./

# create a symlink to /app in /svip-o-vue to mirror the host's paths
RUN ln -s /app /svip-o-vue
