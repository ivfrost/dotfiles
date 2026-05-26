#!/bin/bash
# Additional layer of protection against loss of passwords in self-hosted vaultwarden
# Stores encrypted snapshots of the passwords at localhost

if [[ ! -v VW_BACKUP_ENC_PASS ]]; then
  echo "VW_BACKUP_ENC_PASS is not set. Exiting..."
  exit 1
fi

REMOTE_USER="admin"
REMOTE_HOST="vaultwarden"
REMOTE_VW_DIR="/opt/vaultwarden/data"
LOCAL_BACKUP_DIR="/home/ivfrost/.local/share/vaultwarden"
DATE=$(date +%Y-%m-%d_%H-%M)
TRANSFER_NAME="vw_backup_snap.tar.gz"

mkdir -p "$LOCAL_BACKUP_DIR"

echo "[$(date)] Starting remote backup..."

# 1. Remote Snapshot (Server Side)
ssh ${REMOTE_USER}@${REMOTE_HOST} << 'EOF'
  VW_DIR="/opt/vaultwarden/data"
  TMP_TAR="/tmp/vw_backup_snap.tar.gz"
  
  sudo /usr/bin/sqlite3 $VW_DIR/db.sqlite3 ".backup '/tmp/db_snap.sqlite3'"

  FILES_TO_BACKUP="/tmp/db_snap.sqlite3 $VW_DIR/rsa_key.pem"
  [ -d "$VW_DIR/attachments" ] && FILES_TO_BACKUP="$FILES_TO_BACKUP $VW_DIR/attachments"

  sudo /usr/bin/tar -czf $TMP_TAR $FILES_TO_BACKUP
  sudo /usr/bin/chown admin:admin $TMP_TAR
  sudo /usr/bin/rm /tmp/db_snap.sqlite3
EOF

# Transfer to Local
echo "Transferring file..."
scp ${REMOTE_USER}@${REMOTE_HOST}:/tmp/$TRANSFER_NAME "$LOCAL_BACKUP_DIR/tmp_backup.tar.gz"

# Local Encryption
if [ -f "$LOCAL_BACKUP_DIR/tmp_backup.tar.gz" ]; then
    echo "Encrypting locally..."
    gpg --batch --yes --passphrase "$VW_BACKUP_ENC_PASS" \
        --symmetric --cipher-algo AES256 \
        -o "$LOCAL_BACKUP_DIR/vw_backup_$DATE.tar.gz.gpg" \
        "$LOCAL_BACKUP_DIR/tmp_backup.tar.gz"

    # Cleanup unencrypted local and remote files
    rm "$LOCAL_BACKUP_DIR/tmp_backup.tar.gz"
    ssh ${REMOTE_USER}@${REMOTE_HOST} "rm /tmp/$TRANSFER_NAME"
    
    echo "[$(date)] Success! Encrypted backup: vw_backup_$DATE.tar.gz.gpg"
else
    echo "ERROR: File transfer failed."
    exit 1
fi
