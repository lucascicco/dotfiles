export BUILD_DIR := ${HOME}/dotfiles/files/build

.PHYONY: lint
lint:
	yamllint .	

.PHYONY: bootstrap
bootstrap:
	bash ./run_bootstrap.sh

.PHYONY: install-nvim
install-nvim:
	$$BUILD_DIR/neovim.sh

.PHYONY: install-lvim
install-lvim:
	$$BUILD_DIR/lvim.sh

.PHYONY: force-nvim-upgrade
force-nvim-upgrade:
	$$BUILD_DIR/force_nvim_upgrade.sh
