#!/bin/bash

# automates moving Windows files to my arch LUKS cold storage directory.

# check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script requires root privileges. Run it with sudo."
  exit 1
fi

# check for source directory argument
if [ -z "$1" ]; then
  echo "Usage: sudo ./cold_storage.sh \"/mnt/c/path/to/game\""
  exit 1
fi

SOURCE_DIR="${1%/}" # Strips trailing slash if i accidentally added one
GAME_NAME=$(basename "$SOURCE_DIR")
DEST_BASE="/mnt/arch/@home/win_cold_storage/"
FINAL_DEST="$DEST_BASE$GAME_NAME/"
MAPPER_NAME="arch_hdd"
MOUNT_POINT="/mnt/arch"

# might get a bit wonky but basically looks for the LUKS partition
LUKS_PART=$(lsblk -o NAME,FSTYPE -l | awk '$2=="crypto_LUKS" {print "/dev/"$1}' | head -n 1)

if [ -z "$LUKS_PART" ]; then
  echo "Error: No LUKS partition detected."
  echo "Did you run 'wsl --mount \\\\.\\PHYSICALDRIVE0 --bare' in Windows PowerShell first?"
  exit 1
fi

echo ">> Found LUKS partition at $LUKS_PART."

# decrypt and mount
echo ">> Unlocking LUKS container..."
cryptsetup luksOpen "$LUKS_PART" "$MAPPER_NAME" || { echo "Fatal: Incorrect passphrase or decryption failed."; exit 1; }

echo ">> Mounting to $MOUNT_POINT..."
mkdir -p "$MOUNT_POINT"
mount /dev/mapper/"$MAPPER_NAME" "$MOUNT_POINT" || { echo "Fatal: Mount failed."; cryptsetup luksClose "$MAPPER_NAME"; exit 1; }

# execute transfer
echo ">> Target acquired. Creating destination: $FINAL_DEST"
mkdir -p "$FINAL_DEST"

echo ">> Initiating Rsync pipeline..."
rsync -avh --progress --remove-source-files "$SOURCE_DIR/" "$FINAL_DEST"

# rsync --remove-source-files deletes files but leaves empty directories behind. This clears the dead folders.
find "$SOURCE_DIR" -type d -empty -delete 2>/dev/null

# teardown
echo ">> Transfer complete. Executing secure teardown..."
umount "$MOUNT_POINT"
cryptsetup luksClose "$MAPPER_NAME"

echo ">> SUCCESS: Linux environment secured and locked."
echo ">> ACTION REQUIRED: Open PowerShell (Admin) and run:"
echo "   wsl --unmount \\\\.\\PHYSICALDRIVE0"
echo "   diskpart -> select disk 0 -> online disk"