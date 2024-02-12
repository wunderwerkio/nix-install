{pkgs, ...}: let
  flake-nix = import ../files/flake-nix.nix {
    inherit pkgs;
  };
  configuration-nix = import ../files/configuration-nix.nix {
    inherit pkgs;
  };
  system-configuration-nix = import ../files/system-configuration-nix.nix {
    inherit pkgs;
  };
in
  pkgs.writeShellScriptBin "install-hetzner" ''
    hostname="$1"
    disk="$2"
    ipv6="$3"

    nixos_version=$(nixos-version | grep -oE '^[0-9]+\.[0-9]+')

    usage() {
      scr=$(basename "$0")

      echo "Usage: $scr <hostname> <disk> <ipv6>"
      echo
      echo "Example:"
      echo "  $scr my-machine /dev/sda 0000:0000:0000:0000::/64"
      exit 1
    }

    # Validate inputs.
    if [ -z "''${1-}" ] || [ -z "''${2-}" ] || [ -z "''${3-}" ]; then
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

    umount -f /mnt/boot || true
    umount -f /mnt || true

    wipefs -af "$disk"

    sgdisk \
      --zap-all \
      --new=1:0:+500M --typecode=1:ef00 --change-name=1:"EFI System Partition" \
      --new=2:0:0 --typecode=2:8300 --change-name=2:"Linux Filesystem" \
      "$disk"

    echo "Creating filesystems"

    mkfs.fat /dev/sda1
    mkfs.ext4 /dev/sda2

    echo "Mouting filesystems"

    mount /dev/sda2 /mnt
    mkdir -p /mnt/boot
    mount /dev/sda1 /mnt/boot

    echo "Generating base nix config"
    nixos-generate-config --root /mnt

    sed -e "s|###HOST###|$hostname|g" ${flake-nix} > /mnt/etc/nixos/flake.nix
    sed -e "s|###HOST###|$hostname|g" -e "s|###IPV6###|$ipv6|g" ${system-configuration-nix} > /mnt/etc/nixos/system-configuration.nix
    sed -e "s|###NIXOS-VERSION###|$nixos_version|g" ${configuration-nix} > /mnt/etc/nixos/configuration.nix

    echo "Installing NixOS"
    nixos-install --flake "/mnt/etc/nixos#$hostname"

    echo ""
    echo "#"
    echo "#"
    echo "# NixOS Installed! Unmount the ISO and reboot :-)"
    echo "#"
    echo "#"
  ''
