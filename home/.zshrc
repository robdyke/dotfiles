# If not running interactively, don't do anything
[ -z "$PS1" ] && return

typeset -U path
path=(~/bin /usr/local/bin /usr/local/share/npm/bin $path)

# TERM TYPE Inside screen/tmux, it should be screen-256color -- this is
# configured in .tmux.conf.  Outside, it's up to you to make sure your terminal
# is configured to provide the correct, 256 color terminal type. For putty,
# it's putty-256color (which fixes a lot of things) and otherwise it's probably
# something like xterm-256color. Most, if not all off the terminals I use
# support 256 colors, so it's safe to force it as a last resort, but warn.
if [[ -z $TMUX ]] && test 0$(tput colors 2>/dev/null) -ne 256; then
	echo -e "\e[00;31m> TERM '$TERM' is not a 256 colour type! Overriding to xterm-256color. Please set. EG: Putty should have putty-256color.\e[00m"
	export TERM=xterm-256color
fi

HISTSIZE=9000
SAVEHIST=9000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY # just commands plskthx

# history search by suffix
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"    history-beginning-search-backward
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}"  history-beginning-search-forward

# with arrow keys
zstyle ':completion:*' menu select

setopt completealiases

# MOAR PROMPT
autoload -U promptinit
promptinit

# vim -X = don't look for X server, which can be slow
export EDITOR='vim -X'

# Completion
compinit


