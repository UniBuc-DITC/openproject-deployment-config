#!/bin/bash

set -e

user='root'
deployment_dir='/openproject'

# Read optional parameters
while :; do
    case $1 in
        --production) production=true
        ;;
        --configure-firewall) configure_firewall=true
        ;;
        -*|--*)
          echo "unknown option: '$1'"
          exit 1
        ;;
        *) break;
    esac
    shift
done

if [[ "$production" = true ]]
then
    hostname='mp.unibuc.ro'
else
    hostname='staging.mp.unibuc.ro'
fi

# If requested, configure firewall
if [[ "$configure_firewall" = true ]]
then
  ssh "root@$hostname" "\
    ufw allow ssh && \
    ufw allow http && \
    ufw allow https && \
    ufw allow 6556/tcp && \
    ufw allow 161/udp && \
    ufw allow out 587/tcp && \
    ufw allow out 465/tcp && \
    ufw allow out 465/udp && \
    ufw show added"

  read -p 'Is the firewall configuration OK? (y/N)' -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo 'Rules confirmed, enabling firewall'
    ssh "root@$hostname" 'ufw enable'
  fi

  exit
fi

echo "Deploying as $user to $hostname"

# Read the environment variables from an env file
if [[ "$production" = true ]]
then
    env_vars_filename='.env'
else
    env_vars_filename='.env.staging'
fi

echo 'Copying files'
rsync -v 'docker-compose.yml' $env_vars_filename "$user@$hostname:$deployment_dir"

echo 'Restarting the containers'
ssh "$user@$hostname" "cd $deployment_dir && \
  docker compose stop && \
  docker compose pull && \
  docker compose up -d"
