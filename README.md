*This project has been created as part of the 42 curriculum by enchevri.*

# Inception

## Description

Inception is a small web infrastructure built with Docker Compose inside a virtual machine. It serves a WordPress website over HTTPS using three mandatory services plus one bonus service, each running in its own container built from a custom Dockerfile (Debian bookworm, no pre-built service images):

| Service     | Role                                              | Exposed                    |
|-------------|---------------------------------------------------|----------------------------|
| `nginx`     | Reverse proxy and TLS termination (TLSv1.2/1.3)   | port **443** (only entry point) |
| `wordpress` | WordPress served by PHP-FPM 8.2, installed with WP-CLI | port 9000 (internal network) |
| `mariadb`   | Database for WordPress                            | port 3306 (internal network) |
| `uptime-kuma` (bonus) | Uptime monitoring dashboard, served by nginx on `status.<login>.42.fr` | port 3001 (internal network) |

The containers share a dedicated bridge network (`inception`). Persistent data lives in three named volumes bound to `/home/<user>/data/mariadb`, `/home/<user>/data/wordpress` and `/home/<user>/data/uptime-kuma` on the host. Passwords are provided as Docker secrets; non-sensitive settings come from `srcs/.env`.

```
 Browser ──443/TLS──► nginx ──9000 (FastCGI)──► wordpress ──3306──► mariadb
                        │ │                         │                   │
                        │ └──── wp_data volume ─────┘            mariadb_data volume
                        │
                        └──3001 (status.<login>.42.fr)──► uptime-kuma ── uptime_kuma_data volume
```

## Project description

### Use of Docker and sources included in the project

Docker is used to run each service in its own isolated, reproducible container, described by a Dockerfile and orchestrated by `docker compose`. All sources live in this repository:

- `Makefile`: builds and manages the whole stack (it calls `docker compose`).
- `srcs/docker-compose.yml`: services, network, volumes and secrets.
- `srcs/requirements/<service>/` (bonus services in `srcs/requirements/bonus/<service>/`): one Dockerfile per service, with its configuration (`conf/`) and its start-up script (`tools/entrypoint.sh`).
- `srcs/.env.exemple` and `secrets/*.exemple`: templates of the settings and passwords (the real files are git-ignored).
- `tools/Makefile`: helper used by `make setup`.

Every image is built from `debian:bookworm` (the penultimate stable Debian release); no ready-made service image is pulled.

### Design choices

**Virtual Machines vs Docker.** A VM virtualizes a whole machine, including its own kernel, so it is heavy and slow to start but strongly isolated. A Docker container shares the host kernel and only isolates processes and the filesystem: it starts in seconds and uses far fewer resources, at the cost of weaker isolation. Here the VM is the host environment, and Docker splits the application into small, reproducible services.

**Secrets vs Environment Variables.** Environment variables are convenient but are visible in `docker inspect` and are inherited by child processes. Docker secrets are mounted as files in `/run/secrets/` and only given to the services that need them. This project uses secrets for the four passwords (database user, database root, WordPress admin, WordPress user) and `.env` for everything non-sensitive (database name, user names, domain, e-mails).

**Docker Network vs Host Network.** With `network_mode: host` a container shares the host's network stack, with no isolation and a risk of port conflicts. Here a user-defined bridge network lets the containers reach each other by service name (`mariadb`, `wordpress`) while only nginx publishes a port to the host.

**Docker Volumes vs Bind Mounts.** A bind mount maps an arbitrary host path into a container, whereas a named volume is managed by Docker. This project uses named volumes with the `local` driver and `type: none, o: bind` options, so Docker manages them as volumes while the data is stored at a known place on the host (`/home/<user>/data`), as required by the subject.

## Instructions

Requirements: Linux with Docker and the Docker Compose plugin, and `make`.

```sh
make setup      # (once) install dependencies, create srcs/.env from the template and generate random secrets
```

The four passwords in `secrets/` are generated randomly (the WordPress administrator password is in `secrets/.wp_password_admin`). Edit `srcs/.env` and replace every `CHANGEME`:

- `WP_ADMIN` must not contain `admin` or `administrator`.
- `WP_ADMIN` and `WP_USER` must be two different names, with two different e-mails.

Add the domain to `/etc/hosts` (replace `<login>` with your `LOGIN_ROOT`):

```
127.0.0.1   <login>.42.fr status.<login>.42.fr
```

Build and start everything:

```sh
make            # shows the list of commands
make all        # creates the data directories, builds the images and starts the containers
```

The site is then available at `https://<login>.42.fr` (the certificate is self-signed, so the browser shows a warning). The administration area is at `https://<login>.42.fr/wp-admin`. The bonus monitoring dashboard (Uptime Kuma) is at `https://status.<login>.42.fr`.

Other useful commands: `make down`, `make stop`, `make start`, `make restart`, `make logs`, `make ps`, `make re`, `make clean` (removes containers, volumes **and data**), `make fclean` (also removes images). See `USER_DOC.md` and `DEV_DOC.md` for details.

## Resources

- Docker documentation: https://docs.docker.com/ (Dockerfile reference, Compose file reference, secrets, volumes, networking)
- NGINX documentation: https://nginx.org/en/docs/ (`ngx_http_ssl_module`, `ngx_http_fastcgi_module`)
- WordPress and WP-CLI: https://developer.wordpress.org/cli/commands/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- PHP-FPM configuration: https://www.php.net/manual/en/install.fpm.configuration.php

### Bonus: Uptime Kuma

Uptime Kuma is a self-hosted monitoring tool. It was chosen because it checks that the website stays reachable and shows its history, which fits a web infrastructure. It is built from `debian:bookworm` with Node.js 20 and a pinned release (`1.23.16`), has no published port, and is reached only through nginx. On the first visit, create the admin account in the web interface. To monitor the site, add an HTTP(s) monitor on `https://<login>.42.fr` and tick *Ignore TLS/SSL error* (self-signed certificate). nginx has the network aliases `<login>.42.fr` and `status.<login>.42.fr`, so the containers can resolve these names.

### Use of AI

Claude Code (Anthropic) was used as a coding assistant to review the project, clean up the WordPress and MariaDB entrypoint scripts, improve the Makefiles and draft this documentation. Every change was reviewed and tested by running the stack (full installation from empty data, container restarts, HTTPS check) before being kept.
