# OpenProject deployment configuration

## Description

This repository contains the configuration files for the University of Bucharest's
[OpenProject](https://www.openproject.org/) deployment, based on [Docker](https://www.docker.com/).

## Requirements

### Hardware

As a baseline, you can follow [the official Minimum Hardware Requirements](https://www.openproject.org/docs/installation-and-operations/system-requirements/#minimum-hardware-requirements) recommended by OpenProject.

Newer versions of [Ruby on Rails](https://rubyonrails.org/) are heavily optimized and [Puma](https://github.com/puma/puma) is doing an excellent job in using a machine's available parallelism.
Therefore, the minimum system requirements should be able to accomodate hundreds of users.

### Software

We recommend the latest LTS version of [Ubuntu Server](https://ubuntu.com/server) as the operating system.

We also recommend installing [fail2ban](https://www.fail2ban.org/wiki/index.php/Main_Page) or similar software to protect against SSH key guessing attacks.

## Configuring the environment variables file

Application secrets aren't kept in the `docker-compose.yml` file, but rather in an associated `.env` file.
The name of this file is `.env.staging` for the staging environment, and simply `.env` for the production environment.

The variables which need to be set in the env file are described below:

```env
POSTGRES_USER=openproject
POSTGRES_PASSWORD=<randomly generated secure password>
SERVER_HOSTNAME=<full domain name for your server>
SECRET_KEY_BASE=<secret key generated above>
LETSENCRYPT_EMAIL=<e-mail address where to send Let's Encrypt account messages>
```

In order to generate a strong and secure database password or secret key base, you can use [OpenSSL](https://www.openssl.org/):

```sh
openssl rand -base64 32
```

## Usage

To create a new deployment or update an existing one, you can use the `deploy.sh` script.

This script requires the following software to be installed in order to run:
- [Bash](https://www.gnu.org/software/bash/)
- [rsync](https://rsync.samba.org/)
- an SSH client (such as [OpenSSH](https://www.openssh.com/))

Simply run the `deploy.sh` script from this directory, making sure that the appropriate `.env` file exists as well.
You can pass the `--production` flag to deploy to production, otherwise the deployment is implicitly made to the staging environment.

The script also accepts a `--configure-firewall` flag, which configures and enables [UFW](https://help.ubuntu.com/community/UFW).
This flag is meant to be used only once, after the initial deployment.

## License

The configuration files are released under the permissive [MIT license](LICENSE.txt).
