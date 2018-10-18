# common static env here
export HOME=~
export GOPATH=$HOME/gocode
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:/snap/bin:/usr/local/sbin:/usr/local/share/npm/bin:$GOPATH/bin:/usr/local/go/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH
export EDITOR=_vim
export PAGER="less -R"
export LANG=en_GB.UTF-8
export BC_ENV_ARGS="$HOME/.bcrc -l"
export GCC_COLORS=1
export FZF_DEFAULT_COMMAND="rg --smart-case --files --hidden --ignore-file=$HOME/.rgignore"
export FZF_CTRL_T_COMMAND="rg --smart-case --files --hidden --ignore-file=$HOME/.rgignore"

# Sometimes not set or fully qualified; simple name preferred.
export HOSTNAME=$(hostname -s)
export SYSTEM_COLOUR=$($HOME/.local/bin/system-colour $HOSTNAME)

if [[ $USER == root ]]; then
    PROMPT_COLOUR=160 # red
else
    PROMPT_COLOUR=$SYSTEM_COLOUR
fi
