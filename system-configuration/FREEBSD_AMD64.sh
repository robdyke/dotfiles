cat <<-EOF | sudo tee /usr/local/etc/sudoers.d/wheel > /dev/null
    ## Allow members of group wheel to execute any command
    %wheel ALL=(ALL) ALL
EOF

# replace ssh config if password authentication is enabled (on by default)
if ! sudo grep -q '^PasswordAuthentication no' /etc/ssh/sshd_config; then
    sudo cp system-configuration/etc/sshd_config /etc/ssh/
    sudo service sshd restart
fi
