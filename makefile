.PHONY: memoryalpha reqs forcereqs decrypt encrypt githook

memoryalpha:
	ansible-playbook -b run.yaml --limit memoryalpha

reqs:
	ansible-galaxy install -r requirements.yaml

forcereqs:
	ansible-galaxy install -r requirements.yaml --force

decrypt:
	ansible-vault decrypt vars/vault.yaml memoryalpha.pem

encrypt:
	ansible-vault encrypt vars/vault.yaml memoryalpha.pem

githook:
	@scripts/pre-commit.sh
	@echo "ansible vault pre-commit hook installed"
	@echo "don't forget to create a .vault-password too"