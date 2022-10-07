export BUILD_DIR := ${HOME}/dotfiles/tasks/files/build

.PHYONY: lint
lint:
	yamllint .	

.PHYONY: bootstrap
bootstrap:
	sudo apt-get install ansible -y
	chmod +x ./tasks/files/build/*.sh
	bash ./bootstrap.sh

.PHYONY: install-nvim
install-lvim:
	$$BUILD_DIR/neovim.sh

.PHYONY: install-lvim
install-lvim:
	$$BUILD_DIR/lvim.sh

.PHYONY: upgrade-lvim
upgrade-lvim:
	make install-nvim
	make install-lvim
