{pkgs}: pkgs.writeText "configuration.nix" ''
{ inputs, config, lib, pkgs, ... }:
let
in {
  imports = [
    ./hardware-configuration.nix
    ./system-configuration.nix
  ];

  # Firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
  };

  # SSH.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Put your service config here:

  # NEVER change this value, even after upgrades!
  system.stateVersion = "###NIXOS-VERSION###";
}
''
