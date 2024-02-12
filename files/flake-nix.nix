{pkgs}: pkgs.writeText "flake.nix" ''
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ...}@inputs: {
    nixosConfigurations = {
      "###HOST###" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
''
