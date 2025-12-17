#!/bin/bash
## Unidirectional sync from local to remote machine

if [ $# -ne 1 ]; then
  echo "Usage: $0 user@host"
  exit 1
fi

# Check if the argument is in the correct format
if [[ $1 =~ ^[^@]+@[^@]+$ ]]; then
  echo "Checking availability of remote host: $1..."

  # Check if the remote host is reachable
  if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$1" exit > /dev/null 2>&1; then
    echo "Error: Unable to connect to $1."
    exit 1
  fi

  echo "Syncing GNOME keybindings with $1..."
  
  # Local temporary directory for GNOME configuration dumps
  LOCAL_TEMP_DIR=$(mktemp -d)

  # Sync the GNOME configurations to the local temporary directory
  dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "${LOCAL_TEMP_DIR}/dump_1"
  dconf dump /org/gnome/desktop/wm/keybindings/ > "${LOCAL_TEMP_DIR}/dump_2"
  dconf dump /org/gnome/shell/keybindings/ > "${LOCAL_TEMP_DIR}/dump_3"
  dconf dump /org/gnome/mutter/keybindings/ > "${LOCAL_TEMP_DIR}/dump_4"
  dconf dump /org/gnome/mutter/wayland/keybindings/ > "${LOCAL_TEMP_DIR}/dump_5"
  
  # Sync the dumps to the remote /tmp directory
  rsync -avz --progress "$LOCAL_TEMP_DIR/" "$1:/tmp/" > /dev/null 2>&1

  echo "Configuration files synced to /tmp on $1. Now restoring on the remote machine..."

  # Restore the configurations on the remote machine
  ssh "$1" << 'EOF'
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ < /tmp/dump_1
    dconf load /org/gnome/desktop/wm/keybindings/ < /tmp/dump_2
    dconf load /org/gnome/shell/keybindings/ < /tmp/dump_3
    dconf load /org/gnome/mutter/keybindings/ < /tmp/dump_4
    dconf load /org/gnome/mutter/wayland/keybindings/ < /tmp/dump_5

    # Optionally clean up dumped files after restoration
    rm /tmp/dump_*
EOF

  echo "Syncing GNOME extensions with $1..."
  ssh $1 "rm -rf ~/.local/share/gnome-shell/extensions/"
  scp -r ~/.local/share/gnome-shell/extensions/ $1:~/.local/share/gnome-shell/

  echo "Configuration synchronization completed on $1."

  # Clean up local temporary directory
  rm -rf "$LOCAL_TEMP_DIR"
else
  echo "Error: Argument must be in the format user@host."
  exit 1
fi

