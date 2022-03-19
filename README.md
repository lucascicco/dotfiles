# Dotfiles

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

`make lint`

but make sure you have yamllint installed.

And...enjoy the automatization!
