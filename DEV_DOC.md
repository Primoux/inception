# Developer documentation

## Prerequisites

- Linux (the project is meant to run in a VM), Docker with the Compose plugin, `make`.
- Your user must be allowed to use Docker (`docker` group). `make setup` can install the packages and add the user to the group, then restart your shell.

## Repository layout

```
.
├── Makefile                      # entry point: build, run, clean
├── tools/Makefile                # `make setup`: dependencies + copy templates
├── secrets/                      # *.exemple templates (real files are git-ignored)
└── srcs/
    ├── .env.exemple              # template of the non-sensitive settings
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/   (Dockerfile, conf/99-bind.cnf, tools/entrypoint.sh)
        ├── nginx/     (Dockerfile, conf/nginx.conf,  tools/entrypoint.sh)
        └── wordpress/ (Dockerfile, conf/www.conf,    tools/entrypoint.sh)
```

## Set up the environment from scratch

1. `make setup` installs the dependencies (optional, asks for confirmation) and copies each `*.exemple` file to its real name. Files that already exist are **kept**, never overwritten.
2. Replace every `CHANGEME` in:
   - `srcs/.env`: `MARIADB_DATABASE`, `LOGIN_ROOT`, `MARIADB_USER`, `WP_ADMIN`, `WP_USER`, the two e-mails. `DOMAIN_NAME` is derived from `LOGIN_ROOT` (`<LOGIN_ROOT>.42.fr`).
   - `secrets/.db_password`, `.db_root_password`, `.wp_password_admin`, `.wp_password_user`.
3. Add `127.0.0.1 <LOGIN_ROOT>.42.fr` to `/etc/hosts`.

Rules checked by the WordPress setup: `WP_ADMIN` must not contain `admin`/`administrator`, and `WP_ADMIN` and `WP_USER` must differ.

> Note: `.env.exemple` currently defines `MARIADB_USER` twice. With Compose, the last value wins, so `MARIADB_USER` ends up as `CHANGEME` and not as `${LOGIN_ROOT}`. Keep a single line in your `.env`.

## Build and launch

| Command                | Effect                                                              |
|------------------------|---------------------------------------------------------------------|
| `make all` / `make up` | create `~/data/{mariadb,wordpress}`, `docker compose up --build -d` |
| `make up-<service>`    | rebuild and start one service (`wordpress`, `nginx`, `mariadb`)     |
| `make down-<service>`  | stop and remove one service                                         |
| `make exec-<service>`  | open a `bash` shell in the container                                |
| `make logs` / `make ps`| follow logs / list containers                                       |
| `make re`              | `fclean` then `all`                                                 |

`make up-<service>` is the fast loop when you edit a Dockerfile or an entrypoint: only that service is rebuilt and recreated, and the data is kept.

## Cleaning

| Command       | Removes                                                                          |
|---------------|----------------------------------------------------------------------------------|
| `make clean`  | containers, volumes, and the content of `~/data/mariadb` and `~/data/wordpress`  |
| `make fclean` | same as `clean`, plus the images built by the project                            |
| `make purge`  | `fclean`, then **all** unused Docker data on the machine (`system prune -af --volumes`, `builder prune -af`) |

The data wipe runs `rm -rf` inside a throwaway `debian:bookworm` container because the files are owned by the container users (`mysql`, `www-data`), not by your user. `~/data` itself is kept.

## Where data lives and how it persists

| What                     | Container path     | Volume          | Host path                 |
|--------------------------|--------------------|-----------------|---------------------------|
| MariaDB database files   | `/var/lib/mysql`   | `mariadb_data`  | `/home/$USER/data/mariadb`   |
| WordPress files + uploads| `/var/www/html`    | `wp_data`       | `/home/$USER/data/wordpress` |

`wp_data` is shared by `wordpress` and `nginx` (nginx serves the static files and forwards `.php` to `wordpress:9000`).

Persistence means the entrypoints must be idempotent. They only act on what is missing, so a restart never reinstalls anything:

- **mariadb**: runs `mariadb-install-db` only if `/var/lib/mysql/mysql` does not exist. A temporary SQL file (mode 600) sets the root password, creates the database and the user, and is deleted as soon as the server answers.
- **wordpress**: downloads the core if `wp-load.php` is missing, waits for the database, creates `wp-config.php` and installs the site only if needed, and creates the second user if it does not exist.
- **nginx**: generates a self-signed certificate at every start and fills `${DOMAIN_NAME}` / `${LOGIN_ROOT}` in `nginx.conf` with `sed`.

## Secrets and configuration

Secrets are declared in `srcs/docker-compose.yml` and read by the entrypoints from `/run/secrets/<name>`:

| Secret              | Used by              |
|---------------------|----------------------|
| `db_password`       | mariadb, wordpress   |
| `db_root_password`  | mariadb              |
| `wp_password_admin` | wordpress            |
| `wp_password_user`  | wordpress            |

`srcs/.env` is loaded by all three services through `env_file`. Neither `.env` nor the secret files are versioned.

## Debugging

```sh
make logs                       # all services
docker logs wordpress           # one service
make exec-mariadb               # then: mariadb -uroot -p"$(cat /run/secrets/db_root_password)"
make exec-wordpress             # then: wp user list --allow-root --path=/var/www/html
```

Typical manual check after a change: `make clean && make all`, wait for `WordPress is ready.` in `docker logs wordpress`, then request the site with `curl -k` and log in to `/wp-admin`.
