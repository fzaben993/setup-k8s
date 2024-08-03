include .env
export

SSH_OPTIONS := -i $(SSH_KEY_PATH) -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
IPS := $(shell yq e '.vms[].ip' $(VM_CONFIG_PATH))

define execute_command
	$(info )
	$(info #### Executing command on $(1))
	ssh $(SSH_OPTIONS) $(SSH_USER)@$(1) '$(2)'
	$(info #### Finished executing command on $(1))
endef

execute:
	$(foreach ip,$(IPS),$(call execute_command,$(ip),$(COMMAND)))

prep: ## Prepare the environment
	@$(MAKE) execute COMMAND="sudo yum install -y which"

reg: ## Register the system with subscription-manager
	@$(MAKE) execute COMMAND="sudo subscription-manager register --username=fzaben993 --password=Pass@123 --force"

update: ## Update the packages on the nodes using SSH
	@$(MAKE) execute COMMAND="sudo yum update -y"

reboot: ## Update the packages on the nodes using SSH
	@$(MAKE) execute COMMAND="sudo nohup reboot > /dev/null 2>&1 &"

INVENTORY = ansible/inventory.ini
PLAYBOOKS_PATH := ansible/playbooks
# .PHONY: all install lint debug role-install list-hosts update reg

# all: install

install:
# ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/1-register.yml
# ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/2-update.yml
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/3-firewall.yml
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/4-swap-off.yml
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/5-containerd.yml
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/6-sysctl.yml
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/7-containerd-runtime.yml
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/8-k8s.yml
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/9-master.yml
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/10-join.yml
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/11-master.yml
lint:
	@ansible-lint  $(PLAYBOOKS_PATH)/$(PLAYBOOK)

debug:
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_PATH)/$(PLAYBOOK) -vvv