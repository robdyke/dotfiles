#!/bin/bash
set -ex

# correct so alias works cross platform
ln -sf /usr/local/bin/gpg /usr/local/bin/gpg2

sudo chsh -s /usr/local/bin/bash $(whoami)
