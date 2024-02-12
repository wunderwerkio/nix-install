{pkgs, ...}:
pkgs.writeShellScript "install" ''
  disk="$1"

  usage() {
    scr=$(basename "$0")

    echo "Usage: $scr <disk>"
    echo
    echo "Example:"
    echo "  $scr /dev/sda"
    exit 1
  }

  # Validate inputs.
  if [ -z "''${1-}" ]; then
    usage
  fi

  # Check if disk exists.
  lsblk "$disk" &>/dev/null
  if [ $? -ne 0 ]; then
    echo "The disk $disk does not exist!"
    exit 1
  fi

  echo "#"
  echo "# NixOS Install Script"
  echo "#"

  disklabel=$(lsblk -o MODEL "$disk" | awk 'NR==2')

  # Prompt user to destroy disk contents!
  echo ""
  echo "!!! Really destroy $disk? [yN]"
  read answer

  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Continue"
  else
    echo "Aborted"
    exit 2
  fi

  echo "Deleting existing partitions on $disk"

  sgdisk --zap-all "$disk"
  sgdisk --new=1:0:+500M --typecode=1:ef00 --change-name=1:"EFI System Partition" "$disk"
  sgdisk --new=2:0:0 --typecode=2:8300 --change-name=2:"Linux Filesystem" "$disk"

  echo "Creating filesystems"

  mkfs.fat /dev/sda1
  mkfs.ext4 /dev/sda2

  echo "Mouting filesystems"

  mount /dev/sda2 /mnt
  mkdir -p /mnt/boot
  mount /dev/sda1 /mnt/boot
''
