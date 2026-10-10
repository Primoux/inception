# User documentation

## What the stack provides

A WordPress website served over HTTPS, made of three services, plus a bonus monitoring service:

- **nginx**: the only public entry point (port 443, HTTPS).
- **wordpress**: the WordPress application (PHP-FPM).
- **mariadb**: the database storing the site content and accounts.
- **uptime-kuma** (bonus): a dashboard that monitors whether the website is up, reachable through nginx at `https://status.<login>.42.fr`.

A bonus service adds a second, independent website:

- **static-site**: a static website (a resume shown as an interactive terminal), reached through nginx at `/site/`.

## Start and stop

All commands are run from the root of the project.

| Action                              | Command        |
|-------------------------------------|----------------|
| First start (build + start)         | `make all`     |
| Stop the containers (keep them)     | `make stop`    |
| Start them again                    | `make start`   |
| Restart                             | `make restart` |
| Stop and remove the containers      | `make down`    |
| List the containers                 | `make ps`      |
| Follow the logs                     | `make logs`    |

`make down`, `make stop` and `make restart` keep your data. `make clean` and `make fclean` **delete the website and the database**.

## Access the website

1. Make sure your hosts file maps the domain to the machine, in `/etc/hosts`:
   ```
   127.0.0.1   <login>.42.fr status.<login>.42.fr
   ```
   `<login>` is the value of `LOGIN_ROOT` in `srcs/.env`.
2. Open `https://<login>.42.fr` in a browser.
3. The TLS certificate is self-signed: accept the browser warning once.
4. The administration panel is at `https://<login>.42.fr/wp-admin`.
5. The bonus static website is at `https://<login>.42.fr/site/`.

## Use the static website

The static website behaves like a terminal: type a command and press Enter.

| Command              | Effect                                                   |
|----------------------|----------------------------------------------------------|
| `help`               | list the commands                                        |
| `about`, `skills`    | presentation and technical skills                        |
| `projects`           | 42 projects, each name links to its GitHub repository    |
| `contact`            | contact links                                            |
| `ls`, `cat <file>`   | list the "files" and read one (`cat about`)              |
| `infra`              | animated diagram of the infrastructure                   |
| `explain <topic>`    | short explanation of a concept (`explain` lists the topics) |
| `docker ps`          | the containers of the stack (static text, not live)      |
| `neofetch`           | system information                                       |
| `theme`              | switch the colour (green, amber, cyan)                   |
| `clear` or Ctrl+L    | clear the screen                                         |

Tab completes a command and the up and down arrows browse the history. The site needs JavaScript enabled in the browser.

## Use Uptime Kuma (bonus)

1. Open `https://status.<login>.42.fr` (accept the certificate warning).
2. On the first visit, create the admin account (it is stored in the `uptime-kuma` volume, it is not in `secrets/`).
3. Click *Add New Monitor*: type `HTTP(s)`, URL `https://<login>.42.fr`, and tick **Ignore TLS/SSL error for HTTPS websites** (the certificate is self-signed). The monitor should turn *Up*.

## Credentials

Two WordPress accounts are created on the first start:

| Account       | Role          | Name (login)             | Password file                 |
|---------------|---------------|--------------------------|-------------------------------|
| Administrator | administrator | `WP_ADMIN` in `srcs/.env`  | `secrets/.wp_password_admin`  |
| Author        | author        | `WP_USER` in `srcs/.env`   | `secrets/.wp_password_user`   |

Database passwords (not needed to use the site) are in `secrets/.db_password` and `secrets/.db_root_password`.

These files are not versioned (they are listed in `.gitignore`). Keep them private.

> Changing a password file or `srcs/.env` after the first start does **not** change an existing WordPress or database. To start over with new values, run `make clean` then `make all` (this erases all data).

## Check that everything works

- `make ps` shows `nginx`, `wordpress`, `mariadb`, `static-site` and `uptime-kuma` as running (`Up`).
- `make logs` shows no repeated errors. On a healthy start WordPress ends with `WordPress is ready.`.
- The site answers over HTTPS:
  ```sh
  curl -k --resolve <login>.42.fr:443:127.0.0.1 -I https://<login>.42.fr/
  ```
  The first line should be `HTTP/1.1 200 OK`.
- The static website answers through nginx:
  ```sh
  curl -k --resolve <login>.42.fr:443:127.0.0.1 -I https://<login>.42.fr/site/
  ```
  The first line should be `HTTP/1.1 200 OK`.
- Plain HTTP (port 80) must not answer: only 443 is published. Port 8080 of the static website is not published either.
- You can log in to `/wp-admin` with the administrator account.

## Troubleshooting

- **The browser cannot find the site**: check the `/etc/hosts` line (it must contain `<login>.42.fr` and `status.<login>.42.fr`).
- **The Uptime Kuma monitor is *Down* with a certificate error**: tick *Ignore TLS/SSL error* in the monitor settings.
- **Port 443 already in use**: stop the other service using it, then `make restart`.
- **`/site/` answers `502 Bad Gateway`**: the `static-site` container is not running. Check `make ps`, then start it with `make up-static-site`.
- **The static website shows an old version**: its files are copied into the image at build time. Rebuild it with `make up-static-site`, then force-reload the page (Ctrl+Shift+R).
- **WordPress keeps restarting**: read `make logs`. A common cause is two identical user names in `srcs/.env`, or a `CHANGEME` left in `srcs/.env`. WordPress also refuses two accounts with the same e-mail.
- **Permission errors on `make clean`**: the data belongs to the container users, which is why cleaning is done through a container (`make clean` handles it).
