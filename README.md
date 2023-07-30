# micxer/infra

This repo contains the code I use for deploying and managing my servers for my home media services, infrastructure
monitoring and a bunch of related stuff. Heavily based on https://github.com/ironicbadger/infra! Thanks for that!

## Basic setup

1. Install Ubuntu Server in the most minimal version
2. Setup a dedicated user for ansible: `useradd -G adm,sudo -m -N -s /bin/bash ansible`
3. Copy the public SSH key over to the new host
4. Enable passwordless sudo for the `ansible` user: `echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible`
