
# Utility targets
check_root:
	test "${USER}" = "root"
	@echo executing playbook as root

# Installs playbook prerequisites, only needed once during the lifetime of a
# machine.
bootstrap: check_root
	ansible-playbook -i inventory.ini $@.yml

# The machines
node3: check_root
	ansible-playbook -i inventory.ini $@.yml
node4: check_root
	ansible-playbook -i inventory.ini $@.yml
personal-laptop:
	ansible-playbook -i inventory.ini --ask-sudo-pass $@.yml
work-laptop:
	ansible-playbook -i inventory.ini $@.yml
mayfirst:
	ansible-playbook -i inventory.ini --ask-pass $@.yml

.PHONY: check_root bootstrap node3 node4 personal-laptop work-laptop mayfirst
