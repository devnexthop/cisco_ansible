.PHONY: help install install-collections lint test clean

help:
	@echo "Cisco Ansible Automation - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  install            - Install Python dependencies"
	@echo "  install-collections - Install Ansible collections"
	@echo "  lint               - Run ansible-lint on playbooks"
	@echo "  test               - Run test playbooks"
	@echo "  clean              - Remove generated files (backups, reports)"
	@echo "  inventory-csv      - Generate switch inventory CSV report"

install:
	pip install -r requirements.txt

install-collections:
	ansible-galaxy collection install -r collections/requirements.yml

lint:
	ansible-lint playbooks/

test:
	ansible-playbook playbooks/testing/test_inventory.yml
	ansible-playbook playbooks/testing/test_ping.yml

clean:
	rm -rf backups/* reports/*

inventory-csv:
	ansible-playbook playbooks/switches/generate_inventory_csv.yml


