#!/bin/bash

# RUN AS ROOT TO INSTALL TO /etc/skel/ so new users have these dotfiles
# or sudo -u <user> ./install.sh to install as any other user

# Else will install to home dir

cd $(dirname $0)

# quit on error
#set -e
CHANGE=$(git rev-list HEAD --count)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
VERSION=$BRANCH-$CHANGE
PLATFORM=$(uname)

cat <<EOF
### naggie/dotfiles, version $VERSION.

Dedpendencies:

  * tmux 1.8+
  * fish 2.0+ (recommended) or bash 3+
  * vim 7.3+
  * Dark 256color terminal with SGR1006 mouse support and UTF-8 character
    encoding for unicode character set

EOF

# this is good for log files
date
echo

function warning {
	# TODO: check PS1, no escape code if not interactive....?
	echo -e "\033[00;31m> $*\033[00m"
}

# sneaky hack to install to skel if run as root
if [ `whoami` == root ]; then
	HOME=/etc/skel
fi

# just the arguments (cryptic, I know. That's why you should use fish!)
PRESETS=$@

# make sure the submodules are fetched
echo 'Synchronising submodules...'
git submodule --quiet init || exit 1
git submodule --quiet update || exit 2

# Garbage collection
# remove remains of old submodules, scripts, etc
rm -rf home/.vim/bundle/powerline 2>/dev/null
rm -rf home/.vim/bundle/delimitmate 2>/dev/null
rm -rf home/.vim/bundle/ctrlp     2>/dev/null
rm -rf ~/.config/ipython 2>/dev/null
rm -f  ~/bin/server-splash.sh     2>/dev/null
rm -f  ~/git-completion.bash      2>/dev/null

echo 'Clobbering...'
test -d ~/.vim/ && rm -rf ~/.vim/
test -d ~/zsh/ && rm -rf ~/zsh/
# not for fish as it removes generated completions which have to rebuilt which is a pain
#test -d ~/.config/fish/ && rm -rf ~/.config/fish/

echo 'Copying dotfiles...'
#cp -r home/* ~ # non-dotfiles
# copy dotfiles separately , normal glob does not match
cp -r home/.??* ~ 2> /dev/null

if [ $PLATFORM == 'Darwin' ]; then
    echo 'Mac non-hidden...'
    cp -r home/Library ~
fi

echo "Copying ~/etc..."
cp -a etc ~

# TODO: perserve target executable permissions
echo 'Copying scripts...'
cp -a bin ~
chmod +x ~/bin/*

if [ ! 0$(tput colors 2>/dev/null) -eq 256 ]; then
	warning "TERM '$TERM' is not a 256 colour type! Please set in terminal emulator. EG: Putty should have putty-256color, xterm should have xterm-256color."
fi

# reload TMUX config if running inside tmux
if [ -n "$TMUX" ]; then
	echo 'Reloading tmux configuration...'
	tmux source-file ~/.tmux.conf >/dev/null
else
	warning "Not inside tmux, so can't tell tmux to reload"
fi

#if which fish &>/dev/null && fish -v 2>&1 | grep -q 'version 2'; then
#	test ! -d ~/.config/fish/generated_completions/ \
#		&& fish -c fish_update_completions
#fi

echo Installing/updating fonts...
./etc/powerline-patched/install.sh

if [ $PLATFORM == 'Darwin' ]; then
    echo 'Gah! Darwin!? XQuartz crashes in an annoying focus-stealing loop with this .xinirc. Removing...'
    rm ~/.xinitrc
elif [ -n "$DISPLAY" ] && which xrdb &>/dev/null; then
	echo 'Merging Xresources...'
	xrdb -merge ~/.Xresources
	# kind of forced to put this here. Ubuntu occasionally changes it for absolutely no reason.
	setxkbmap gb
else
	warning "X not configured. Now you can't enjoy the nice urxvt and xterm settings."
fi

# generate help files (well, tags) for the vim plugins
if which vim &>/dev/null; then
	echo 'Generating helptags for vim submodules...'
	# -e : ex mode, -s : silent batch mode, -n : no swap
	# must source vimrc in this mode.
	echo 'source ~/.vimrc | call pathogen#helptags()' | vim -es -n -s
else
	warning 'Vim not found! Is your brain functioning correctly?'
fi

echo $VERSION > ~/.naggie-dotfiles-version

# in case someone forgot...
if [ $BRANCH == 'master' ]; then
	warning "Generic version installed from master branch. Make your own branch for user/host-specific things."
elif [[ $BRANCH =~ "*$USER*" ]]; then
	warning "Branch does not contain user. Sure about this? The convention is to have a custom branch name containing your username."
fi



if [ -f ~/.bash_history ] && [ ! -f ~/.history ]; then
    echo "Migrating history file..."
    cp ~/.bash_history ~/.history
fi


tmux -V | grep -q 'tmux 2.' || warning "tmux 2.x not installed"
vim --version | grep -q 'Vi IMproved 7.4' || warning "vim 7.4 not installed"

# totally worth it
if which fish > /dev/null; then
    fish -c fish_update_completions
fi

