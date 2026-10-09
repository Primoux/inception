# User documentation

## What the stack provides

A WordPress website served over HTTPS, made of three services:

- **nginx**: the only public entry point (port 443, HTTPS).
- **wordpress**: the WordPress application (PHP-FPM).
- **mariadb**: the database storing the site content and accounts.

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
   127.0.0.1   <login>.42.fr
   ```
   `<login>` is the value of `LOGIN_ROOT` in `srcs/.env`.
2. Open `https://<login>.42.fr` in a browser.
3. The TLS certificate is self-signed: accept the browser warning once.
4. The administration panel is at `https://<login>.42.fr/wp-admin`.

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

- `make ps` shows `nginx`, `wordpress` and `mariadb` as running (`Up`).
- `make logs` shows no repeated errors. On a healthy start WordPress ends with `WordPress is ready.`.
- The site answers over HTTPS:
  ```sh
  curl -k --resolve <login>.42.fr:443:127.0.0.1 -I https://<login>.42.fr/
  ```
  The first line should be `HTTP/1.1 200 OK`.
- Plain HTTP (port 80) must not answer: only 443 is published.
- You can log in to `/wp-admin` with the administrator account.

## Troubleshooting

- **The browser cannot find the site**: check the `/etc/hosts` line.
- **Port 443 already in use**: stop the other service using it, then `make restart`.
- **WordPress keeps restarting**: read `make logs`. A common cause is two identical user names in `srcs/.env`, or a file left with `CHANGEME`.
- **Permission errors on `make clean`**: the data belongs to the container users, which is why cleaning is done through a container (`make clean` handles it).
