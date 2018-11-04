source ~/.env.sh

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source ~/.functions.sh
source ~/.aliases
_init_agents

SAVEHIST=$HISTSIZE
unsetopt EXTENDED_HISTORY # just a list of commands so bash_history is compatible
setopt INC_APPEND_HISTORY # immediate sharing of history
# pass * if globbing fails (etc)
unsetopt NOMATCH
# auto rehash to discover execs in path
setopt nohashdirs
# with arrow keys
zstyle ':completion:*' menu select
setopt completealiases
setopt PROMPT_SUBST
autoload -U colors && colors
# note HISTORY_IGNORE is no longer defined -- see cleanup-history for the replacement mechanism

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

# case insensitive completion
# http://stackoverflow.com/questions/24226685/have-zsh-return-case-insensitive-auto-complete-matches-but-prefer-exact-matches
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
[ $TMUX ] && tmux set -g status-left-bg colour${SYSTEM_COLOUR} &>/dev/null

PROMPT="\$(__exit_warn)
%F{${PROMPT_COLOUR}}%n@%M:\$PWD%f \$(git_super_status)\$(__p4_ps1)%F{239} \$(date +%T)%f
$ "

# if you call a different shell, this does not happen automatically. WTF?
export SHELL=$(which zsh)

_auto_tmux_attach
_set_term_title

precmd() {
	# reload history to get immediate update because my computer is fast, yo.
	fc -R

    # reset the terminal, in case something (such as cat-ing a binary file or
    # failed SSH) sets a strange mode
    stty sane
    _set_term_title
    _update_agents
}

preexec() {
    # no need for another prompt before
    _tmux_update_env
}
#
# zsh uses zle, not readine so .inputrc is not used. Match bindings here:

# Launch FZF vim plugin outside of vim (with a tty)
bindkey -s '\C-p' "\C-k \C-u fzf --cycle --multi | tr '\\\n' '\\\0' | xargs -0 sh -c '\$0 \"\$@\" </dev/tty' $EDITOR\n"

# sudo-ize command
bindkey -s '\C-s' "\C-asudo \C-e"

# bind UP and DOWN arrow keys
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
# https://github.com/zsh-users/zsh-history-substring-search
# both methods are necessary
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

which dircolors &> /dev/null &&  eval $(dircolors ~/.dir_colors)

_disable_flow_control

source ~/.fzf/shell/completion.zsh
source ~/.fzf/shell/key-bindings.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
~/.local/bin/cleanup-history ~/.history
fc -R # reload history
trap "~/.local/bin/cleanup-history ~/.history" EXIT
