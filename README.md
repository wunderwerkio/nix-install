# Nix Install

This nix flake provides a quick and easy way to install NixOS.
The system is installed using **Nix Flakes**.

Currently, only Hetzner is supported.

## Hetzner

This script partitions the specified drive as follows:

- 500MB EFI partition
- Remaining space as EXT4 system partition

A base system configuration is created:

- IPv4 DHCP
- IPv6 static (user-supplied) [See Docs](https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Cloud#Network_configuration)
- Enables SSH with Password Login (Change this!)
- Enables Firewall with ports 80, 443, 22 open by default
- Installs `vim`, `curl`, `git` and `htop`

### Usage

- Create a new VPS instance with any distro (either x86 or ARM64)
- In VPS settings under *ISO Images* mount the *NixOS* ISO.
- Start VPS and open console and wait for shell (may take some time with black sreen)
- Change to root user `sudo -i`
- Run script `nix --extra-experimental-features "nix-command flakes" run "github:wunderwerkio/nix-install#hetzner" <hostname> <disk> <ipv6>`
