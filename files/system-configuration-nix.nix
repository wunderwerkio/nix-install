{pkgs}:
pkgs.writeText "system-configuration.nix" ''
  { lib, pkgs, ... }: {
    #
    # The system-specific configuration.
    # This file is safe to edit!
    #

    # Enable nix command and flakes.
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };

    # System packages.
    environment.systemPackages = with pkgs; [
      vim
      curl
      git
      htop
    ];

    # Set console keymap.
    console.keyMap = "de";

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Hostname.
    networking.hostName = "###HOST###";

    # Set your time zone.
    time.timeZone = "Europe/Vienna";

    # Enable QEMU Guest Agent.
    services.qemuGuest.enable = true;
    # Make sure setting a password actually works.
    # https://discourse.nixos.org/t/qemu-guest-agent-on-hetzner-cloud-doesnt-work/8864/2
    systemd.services.qemu-guest-agent.path = [ pkgs.shadow ];

    # Networking.
    systemd.network = {
      enable = true;

      networks."10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig.DHCP = "ipv4";
        address = [
          "###IPV6###"
        ];
        routes = [
          { routeConfig.Gateway = "fe80::1"; }
        ];
      };
    };

    networking.useNetworkd = false;
    networking.useDHCP = false;
  }
''
