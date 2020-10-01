cat <<-EOF | sudo tee /usr/local/etc/sudoers.d/wheel
    ## Allow members of group wheel to execute any command
    %wheel ALL=(ALL) ALL
EOF

echo FARGLEBUS
