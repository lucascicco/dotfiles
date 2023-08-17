export BUILD_DIR := ${HOME}/dotfiles/scripts/build

.PHYONY: lint
lint:
	yamllint .

.PHYONY: bootstrap
bootstrap:
	bash ./bootstrap.sh
