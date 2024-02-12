{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    systems = [
      # Linux machines
      "x86_64-linux"
      "aarch64-linux"
      # MacOS machines
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forEachSystem = nixpkgs.lib.genAttrs systems;
  in {
    packages = forEachSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in rec {
        hetzner = import ./scripts/hetzner.nix {
          inherit pkgs;
        };
      }
    );

    formatter = forEachSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
        pkgs.alejandra
    );
  };
}
