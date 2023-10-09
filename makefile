.PHONY: memoryalpha reqs forcereqs decrypt encrypt githook updates docker-compose help

help:
	@echo "memoryalpha makefile"
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

memoryalpha:
ifeq (dry, $(filter dry,$(MAKECMDGOALS)))
	@echo 'Doing a dry run...'
else
	@echo "Provisioning memoryalpha..."
endif
	@export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES && \
	ansible-playbook -b playbooks/run.yaml --limit memoryalpha $(if $(filter dry,$(MAKECMDGOALS)),--check)

docker-compose:
	ansible-playbook -b playbooks/run.yaml --limit memoryalpha --tags docker_compose $(if $(filter dry,$(MAKECMDGOALS)),--check) -v

reqs:
	@echo "Installing dependencies..."
	ansible-galaxy install -r requirements.yaml

forcereqs:
	ansible-galaxy install -r requirements.yaml --force

decrypt:
	@echo "Decrypting values..."
	ansible-vault decrypt vars/vault.yaml memoryalpha.pem

encrypt:
	@echo "Encrypting values..."
	ansible-vault encrypt vars/vault.yaml memoryalpha.pem

githook:
	@scripts/pre-commit.sh
	@echo "ansible vault pre-commit hook installed"
	@echo "don't forget to create a .vault-password too"

updates:
	ansible-playbook -b playbooks/updates.yaml --limit memoryalpha

%:
	@: