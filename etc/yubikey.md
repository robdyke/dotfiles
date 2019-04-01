Uses:


Multi-factor authentication
---------------------------

Nowadays, Yubikeys should just work as they support FIDO/U2F. Firefox
still needs u2f to be enabled in about:config.

SSH key storage
---------------

It's possible to use a Yubikey to hold an SSH key by using GPG-agent as
the SSH-agent and storing the key as a GPG key with authentication
capabilities. This makes your SSH ID more secure, and portable between
machines with some configuration.

Git commit signing
------------------

As the Yubikey can act as an OpenPGP card, it\'s possible to store
signing keys on the device that can be used to sign git commits. This
can even happen on a remote machine with GPG agent forwarding.

Encryption and signing
----------------------

GPG can be used for encrypting and signing things for transfer over
untrusted networks.

PAM / Windows Hello
-------------------

Yubikeys can be used to login to Ubuntu, Windows or Mac operating
systems.

PIV
---

It\'s possible to use a Yubikey to securely perform x.509 operations with
private keys hidden inside. This may be useful to create a secure Private CA,
make client authentication easier or for physical access control. May be
investigated later.

Payload bootstrapper
--------------------

A bit like a [USB rubber ducky,](https://www.hak5.org/gear/usb-rubber-ducky)
yubikeys can be used to deliver a payload. This is achieved by using the
"static password" feature of the yubikey -- with a payload instead of a
password. The payload has some limitations, though. The payload is limited to
38 characters, and may be implicated by differences between keyboard layouts.

I have my yubikey set up with the following payload:

```
wget -O.b https://<domain>/b;bash .b
```

Where `<domain>` is a website for my home network. The resultant URL serves a
redirect to the raw `1-bootstrap.sh` within this repository, such that a
long-press on my yubikey will provision any ubuntu/mac/raspbian based computer
with my dotfiles.

Note that I could have used a pipe to eliminate the temporary file, but the
pipe character has a different scan code across US/GB/Mac keyboard layouts
making the payload less reliable. All characters in the above payload have
consistent scancodes across all keyboards that I am likely to encounter.


Ansible vault decryption
------------------------

In combination with [pass](https://password-store.org), this script can allow a
yubikey to decrypt an ansible vault password on-the-fly:
https://github.com/naggie/dotfiles/blob/master/scripts/ansible-vault-pass


LUKS volume decryption 2FA
--------------------------

Yubikeys can be used with LUKS to enable unlocking of encrypted volumes,
including the boot volume for FDE. See
https://github.com/cornelinux/yubikey-luks and
https://wiki.archlinux.org/index.php/YubiKey#YubiKey_and_LUKS_encrypted_partition/disk


------------------------------------------------------------------------

Yubikey initialisation guide
============================

1. Disable OTP mode (unless you like injecting random OTP passwords into chat
   or the terminal all the time). `ykpersonalise` can do this, but can become
   locked out as it relies on OTP mode. To disable OTP mode: `ykman mode
   FIDO+CCID`
1. Set OpenPGP card user and admin PIN (6 and 8 digits respectively)
    1. `gpg2 --card-edit <email>`
    1. `admin`
    1. `passwd` -- change PIN and admin PIN as prompted
1. Move S, E, A keys to card (see next section)
1. Enable touch flags as appropriate
    1. `ykman openpgp touch enc on`
    1. `ykman openpgp touch aut on`
    1. `ykman openpgp touch sig on`


GPG Set up guide
================

There are many guides available on the internet but the process is
subject to a lot of caveats and confusing behaviour. Here's a guide
using some scripts I've made to make things reliable and secure:

0.  Boot a livecd session
1.  Make sure you\'ve got GPG2 installed. Note that Debian/Ubuntu may
    have GPG1 by default -- you will have to alias the **gpg2** binary
    to **gpg.**
2.  Generate your GPG PKI (gnupg2.2+) using
    <https://github.com/naggie/dotfiles/blob/master/scripts/gpg-keygen> on a
    livecd (for security). This should be run in an empty directory, and
    will create a new gnupg home along with exported public/private
    keys, fingerprint, key ID etc using your name and email from git.
    The topology is:
    1.  One master key (CS) (4096 bit RSA)
    2.  S subkey (4096 bit RSA)
    3.  E subkey (4096 bit RSA)
    4.  A subkey (4096 bit RSA)
3.  Backup all generated files in a secure location (USB drive in safe,
    preferably encrypted)
4.  Copy the contents of gnupghome to **\~/.gnupg/**
5.  Install a [hardened
    gpg.conf](https://github.com/naggie/dotfiles/blob/master/home/.gnupg/gpg.conf)
    that selects the strongest ciphers and long key IDs.
6.  Change the default Yubikey PIN and admin PIN using the above
    instructions.
7.  Use **gpg \--edit-key \<email\>**
    1.  **toggle**
    2.  For each key (S,E,A) select one by toggling the asterisk one at
        a time with the **key \<n\>** command (1,2,3 respectively)
    3.  When a key is selected, run **keytocard** to copy the key to the
        correct slot on the yuibkey (there are 3, one each for S,E,A)
    4.  `save` then exit. If you don't save, the private keys will persist
        locally which defeats the purpose of using the yubikey.
8.  Especially if you have a Nano-type yubikey, I recommend that you
    enable touch-to-sign, touch-to-encrypt, and touch-to-authenticate.
    You can do this with the official Yubikey **ykman** program as detailed
    above.

SSH
---

Your yubikey is now set up for encryption + signing on the local host.
To use it to authenticate with SSH, you can use the GPG key that was
generated for authentication. To do this you need to:

1.  Obtain your SSH compatible authentication public key with **gpg2
    \--export-ssh-key**
2.  As usual, copy it to the authorised keys file on the remote hosts
    you want to connect to
3.  Run GPG agent as your ssh agent. You can do this in your **.bashrc**
    as shown by **\_init\_agents** in
    <https://github.com/naggie/dotfiles/blob/master/home/.functions.sh#L82>
    . You\'ll also need to enable SSH agent support in your gpg.conf,
    [as I
    have.](https://github.com/naggie/dotfiles/blob/master/home/.gnupg/gpg.conf)
4.  If you use tmux, you may find **\_update\_agents** useful as an
    **onprompt** command to update stale bash shells automatically.

Your agent can then be forwarded with **ssh -A** as usual[. Note that
you must trust the remote host to do this; anyone with sudo access can
assume your SSH identity,]{style="color: rgb(255,0,0);"} which is why it
is recommended to enable touch-to-authenticate as above.

Note that GPG can ingest regular SSH keys into its own store with
**ssh-add**. However, these keys won\'t end up on the Yubikey.

Code signing
------------

To enable code signing with Git + Github:

1.  Upload the output of **gpg \--export \--armor \<email\>** (your GPG
    public keys) to <https://github.com/settings/keys> .
2.  Tell git which key to use: **git config \--global user.signingkey
    \<email\>**
3.  Tell git to sign always: **git config \--global commit.gpgsign
    true**

Remote code signing
-------------------

If you\'re developing on a remote machine, you\'re probably familair
with forwarding your SSH agent to allow the use of Git with local SSH
credentials. GPG is capable of a similar mechanism, allowing commits on
a remote machine to be signed using your local Yubikey. GPG uses a unix
socket for the agent connection, and a special restricted \"extra\"
socket for remote use. The [official
guide](https://wiki.gnupg.org/AgentForwarding) suggests 2 methods,
depending on wether your version of OpenSSH supports unix socket
forwarding or not. *Both methods are flawed:*

1.  The first method (recommended for OpenSSH older than 6.7) suggests using
    netcat to forward the unix socket over a TCP socket. This is insecure,
    because anyone else on the remote host could connect to the forwarded TCP
    port and use your forwarded agent...
2.  OpenSSH 6.7 and above can forward unix sockets, so the next recommendation
    is to do so natively. However, the location of the local and remote sockets
    is dependent on the version of GPG, your OS, and your username. As such,
    you would have to investigate for every remote host and add an entry for
    every remote host. It also requires server configuration to delete the
    stale socket automatically.

I recommend you use my [gssh
wrapper](https://github.com/naggie/dotfiles/blob/master/home/.functions.sh#L119)
which probes the remote host for the GPG socket location and kills any remote
GPG agent before connecting after deleting any stale socket.  Being separate
from the normal **ssh** command, it allow allows you to be mindful about when
you forward your agent -- forwarding your GPG agent carries similar risks to
forwarding your SSH agent -- an administrator on the remote host could use your
local GPG agent to further mitigate the risk, enable touch settings on your
yubikey as above.


----


See also: https://wiki.archlinux.org/index.php/YubiKey -- this is the best and
most complete Yubikey guide.
