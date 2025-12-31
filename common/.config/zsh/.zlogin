# Use keychain to keep ssh-agent information available in a file
/usr/bin/keychain "$HOME/.ssh/id_ed25519_fedora_ivfrost"
. "$HOME/.keychain/$HOST-sh"
