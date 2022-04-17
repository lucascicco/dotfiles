.PHYONY: lint
lint:
	yamllint .	

.PHYONY: bootstrap
bootstrap:
	sudo apt-get install ansible -y
	chmod +x ./tasks/files/build/*.sh
	bash ./bootstrap.sh
