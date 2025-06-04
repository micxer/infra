default:
    @just --list

help:
    @echo "memoryalpha justfile"
    @echo "--------------------"
    @echo "memoryalpha: provision memoryalpha"
    @echo "  Add dry to start a dry run of the playbook"
    @echo "reqs: install dependencies"
    @echo "forcereqs: force install dependencies"
    @echo "decrypt: decrypt vault"
    @echo "encrypt: encrypt vault"
    @echo "githook: install ansible vault pre-commit hook"
    @echo "updates: update packages on memoryalpha"
    @echo "docker-compose: create docker-compose file o memoryalpha"

default_dry := ''

memoryalpha dry=default_dry: decrypt-ssh
    #!/usr/bin/env sh
    set -e
    echo {{ if dry == "dry" { "Doing a dry run..." } else { "Provisioning memoryalpha..." } }}

    # Run ansible and save exit code
    ansible-playbook -b playbooks/run.yml --limit memoryalpha -vv {{ if dry == "dry" { " --check --diff" } else { "" } }} || ANSIBLE_EXIT_CODE=$?

    # Always encrypt regardless of previous command result
    just encrypt-ssh
    
    # If ansible failed, exit with its exit code
    if [ -n "$ANSIBLE_EXIT_CODE" ]; then
        exit $ANSIBLE_EXIT_CODE
    fi

docker-compose dry=default_dry: decrypt-ssh
    #!/usr/bin/env sh
    set -e
    echo {{ if dry == "dry" { "Doing a dry run for docker-compose..." } else { "Running docker-compose..." } }}
    
    # Run ansible and save exit code
    ansible-playbook -b playbooks/run.yml --limit memoryalpha --tags docker_compose {{ if dry == "dry" { "--check --diff" } else { "" } }} -v || ANSIBLE_EXIT_CODE=$?
    
    # Always encrypt regardless of previous command result
    just encrypt-ssh
    
    # If ansible failed, exit with its exit code
    if [ -n "$ANSIBLE_EXIT_CODE" ]; then
        exit $ANSIBLE_EXIT_CODE
    fi

reqs:
    echo "Installing dependencies..."
    ansible-galaxy install -r requirements.yml

forcereqs:
    ansible-galaxy install -r requirements.yml --force

decrypt-ssh:
    echo "Decrypting values..."
    ansible-vault decrypt memoryalpha.pem

encrypt-ssh:
    echo "Encrypting values..."
    git restore memoryalpha.pem

decrypt:
    echo "Decrypting values..."
    ansible-vault decrypt vars/vault.yml

encrypt:
    echo "Encrypting values..."
    ansible-vault encrypt vars/vault.yml

githook:
    @scripts/pre-commit.sh
    echo "ansible vault pre-commit hook installed"
    echo "don't forget to create a .vault-password too"

update: decrypt && encrypt
    ansible-playbook -b playbooks/updates.yml --limit memoryalpha
