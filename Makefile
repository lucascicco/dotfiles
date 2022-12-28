export BUILD_DIR := ${HOME}/dotfiles/files/build

.PHYONY: lint
lint:
	yamllint .	

.PHYONY: bootstrap-linux
bootstrap-linux:
	chmod +x ./files/build/*.sh
	sudo apt-get install ansible -y
	bash ./run_ansible.sh

.PHYONY: bootstrap-macos
bootstrap-macos:
	chmod +x ./files/build/*.sh
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install ansible
	bash ./run_ansible.sh

.PHYONY: install-nvim
install-nvim:
	$$BUILD_DIR/neovim.sh

.PHYONY: install-lvim
install-lvim:
	$$BUILD_DIR/lvim.sh

.PHYONY: force-nvim-upgrade
force-nvim-upgrade:
	$$BUILD_DIR/force_nvim_upgrade.sh
