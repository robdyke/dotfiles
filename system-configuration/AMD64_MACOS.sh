#!/bin/bash
set -ex
source include/util.sh
assert_root()

# correct so alias works cross platform
ln -sf /usr/local/bin/gpg /usr/local/bin/gpg2

chsh -s /usr/local/bin/bash $(whoami)
