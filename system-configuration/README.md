These scripts install platform specific dependencies only. They may may use of
`obtain` from `/etc/util.sh`.

In general, they configure:

* Keyboard layouts in X/console/wayland etc
* OpenSSH server

These scripts are sourced automatically by `/provision.sh`.  To run them
manually, first source `/etc/util.sh` before sourcing the applicable script as
the current user. Sudo may be used inside scripts.

Script working directory is the root of the repository.

Script should be idempotent and not result in lost configuration.
