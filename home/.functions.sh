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
		&& printf "\n\33[31mExited with status %s\33[m" $status
}

# get new or steal existing tmux
function tm {
	# must not already be inside tmux
	test ! $TMUX || return
	# detach any other clients
	# attach or make new if there isn't one
	tmux attach -d || tmux
}

# cd then ls
function cd {
	builtin cd "$@" && ls
}


function _tmux_update_env {
    # tmux must be running
    [ $TMUX ] || return

    # must be remote host (else it clobbers keychain, which runs local only)
    tmux show-environment -g | grep -q SSH_CONNECTION || return

    # when an SSH connection is re-established, so is the agent connection.
    # Reload it automatically.
    eval $(tmux show-environment -s | grep 'SSH_AUTH_SOCK\|DISPLAY')
    echo "Synced env"
}


# SSH wrapper to magically LOCK tmux title to hostname, if tmux is running
# prefer clear terminal after SSH, on success only
# now with MOAR agent forwarding
function ssh {
	if test $TMUX; then
		# find host from array (in a dumb way) by getting last argument
		# It uses the fact that for implicitly loops over the arguments
		# if you don't tell it what to loop over, and the fact that for
		# loop variables aren't scoped: they keep the last value they
		# were set to
		# http://stackoverflow.com/questions/1853946/getting-the-last-argument-passed-to-a-shell-script
		for host; do true; done

        old_window_name=$(tmux display-message -p '#W')

		printf "\\033k%s\\033\\\\" $host
		command ssh -A "$@"
		printf "\\033k%s\\033\\\\" $old_window_name

	else
		command ssh -A "$@"
	fi
}
