# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export PATH=~/bin:/usr/local/bin:/usr/local/share/npm/bin:$PATH:~/local/bin

# fix annoying accidental commits and amends
# and other dangerous commands
export HISTIGNORE='git*--amend*:ls:cd:git*-m*:git*-am*:git*-f*:rm -rf*'
export HISTCONTROL=ignoredups:ignorespace
# vim -X = don't look for X server, which can be slow
export EDITOR='vim -X'

# sometimes TMUX can get confused about whether unicode is supported to draw
# lines or not. tmux may draw x and q instead, or default to - and | which is
# ascii. This also allows other programs to use nice UTF-8 symbols, such as
# NERDtree in vim. So very awesome.
export LANG=en_GB.utf8

# TERM TYPE Inside screen/tmux, it should be screen-256color -- this is
# configured in .tmux.conf.  Outside, it's up to you to make sure your terminal
# is configured to provide the correct, 256 color terminal type. For putty,
# it's putty-256color (which fixes a lot of things) and otherwise it's probably
# something ilike xterm-256color. Most, if not all off the terminals I use
# support 256 colors, so it's safe to force it as a last resort, but warn.
if [ -z $TMUX ] && test $(tput colors) -ne 256; then
	echo -e "\e[00;31m> TERM is not set to a 256 colour type! Overriding to xterm-256color. Please set. EG: Putty should have putty-256color.\e[00m"
	export TERM=xterm-256color
fi

# if you call a different shell, this does not happen automatically. WTF?
export SHELL=$(which bash)

# available since 4.8.0
export GCC_COLORS=1

# this bashrc takes a sec or so thanks to all the completions, so print this first
# Now this doesn't matter thanks to the deferred() system
echo -ne "\n\033[37m> Welcome to $(hostname -s), $USER.\033[0m "

# AUTOMATIC TMUX
# must not launch tmux inside tmux (no memes please)
# must be installed/single session/no clients
# term must be sufficiently wide
test -z "$TMUX" \
	&& which tmux &> /dev/null \
	&& test $(tmux list-sessions 2> /dev/null | wc -l) -eq 1 \
	&& test $(tmux list-clients 2> /dev/null | wc -l) -eq 0 \
	&& test $(tput cols) -gt 120 \
	&& tmux attach


# update the values of LINES and COLUMNS. Automatically
shopt -s checkwinsize

# stop -bash: !": event not found
set +o histexpand

# Useful title for ssh
printf "\033]0;%s\007" $HOSTNAME

# Update TMUX title with path
function prompt {
	# to a clever shorthand representation of the current dir
	LABEL=$(echo $PWD | sed s/[^a-zA-Z0-9\/]/-/g | grep -oE '[^\/]+$')

	# tmux title, padded
	# only run this if tmux is also running
	test -z "$TMUX" || echo -ne "\\033k$LABEL\\033\\\\"
}
PROMPT_COMMAND=prompt

# MOAR PROMPT
# with git branch
# make sure the function exists, even if it wasn't included
# this is overridden later
function __git_ps1 {
	exit
}

PS1="\n\[\e[0;32m\]\u@\h \[\e[1;34m\]\$PWD\[\e[0;33m\]\$(__git_ps1)\[\e[m\]\n\$ "

# aliases shared between fish and bash
source ~/.aliases

# bash specific aliases
alias tm='test -z $TMUX && (tmux a || tmux)'


# slow completion things in background after bashrc is executed
function deferred {
	# git completion (maybe other completion too)
	[ -f /etc/bash_completion ] && source /etc/bash_completion

	# OS X via homebrew git completion via package bash-completion
	[ -f /usr/local/etc/bash_completion ] && source /usr/local/etc/bash_completion

	# Homebrew completions
	test -x /usr/local/bin/brew && source `brew --prefix`/Library/Contributions/brew_bash_completion.sh

	# map completion for aliases
	complete -o default -o nospace -F _git g

	# hardcoded ssh completions (known_hosts is encrypted mostly)
	#complete -o default -W 'example.com example.net' ssh scp ping
}

PLATFORM=`uname`
if [[ $PLATFORM == 'Linux' ]]; then
	alias ls='ls --color=auto'
elif [[ $PLATFORM == 'Darwin' ]]; then
	#alias ls='ls -G'
	export CLICOLOR=1
	export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
fi

# cd then ls
function cd {
	builtin cd "$@" && ls
}

# cheap coloured man pages. Yay!
function man {
	env \
	LESS_TERMCAP_mb=$(printf "\e[1;31m") \
	LESS_TERMCAP_md=$(printf "\e[1;31m") \
	LESS_TERMCAP_me=$(printf "\e[0m") \
	LESS_TERMCAP_se=$(printf "\e[0m") \
	LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
	LESS_TERMCAP_ue=$(printf "\e[0m") \
	LESS_TERMCAP_us=$(printf "\e[1;32m") \
	man "$@"
}

# fix backspace on some terminals
stty erase ^?
#stty erase ^H

[ -x /usr/bin/keychain ] && [ -r ~/.ssh/id_rsa ] && eval `keychain --quiet --eval ~/.ssh/id_rsa`
test -x /usr/bin/dircolors && eval $(dircolors ~/.dir_colors)

# ls is the first thing I normally do when I log in. Let's hope it's not annoying
echo "Files in $PWD are:"
echo
# neat ls with fixed width
COLUMNS=80 ls

# Disable stupid flow control. Ctrl+S can disable the terminal, requiring
# Ctrl+Q to restore. It can result in an apparent hung terminal, if
# accidentally pressed.
stty -ixon -ixoff

# run the deferred function in the background in this context after bashrc
# http://superuser.com/questions/267771/bash-completion-makes-bash-start-slowly
trap 'deferred; trap USR1' USR1
{ sleep 0.1 ; builtin kill -USR1 $$ ; } & disown
