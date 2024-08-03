include .env
export

# Read VM configurations from YAML file
VM_NAMES := $(shell yq e '.vms[].name' $(VM_CONFIG_PATH))
VM_IPS := $(shell yq e '.vms[].ip' $(VM_CONFIG_PATH))
COMMON_CONFIG := $(shell yq e '.common_config' $(VM_CONFIG_PATH))
JOIN_C01 := $(shell vagrant ssh cp-01 -c 'sudo kubeadm token create --print-join-command' | tr -d '\r\n')
NODES := $(shell yq e '.vms[].name' $(VM_CONFIG_PATH) | sed 's/$$/-body/')

print-vm-ips:
	@echo "VM_IPS: $(VM_IPS)"

# Help target
.PHONY: help \
        install-tools \
        install-crio \
        setup-kubeconfig \
        join-worker-nodes \
        setup-metrics-server \
        up \
        destroy \
        reload \
        all \
        list-vms \
        print-nodes-body
.DEFAULT_GOAL := help

# Print a help message with available targets
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Available targets:"
	@awk -F ':.*##' '/^[a-zA-Z_-]+:.*##/ { printf "\033[36m%-24s\033[0m%s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "SSH into VMs:"
	@for vm in $(VM_NAMES); do \
		printf "\033[36m%-24s\033[0m %s\n" "ssh-$${vm}:" "SSH into VM $${vm}"; \
	done
	@echo ""
# New hook-related definitions
NO_HOOKS := clean help node-01 node-02 cp-01
TARGETS := up destroy reload node-01 node-02 cp-01 update update-ssh install-crio setup-kubeconfig join-worker-nodes setup-metrics-server all ping list check-inventory play print-nodes generate-hosts

# Pattern rule to dynamically add pre/post hooks
define make-rule
$(1): pre-hook-$(1) $(1)-body post-hook-$(1)
endef

# Generate rules
$(foreach target,$(filter-out $(NO_HOOKS),$(TARGETS)), $(eval $(call make-rule,$(target))))
pre-hook-%:
	@echo "#### Start execute make $*"

post-hook-%:
	@echo "#### End of make $*"

print-nodes-body: ## Print the NODES variable
	@echo $(NODES)

update-ssh-body: ## Update the packages on the nodes using SSH
	@for ip in $(VM_IPS); do \
		echo "\n#### Updating packages on $$ip"; \
		ssh -i ~/.ssh/id_rsa \
			-o UserKnownHostsFile=/dev/null  \
			-o StrictHostKeyChecking=no vagrant@$$ip "bash -s" < $(VAGRANT_CWD)/init.sh username=$(username) password=$(password); \
		echo "\n#### Finished Updating packages on $$ip"; \
	done

# Docker
do: ## Build the Docker image
	docker run -it --rm -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host ubuntu:22.04 bash

zip: 
	find . -type d -name '.vagrant' -prune -o -print | zip archive_name.zip -@

# Setup kubeconfig
setup-kubeconfig-body: ## Set up the kubeconfig for kubectl
	vagrant ssh cp-01 -c "rsync -avz --delete /home/vagrant/.kube/config /vagrant/" && mv config ~/.kube/
	kubectl get po -n kube-system
	kubectl get --raw='/readyz?verbose'
	kubectl cluster-info


	kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml
	sleep 60
	kubectl top nodes

# Execute all commands sequentially
all-body: install-tools validate-vm-names
	@echo "Waiting for 60 seconds..."
	sleep 60
	install-crio
	@echo "Waiting for 60 seconds..."
	sleep 60
	setup-kubeconfig
	@echo "Waiting for 60 seconds..."
	sleep 60
	join-worker-nodes
	setup-metrics-server
	@echo "Makefile execution finished"


ping:
	- ansible linux -m ping

list:
	- ansible linux -a 'ls -la /home/do'

check-inventory:
	- ansible-inventory --list --yaml

play:
	- ansible-playbook playbooks/nginx.yml

%:  %-default
	- @  true

clean: destroy
	rm -rf .vagrant

generate-hosts-body:
	@echo "[k8s-cluster]" > $(ANSIBLE_PATH)/hosts
	@yq eval '.vms[] | .name + " ansible_host=" + .ip' $(VM_CONFIG_PATH) >> $(ANSIBLE_PATH)/hosts
	@echo "Generated hosts file."

ssh-%: ## SSH into the specified VM
	@vagrant ssh $*

# Validate VM_NAMES
list-vms: ## List the VMs defined in vm_config.yml
	@echo "VM Names: $(VM_NAMES)"

# Vagrant VMs
up-body: ## Start the Vagrant VMs
	@cd $(VAGRANT_CWD) && \
	vagrant up

destroy-body: ## Destroy the Vagrant VMs
	vagrant destroy -f

reload-body: ## Reload the Vagrant VMs
	vagrant halt

snapshot:
	@vagrant halt && \
		vagrant snapshot save cp-01 cp-01-snapshot && \
		vagrant snapshot save node-01 node-01-snapshot && \
		vagrant snapshot save node-02 node-02-snapshot && \
		vagrant up

$(NODES): ## Install kubeadm, kubelet, and kubectl on the nodes
	@vagrant ssh $(subst -body,,$@) -c "bash /tmp/init.sh '$(username)' '$(password)'"

update-body: $(NODES) ## Update the packages on the nodes
