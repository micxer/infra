.PHONY: memoryalpha reqs forcereqs decrypt encrypt githook updates

memoryalpha:
	@echo "Provisioning memoryalpha..."
	@export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES && \
	ansible-playbook -b playbooks/run.yaml --limit memoryalpha

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