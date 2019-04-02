These scripts install platform specific dependencies only. They may may use of
`obtain` from `/etc/util.sh`.

These scripts are sourced automatically in a sudo context by `/provision.sh`.
To run them manually, first source `/etc/util.sh` before sourcing the
applicable script.
