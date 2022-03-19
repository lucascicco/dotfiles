# Dotfiles

[![Ansible Logo](https://camo.githubusercontent.com/eb25100389f8134449aa0f429899bf9b386cfadd80c47fe176501a42db1fcc50/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f414e5349424c452d2532333141313931382e7376673f267374796c653d666c6174266c6f676f3d616e7369626c65266c6f676f436f6c6f723d7768697465)](https://www.ansible.com/)

This project use ansible to provision all the installation.

### Requirements

- ansible

### Installation

If you have cmake installed on your machine you can just run the following command to simplify your
life:

`$ make bootstrap`

Make sure to have ansible installed in your machine by running the following command:

`$ sudo apt update $ sudo apt install ansible -y`

Then to install the packages just run the "bootstrap" script:

`$ sh bootstrap.sh`

### Extras

To check lint issues on your yaml files, just run:

`$ make lint`

but make sure you have yamllint installed.

And...enjoy the automatization!
