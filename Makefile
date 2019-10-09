inventory = inventories/inventory
install_user = root

VENV_NAME?=venv
VENV_ACTIVATE=. $(VENV_NAME)/bin/activate
PYTHON=${VENV_NAME}/bin/python3

venv: $(VENV_NAME)/bin/activate
$(VENV_NAME)/bin/activate: env-requirements.txt
	test -d $(VENV_NAME) || virtualenv -p python3 $(VENV_NAME)
	${PYTHON} -m pip install -r env-requirements.txt
	touch $(VENV_NAME)/bin/activate

################################ GALAXY COMMANDS ################################

galaxy-install: venv
	$(VENV_ACTIVATE) && ansible-galaxy install -r roles/requirements.yml --roles-path=galaxy_roles

galaxy-force-update: venv
	$(VENV_ACTIVATE) && ansible-galaxy install -r roles/requirements.yml --roles-path=galaxy_roles --force-with-deps

############################## DEPLOYMENT COMMANDS ##############################

deploy-common: galaxy-install
	$(VENV_ACTIVATE) && ansible-playbook -i $(inventory) playbooks/common.yml

deploy-new-hosts: galaxy-install
	$(VENV_ACTIVATE) && ansible-playbook -i $(inventory) playbooks/common.yml --user=$(install_user)

deploy-new-users: galaxy-install
	$(VENV_ACTIVATE) && ansible-playbook -i $(inventory) playbooks/users.yml --user=$(install_user)

deploy-users: galaxy-install
	$(VENV_ACTIVATE) && ansible-playbook -i $(inventory) playbooks/users.yml

deploy-jumpbox: galaxy-install
	$(VENV_ACTIVATE) && ansible-playbook -i $(inventory) playbooks/jumpbox.yml

################################# TEST COMMANDS #################################

ping: venv
	$(VENV_ACTIVATE) && ansible-playbook -i $(inventory) playbooks/ping.yml

ping-new: venv
	$(VENV_ACTIVATE) && ansible-playbook -i $(inventory) playbooks/ping.yml --user=$(install_user)

test: galaxy-install
	$(VENV_ACTIVATE) && ansible-lint playbooks/*.yml --exclude=galaxy_roles
	$(VENV_ACTIVATE) && ansible-playbook playbooks/*.yml --check
