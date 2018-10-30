source ~/.env.sh

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source ~/.functions.sh
source ~/.aliases
_tmux_update_env
_setup_ssh_agent

# note HISTIGNORE is no longer defined -- see cleanup-history for the replacement mechanism
export HISTCONTROL=ignoredups:ignorespace:erasedups
# if you call a different shell, this does not happen automatically. WTF?
export SHELL=$(which bash)

[ $TMUX ] && tmux set -g status-left-bg colour${SYSTEM_COLOUR} &>/dev/null

_auto_tmux_attach

# update the values of LINES and COLUMNS. Automatically
shopt -s checkwinsize

# stop -bash: !": event not found
set +o histexpand

HISTFILESIZE=$HISTSIZE

_bash_history_sync() {
    # append last command to history file without messing up history counter in file
    builtin history | tail -n 1 | cut -c 8- >> $HISTFILE
    # clear history
	builtin history -c
    # reload history
	builtin history -r
}

_set_term_title

# Update TMUX title with path
function onprompt {
    # reset the terminal, in case something (such as cat-ing a binary file or
    # failed SSH) sets a strange mode
    stty sane

    _set_term_title
	_bash_history_sync
    _tmux_update_env

    # ssh-agent protocol can't tell gpg-agent/pinentry what tty to use, so tell it
    echo UPDATESTARTUPTTY | gpg-connect-agent
}

PROMPT_COMMAND=onprompt

PS1="\$(__exit_warn)\n\[\e[38;5;${PROMPT_COLOUR}m\]\u@\H:\$PWD\[\e[90m\]\$(__git_ps1)\$(__p4_ps1) \$(date +%T)\[\e[0m\]\n\$ "

# slow completion things in background after bashrc is executed
function _deferred {
	# linux / homebrew completions (package: bash-completion)
	[ -f /etc/bash_completion ] && source /etc/bash_completion
    [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

	# latest git completion and PS1
	source ~/.git-completion.sh
	source ~/.git-prompt.sh
    # fish/zsh already have this
    which task > /dev/null && source ~/.task-completions.sh

	# map completion for aliases that need them
	complete -o default -o nospace -F _git g
	complete -o default -o nospace -F _git_diff d
	complete -o default -o nospace -F _git_log l
	complete -o default -o nospace -F _git_status s
	complete -o default -o nospace -F _task n

	# hardcoded ssh completions (known_hosts is encrypted mostly)
	#complete -o default -W 'example.com example.net' ssh scp ping
}

# fix backspace on some terminals
stty erase ^?
#stty erase ^H


which dircolors &>/dev/null &&  eval $(dircolors ~/.dir_colors)

_disable_flow_control

# fix gpg-agent ncurses passphrase prompt
# https://www.gnupg.org/documentation/manuals/gnupg/Common-Problems.html
export GPG_TTY=$(tty)

source ~/.fzf/shell/completion.bash
source ~/.fzf/shell/key-bindings.bash

# run the deferred function in the background in this context after bashrc
# http://superuser.com/questions/267771/bash-completion-makes-bash-start-slowly
trap '_deferred 2>/dev/null; trap USR1' USR1
{ sleep 0.1 ; builtin kill -USR1 $$ ; } & disown

# clear history
~/.local/bin/cleanup-history ~/.history
# clear history
builtin history -c
# reload history
builtin history -r

trap "~/.local/bin/cleanup-history ~/.history" EXIT
