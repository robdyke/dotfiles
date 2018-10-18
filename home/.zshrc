source ~/.env.sh

# pass * if globbing fails (etc)
unsetopt NOMATCH

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source ~/.functions.sh

# only on new shell, fail silently. Must be non-invasive.
[ ! $TMUX ] && ~/bin/server-splash 2>/dev/null

HISTSIZE=1000
SAVEHIST=1000
# Change default as unconfigured bash could clobber history. Bash can run
# unconfigured if CTRL+C is hit during initialisation.
HISTFILE=~/.history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
unsetopt EXTENDED_HISTORY # just commands plskthx so bash_history is compatible
setopt INC_APPEND_HISTORY # immediate sharing of history

# fix annoying accidental commits and amends
# and other dangerous commands, yubikey OTP
export HISTORY_IGNORE='(git*--amend*|ls|cd|cccccc*|*reboot*|*halt*|0*|task*)'

# auto rehash to discover execs in path
setopt nohashdirs

# with arrow keys
zstyle ':completion:*' menu select

setopt completealiases

setopt PROMPT_SUBST
autoload -U colors && colors

# git
# git@github.com:olivierverdier/zsh-git-prompt.git
ZSH_THEME_GIT_PROMPT_CACHE=1
source ~/.zsh/zsh-git-prompt/zshrc.sh

# zsh will use vi bindings if you have vim as the editor. I want emacs.
# zsh does not use gnu readline, but zle
bindkey -e

# Completion
autoload -U compinit && compinit

# Syntax highlighting
#git@github.com:zsh-users/zsh-syntax-highlighting.git
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# history search by substring like fish and bash (with inputrc)
# git@github.com:zsh-users/zsh-history-substring-search.git
# must be loaded after syntax highlighting
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# bind UP and DOWN arrow keys
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
# https://github.com/zsh-users/zsh-history-substring-search
# both methods are necessary
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# case insensitive completion
# http://stackoverflow.com/questions/24226685/have-zsh-return-case-insensitive-auto-complete-matches-but-prefer-exact-matches
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
[ $TMUX ] && tmux set -g status-left-bg colour${SYSTEM_COLOUR} &>/dev/null


PROMPT="\$(__exit_warn)
%F{${PROMPT_COLOUR}}%n@%M:\$PWD%f \$(git_super_status)\$(__p4_ps1)%F{239} \$(date +%T)%f
$ "

# if you call a different shell, this does not happen automatically. WTF?
export SHELL=$(which zsh)

_auto_tmux

_set_term_title

# only auto set title based on initial pane
# this detects if the pane is the first in a new window
test $TMUX \
	&& test $(tmux list-panes | wc -l) -eq 1 \
	&& TMUX_PRIMARY_PANE=set

# Update TMUX title with path using hook
# Other hooks: http://zsh.sourceforge.net/Doc/Release/Functions.html
chpwd() {
	# only if TMUX is running, and it's safe to assume the user wants to have the tab automatically named
	if [ -n "$TMUX" ] && [ $TMUX_PRIMARY_PANE ]; then

		# to a clever shorthand representation of the current dir
		LABEL=$(echo $PWD | sed 's/[^a-zA-Z0-9\.\/]/-/g' | grep -oE '[^\/]+$')

        tmux rename-window "$LABEL"
	fi
}

precmd() {
	# reload history to get immediate update because my computer is fast, yo.
	fc -R

    # reset the terminal, in case something (such as cat-ing a binary file or
    # failed SSH) sets a strange mode
    stty sane
}

preexec() {
    # no need for another prompt before
    _tmux_update_env
}

source ~/.aliases

# zsh uses zle, not readine so .inputrc is not used. Match bindings here:

# Launch FZF vim plugin outside of vim (with a tty)
bindkey -s '\C-p' "\C-k \C-u fzf --multi | tr '\\\n' '\\\0' | xargs -0 sh -c '\$0 \"\$@\" </dev/tty' $EDITOR\n"

# sudo-ize command
bindkey -s '\C-s' "\C-asudo \C-e"

# take over SSH keychain (with gpg-agent soon) but only on local machine, not remote ssh machine
# keychain used in a non-invasive way where it's up to you to add your keys to the agent.
test -x $SSH_CONNECTION && \
    which keychain &>/dev/null && \
    eval `keychain --ignore-missing --nogui --noask --eval --noinherit --agents ssh`

which dircolors &> /dev/null &&  eval $(dircolors ~/.dir_colors)

_disable_flow_control

# fix gpg-agent ncurses passphrase prompt
# https://www.gnupg.org/documentation/manuals/gnupg/Common-Problems.html
export GPG_TTY=$(tty)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
trap "~/.local/bin/cleanup-history ~/.history" EXIT
