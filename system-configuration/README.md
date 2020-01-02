These scripts install platform specific dependencies only.

In general, they configure:

* Keyboard layouts in X/console/wayland etc
* OpenSSH server

These scripts are sourced automatically by `/provision.sh`.

Script working directory is the root of the repository.

Script should be idempotent.
