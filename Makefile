.PHYONY: lint
lint:
	yamllint .	

.PHYONY: bootstrap
bootstrap:
	sudo apt-get update
	sudo apt-get install ansible -y
	bash ./bootstrap.sh

