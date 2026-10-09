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
        ├── wordpress/ (Dockerfile, conf/www.conf,    tools/entrypoint.sh)
        └── bonus/
            └── static-site/ (Dockerfile, conf/nginx.conf, site/)
```

## Set up the environment from scratch

1. `make setup` installs the dependencies (optional, asks for confirmation), then:
   - copies `srcs/.env.exemple` to `srcs/.env`;
   - **generates a random 24-character password** for each of the four files in `secrets/` (mode 600).
   Files that already exist are **kept**, never overwritten.
2. Replace every `CHANGEME` in `srcs/.env`: `MARIADB_DATABASE`, `LOGIN_ROOT`, `MARIADB_USER`, `WP_ADMIN`, `WP_USER` and the two e-mails (they must be different). `DOMAIN_NAME` is derived from `LOGIN_ROOT` (`<LOGIN_ROOT>.42.fr`). The secrets need no editing, but read `secrets/.wp_password_admin` to log in to `/wp-admin`.
3. Add `127.0.0.1 <LOGIN_ROOT>.42.fr` to `/etc/hosts`.

Rules for the WordPress accounts: `WP_ADMIN` must not contain `admin`/`administrator`, and `WP_ADMIN` / `WP_USER` and their e-mails must differ (WordPress rejects a duplicate e-mail).

## Build and launch

| Command                | Effect                                                              |
|------------------------|---------------------------------------------------------------------|
| `make all` / `make up` | create `~/data/{mariadb,wordpress}`, `docker compose up --build -d` |
| `make up-<service>`    | rebuild and start one service (`wordpress`, `nginx`, `mariadb`, `static-site`) |
| `make down-<service>`  | stop and remove one service                                         |
| `make exec-<service>`  | open a `bash` shell in the container (`wordpress`, `nginx`, `mariadb`) |
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

- **mariadb**: runs `mariadb-install-db` only if `/var/lib/mysql/mysql` does not exist. At every start, a one-shot `mariadbd --bootstrap` run applies the root password, the database and the user from a here-document (no file is written), then the real server starts.
- **wordpress**: downloads the core if `wp-load.php` is missing, creates `wp-config.php` and installs the site only if needed, and creates the second user if it does not exist.
- **start-up order**: no script waits in a loop. `docker-compose.yml` orders the services with healthchecks: `wordpress` starts once `mariadb` answers a ping (`service_healthy`), and `nginx` starts once WordPress is installed and PHP-FPM listens on 9000, and once `static-site` serves its home page (`service_healthy` for both).
- **nginx**: generates a self-signed certificate at every start and fills `${DOMAIN_NAME}` / `${LOGIN_ROOT}` in `nginx.conf` with `sed`.
- **static-site**: stateless, it has no entrypoint and no volume. Its healthcheck requests the home page with `curl` on port 8080.

## Secrets and configuration

Secrets are declared in `srcs/docker-compose.yml` and read by the entrypoints from `/run/secrets/<name>`:

| Secret              | Used by              |
|---------------------|----------------------|
| `db_password`       | mariadb, wordpress   |
| `db_root_password`  | mariadb              |
| `wp_password_admin` | wordpress            |
| `wp_password_user`  | wordpress            |

`srcs/.env` is loaded by the three mandatory services through `env_file` (`static-site` needs no setting and no secret). Neither `.env` nor the secret files are versioned.

## Bonus: static website

`static-site` is a separate image built from `debian:bookworm` with only `nginx` installed, plus `curl` for the healthcheck. It listens on port 8080 inside the `inception` network and publishes nothing on the host.

**Routing.** The main nginx forwards the `/site/` prefix to it, in `srcs/requirements/nginx/conf/nginx.conf`:

```nginx
location = /site {
    return 301 /site/;
}

location /site/ {
    proxy_pass http://static-site:8080/;
}
```

The trailing slash in `proxy_pass` strips the `/site/` prefix, so the container serves its files from its own root. The redirect from `/site` to `/site/` is needed because the pages load `style.css` and `script.js` with relative paths.

**Files** (in `srcs/requirements/bonus/static-site/site/`):

| File         | Content                                                              |
|--------------|----------------------------------------------------------------------|
| `index.html` | page skeleton: output area and command input                         |
| `style.css`  | terminal look, the three colour themes, diagram and game styles      |
| `script.js`  | all the behaviour: commands, completion, history, diagram, games     |
| `404.html`   | error page, returned by the container for any unknown path           |

There is no build step, no framework and no dependency: the browser runs the JavaScript, and the server only sends files. User input is always written with `textContent`, never interpreted as HTML.

**Editing the content.** The data sits at the top of `script.js`:

- `PROJECTS`: the repositories listed by `projects`, grouped by section. Each link is built as `GITHUB/<name>`, so the name must match the repository name exactly.
- `CONTACTS`: the links printed by `contact`.
- `EXPLAIN`: the texts of `explain <topic>`.

To add a command, add a function to the `commands` object. It is picked up by Tab completion automatically, unless its name is listed in `HIDDEN`.

**Applying a change.** The site is copied into the image (`COPY site/ /var/www/html/`), not mounted, so the image must be rebuilt:

```sh
make up-static-site
```

A change to the main `nginx.conf` needs `make up-nginx` instead.

**Things to know.**

- `404.html` loads `/site/style.css` with an absolute path, because an error page can be returned for any URL depth. If the `/site/` route is renamed, update that path too.
- `docker ps` in the terminal prints fixed text. A static site cannot query Docker.
- There is no `make exec-static-site`; use `docker exec -it static-site bash`.
- `docker logs static-site` and `make logs` show nothing for this service: nginx writes to `/var/log/nginx/access.log` and `error.log` inside the container.

## Debugging

```sh
make logs                       # all services
docker logs wordpress           # one service
docker exec static-site tail /var/log/nginx/access.log   # the bonus website
make exec-mariadb               # then: mariadb -uroot -p"$(cat /run/secrets/db_root_password)"
make exec-wordpress             # then: wp user list --allow-root --path=/var/www/html
```

Typical manual check after a change: `make clean && make all`, wait for `WordPress is ready.` in `docker logs wordpress`, then request the site with `curl -k` and log in to `/wp-admin`.
