# correct so alias works cross platform
ln -sf /usr/local/bin/gpg /usr/local/bin/gpg2

chsh -s /usr/local/bin/bash $(whoami)
