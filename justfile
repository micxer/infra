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

memoryalpha dry=default_dry: decrypt-ssh && encrypt-ssh
    echo {{ if dry == "dry" { "Doing a dry run..." } else { "Provisioning memoryalpha..." } }}
    @export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES && \
    ansible-playbook -b playbooks/run.yml --limit memoryalpha -vv {{ if dry == "dry" { " --check --diff" } else { "" } }}

docker-compose dry=default_dry: decrypt-ssh && encrypt-ssh
    echo {{ if dry == "dry" { "Doing a dry run for docker-compose..." } else { "Running docker-compose..." } }}
    ansible-playbook -b playbooks/run.yml --limit memoryalpha --tags docker_compose {{ if dry == "dry" { "--check --diff" } else { "" } }} -v

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
    ansible-vault encrypt memoryalpha.pem

decrypt:
    echo "Decrypting values..."
    ansible-vault decrypt memoryalpha.pem

encrypt:
    echo "Encrypting values..."
    ansible-vault encrypt memoryalpha.pem

githook:
    @scripts/pre-commit.sh
    echo "ansible vault pre-commit hook installed"
    echo "don't forget to create a .vault-password too"

update: decrypt && encrypt
    ansible-playbook -b playbooks/updates.yml --limit memoryalpha
