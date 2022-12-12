FROM debian:bullseye

RUN mkdir -p /dotfiles
WORKDIR /dotfiles

COPY ./tasks tasks
COPY ./local.yml local.yml
COPY ./Makefile Makefile
COPY ./settings.sh settings.sh
COPY ./bootstrap.sh bootstrap.sh

RUN apt-get update && apt-get install -y \
  make \
  ansible \
  vim \
  sudo
