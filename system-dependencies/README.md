These scripts perform platform specific configuration only. They may may use of
`obtain` from `/etc/util.sh`.

In general they install:

* vim/neovim
* tmux
* dstask
* fzf
* ripgrep
* Programming languages
* A desktop environment, Firefox, Alacritty etc (some non-server distros only)


These scripts are sourced automatically by `/provision.sh`.

Script working directory is the root of the repository.

Script should be idempotent.
