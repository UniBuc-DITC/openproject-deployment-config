# OpenProject deployment configuration

## Description

This repository contains the configuration files for the University of Bucharest's
[OpenProject](https://www.openproject.org/) deployment, based on [Docker](https://www.docker.com/).

We recommend also checking out the official [guide for a Docker-based OpenProject install](https://www.openproject.org/docs/installation-and-operations/installation/docker/).

## Requirements

### Hardware

As a baseline, you can follow [the official Minimum Hardware Requirements](https://www.openproject.org/docs/installation-and-operations/system-requirements/#minimum-hardware-requirements) recommended by OpenProject.

Newer versions of [Ruby on Rails](https://rubyonrails.org/) are heavily optimized and [Puma](https://github.com/puma/puma) is doing an excellent job in using a machine's available parallelism.
Therefore, the minimum system requirements should be able to accomodate hundreds of users.

### Software

We recommend the latest LTS version of [Ubuntu Server](https://ubuntu.com/server) as the operating system.

Having a firewall enabled is essential for securing your server. On Ubuntu Server, you can use [UFW](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu).

You can use the following rules as a starting point:

```shell
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 6556/tcp
ufw allow 161/udp
ufw allow out 587/tcp
ufw allow out 465/tcp
ufw allow out 465/udp
ufw show added
```

(besides SSH, HTTP and HTTPS, we also allow a few ports for [`checkmk`](https://checkmk.com/) and [SNMP](https://en.wikipedia.org/wiki/Simple_Network_Management_Protocol), which we use at UB)

We also recommend installing [fail2ban](https://www.fail2ban.org/wiki/index.php/Main_Page) or similar software to protect against SSH key guessing attacks.

## Configuring the environment variables file

Application secrets and configurable parameters aren't kept in the `compose.yaml` file, but rather in an associated `.env` file.

The environment variables which **must** be set are:

```env
POSTGRES_USER=openproject
POSTGRES_PASSWORD=<randomly generated secure password>
SERVER_HOSTNAME=<full domain name for your server>
LETSENCRYPT_EMAIL=<e-mail address where Let's Encrypt will send account-related messages>
ENTRA_TENANT_ID=<tenant ID>
ENTRA_CLIENT_ID=<client ID for associated app registration>
ENTRA_CLIENT_SECRET=<client secret>
```

The `ENTRA_*` variables are required for enabling authentication using Microsoft Entra ID. They can be obtained by following the steps [in the official documentation](https://www.openproject.org/docs/system-admin-guide/authentication/openid-providers/#azure-active-directory).

The following ones are optional, with sensible defaults being used if missing:

```env
OPENPROJECT_HTTPS=<true or false, enable or disable HTTPS support>
OPENPROJECT_DISABLE__PASSWORD__LOGIN=<true or false, enable or disable password-based authentication>
```

If you're testing out the deployment locally, you will want to set `OPENPROJECT_HTTPS=false` to avoid errors due to missing TLS certificates and `OPENPROJECT_DISABLE__PASSWORD__LOGIN=false` to be able to log in with the default admin account (which is username `admin`, password `admin`).

## Usage

To create a new deployment or update an existing one, you have to:

- [Clone](https://git-scm.com/docs/git-clone) this repository onto the target machine.

- Create a `.env` file with the variables described above.

- Ensure you have the latest versions of all the container images by running `docker compose pull`.

- If this is the first time you're starting the app, you'll have to wait until the database is initialized and all the migrations are perfromed. You can do so as a separate step by running `docker compose up db seeder`.

  After the message `seeder-1 exited with code 0` is displayed, you can stop the containers by using `Ctrl` / `Cmd` + `C`.

- Start all the app services by running `docker compose up --detach`. After a short while, the app should be available on the HTTP/HTTPS ports associated with your app.

## License

The configuration files are released under the permissive [MIT license](LICENSE.txt).
