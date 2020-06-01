#!/bin/bash
cd $(dirname $0)
mkdir -p $HOME/.local/share/systemd/user

cp locklights.service $HOME/.local/share/systemd/user/
systemctl --user enable locklights.service
systemctl --user restart locklights.service

cp camlight.service $HOME/.local/share/systemd/user/
systemctl --user enable camlight.service
systemctl --user restart camlight.service
