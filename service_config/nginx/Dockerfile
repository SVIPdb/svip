FROM nginx:mainline

# Copy over the scripts
COPY reloader.sh /
COPY entrypoint.sh /

# Make the scripts executable
RUN chmod +x /reloader.sh /entrypoint.sh

# Copy over the nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Install the requirements
RUN apt-get update && apt-get install -y inotify-tools

# Clean up the apt cache
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["nginx", "-g", "daemon off;"]