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

memoryalpha dry=default_dry: decrypt && encrypt
    echo {{ if dry == "dry" { "Doing a dry run..." } else { "Provisioning memoryalpha..." } }}
    @export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES && \
    ansible-playbook -b playbooks/run.yml --limit memoryalpha -vv {{ if dry == "dry" { " --check" } else { "" } }}

docker-compose: decrypt && encrypt
    ansible-playbook -b playbooks/run.yml --limit memoryalpha --tags docker_compose $(if $(filter dry,$(MAKECMDGOALS)),--check) -v

reqs:
    echo "Installing dependencies..."
    ansible-galaxy install -r requirements.yml

forcereqs:
    ansible-galaxy install -r requirements.yml --force

decrypt:
    echo "Decrypting values..."
    ansible-vault decrypt vars/vault.yml memoryalpha.pem

encrypt:
    echo "Encrypting values..."
    ansible-vault encrypt vars/vault.yml memoryalpha.pem

githook:
    @scripts/pre-commit.sh
    echo "ansible vault pre-commit hook installed"
    echo "don't forget to create a .vault-password too"

update: decrypt && encrypt
    ansible-playbook -b playbooks/updates.yml --limit memoryalpha
