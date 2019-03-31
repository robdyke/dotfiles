#!/bin/bash

# correct so alias works cross platform
ln -sf /usr/local/bin/gpg /usr/local/bin/gpg2

sudo chsh -s /usr/local/bin/bash $(whoami)

# TODO should be in user configuration
browserpass-setup firefox
