# Dockerized Quartz

[Quartz (v5)](https://github.com/jackyzha0/quartz) is a lightweight static site generator that helps you host your digital garden with minimal setup. This project provides an automated, Dockerized solution to build and serve Quartz sites effortlessly. Simply mount your Obsidian Vault as a Docker volume, and Quartz will handle the rest!

## Features

- 🚀 **Minimal Configuration**: Simply plug in your existing Obsidian Vault as a Docker bind volume.

- 🔄 **Automated Builds**: Rebuilds automatically after a set delay when notes in your Docker volume change.

- 🔗 **Webhook Trigger**: Trigger builds by sending a POST request to a secret URL.

- 📢 **Notifications**: Get notified on build start, success, or failure.

- 📦 **Default or Custom Quartz Repository**: If none present, container will clone [the Quartz repo](https://github.com/jackyzha0/quartz) on startup or you can provide your own customized Quartz.

- 🔒 **Support for Private Repositories**: Keep your Quartz config private.

- 🌐 **NGINX Web Server**: Served with NGINX, with basic configuration that can be extended.

## Quick Start

To quickly get started with Quartz in Docker create `docker-compose.yml` file:

1. **Edit compose file**:
    ```yaml
    version: '3.8'
    services:
        quartz:
            image: shommey/dockerized-quartz
            container_name: quartz-notes
            environment:
            # Use your custom Quartz repo or leave blank for the default Quartz repo
            # GIT_REPO: "https://github.com/yourusername/your-quartz-site.git"
            
            # Optional: specify a branch to checkout (the default repo already
            # defaults to the Quartz 5 branch, so this is usually unnecessary)
            # GIT_BRANCH: "v5"
            
            # Optional: Update delay after which quartz build will trigger, default 300 seconds
            BUILD_UPDATE_DELAY: 120

            # Optional: Auto rebuild Quartz after change in Obsidian Vault 
            AUTO_REBUILD: true
            volumes:
            # Mount your Obsidian vault for Quartz to read and build the site from
            # If not set it will mount docs
            # - /path/on/host:/vault:ro
            #
            # Optional: Mount existing Quartz repo
            # - /path/on/host:/usr/src/app/quartz
            #
            # Optional: Persist nginx logs if needed
            # - /path/to/nginx/logs:/var/log/nginx
            #
            # Optional: Mount nginx conf
            # - /path/on/host:/etc/nginx
            ports:
            # Map any port on the host to port 80 in the container for web access
            - "80:80"
            restart: unless-stopped
    ```
2. **Run it**: \
    `docker compose up -d` in the directory. \
    Access your Quartz site on `http://<YOUR_MACHINE_IP>:<PORT>`

For more detailed setups [see docs](docs/index.md).

### Documentation

1. [Overview](docs/overview.md)
2. [Providing Quartz](docs/providing-quartz.md)
3. [Importing Obsidian Vault](docs/importing-vault.md)
4. [Enabling Basic Auth](docs/basic-auth.md)
5. [Building From Source](docs/build-from-source.md)
6. [Trigger Rebuild With Webhook](docs/trigger-rebuild-with-webhook.md)
7. [Cron Job Trigger](docs/cron-job-trigger.md)
8. [Notifications Setup](docs/notifications.md)

---

### Attribution  

This project builds upon and integrates several open-source projects:  

- [**Quartz v5**](https://github.com/jackyzha0/quartz) – The core static site generator that powers this project.  
- [**Apprise**](https://github.com/caronc/apprise) – Handles notifications for build status updates.  
- [**NGINX**](https://www.nginx.com/) – Serves the generated Quartz site with a configurable web server.  

A huge thanks to the maintainers of these projects for their amazing work! 🚀
