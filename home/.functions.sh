function _tmux_update_env {
    # tmux must be running
    [ $TMUX ] || return

    # update display to location
    eval $(tmux show-environment -s | grep 'DISPLAY=')

    # must be remote host (else it clobbers keychain, which runs local only)
    tmux show-environment | grep -q "SSH_CONNECTION=" || return

    # when an SSH connection is re-established, so is the agent connection.
    # Reload it automatically.
    eval $(tmux show-environment -s | grep 'SSH_AUTH_SOCK=')
}

# Prompt functions
# make sure the function exists, even if it wasn't included
# this is overridden later
function __git_ps1 {
	return
}

function __p4_ps1 {
	[ $P4CLIENT ] || return
	echo -n " ($P4CLIENT) "
}

function __exit_warn {
	# test status of last command without affecting it
	st=$?
	test $st -ne 0 \
		&& printf "\n\33[31mExited with status %s\33[m" $st
}

# get new or steal existing tmux
function tm {
	# must not already be inside tmux
	test ! $TMUX || return
	# detach any other clients
	# attach or make new if there isn't one
	tmux attach -d || tmux
}

function _auto_tmux_attach {
    # AUTOMATIC TMUX
    # must not launch tmux inside tmux (no memes please)
    # must be installed/single session/no clients
    test -z "$TMUX" \
        && which tmux &> /dev/null \
        && test $(tmux list-sessions 2> /dev/null | wc -l) -eq 1 \
        && test $(tmux list-clients 2> /dev/null | wc -l) -eq 0 \
        && tmux attach
}

function _set_term_title {
    # set window pane title if inside tmux
    # NOTE this used to apply to the primary pane only, but since git root use
    # used it could be simplified to any pane
    if [ $TMUX ]; then
        # shorthand representation of git dir or current dir
        dir="$(git rev-parse --show-toplevel 2>/dev/null)" || dir="$PWD"
        LABEL=$(echo $dir | sed s/[^a-zA-Z0-9\.\/]/-/g | grep -oE '[^\/]+$')
        tmux rename-window "$LABEL"
    fi

    # reset terminal title if this terminal is local
    if [ ! "$SSH_CONNECTION" ]; then
        printf "\033]0;%s\007" "$HOSTNAME"
    fi
}

function _disable_flow_control {
    # Ctrl+S can freeze the terminal, requiring
    # Ctrl+Q to restore. It can result in an apparent hung terminal, if
    # accidentally pressed.
    stty -ixon -ixoff
    # https://superuser.com/questions/385175/how-to-reclaim-s-in-zsh
    stty stop undef
    stty start undef
}

function _init_agents {
    # take over SSH keychain (with gpg-agent soon) but only on local machine, not remote ssh machine
    # keychain used in a non-invasive way where it's up to you to add your keys to the agent.
    if [ ! "$SSH_CONNECTION" ] && which keychain &>/dev/null; then
        #eval `keychain --gpg2 --ignore-missing --quiet --nogui --noask --eval --noinherit --agents ssh`
		export SSH_AUTH_SOCK=$(gpgconf --list-dirs | grep agent-ssh-socket | cut -f 2 -d :)
        gpg-connect-agent /bye
    fi
}

function _update_agents {
    # guaranteed to be current thanks to _tmux_update_env
    if [ ! "$SSH_CONNECTION" ]; then
        # ssh-agent protocol can't tell gpg-agent/pinentry what tty to use, so tell it
        # incidentally, this will start an agent if none is found
        echo UPDATESTARTUPTTY | gpg-connect-agent > /dev/null
    fi
}

# wrappers
function ssh {
    # last arg is probably host
    for host; do true; done

	if [ $TMUX ]; then
        tmux rename-window "$host"
    elif [ ! "$SSH_CONNECTION" ]; then
        # dedicated local terminal, set title of terminal
        printf "\033]0;%s\007" "$host"
    fi

    command ssh "$@"

    # _set_term_title will reset the title now.
}

# ssh with gpg and ssh agent forwarding Use only on trusted hosts.
function gssh {
    echo "Perparing host for forwarded GPG agent..." >&2

    # prepare remote for agent forwarding, get socket
    # Remove the socket in this pre-command as an alternative to requiring
    # StreamLocalBindUnlink to be set on the remote SSH server.
    # Find the path of the agent socket remotely to avoid manual configuration
    # client side. The location of the socket varies per version of GPG,
    # username, and host OS.
    remote_socket=$(cat <<'EOF' | command ssh -T "$@" bash
        set -e
        socket=$(gpgconf --list-dirs | grep agent-socket | cut -f 2 -d :)
        gpgconf --kill gpg-agent
        test -S $socket && rm $socket
        echo $socket
EOF
)
    if [ ! $? -eq 0 ]; then
        echo "Problem with remote GPG. use ssh -A $@ for ssh with agent forwarding only." >&2
        return
    fi

    if [ "$SSH_CONNECTION" ]; then
        # agent on this host is forwarded, allow chaining
        local_socket=$(gpgconf --list-dirs | grep agent-socket | cut -f 2 -d :)
    else
        # agent on this host is running locally, use special remote socket
        local_socket=$(gpgconf --list-dirs | grep agent-extra-socket | cut -f 2 -d :)
    fi

    if [ ! -S $local_socket ]; then
        echo "Could not find suitable local GPG agent socket" 2>&1
        return
    fi

    echo "Connecting..." >&2
    ssh -A -R $remote_socket:$local_socket "$@"
}

# this is a simple wrapper for scp to prevent local copying when a colon is forgotten
# It's annoying to create files named naggie@10.0.0.1
# use ~/.aliases to enable.
function scp {
    if [ $1 ] && ! echo "$@" | grep -q ':' &> /dev/null; then
        echo "No remote host specified. You forgot ':'"
        return 1
    fi

    command scp "$@"
}

# cd then ls
function cd {
	builtin cd "$@" && ls --color=auto
}

