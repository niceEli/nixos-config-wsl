{
  description = "niceeli's NixOS-WSL system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    compile-mode-nvim = {
      url = "github:ej-shafran/compile-mode.nvim";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    let
      mkHost =
        name:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/${name} ];
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      # system-level outputs (not per-arch)
      flake = {
        nixosConfigurations = {
          desktop = mkHost "desktop";
          laptop = mkHost "laptop";
        };
      };

      # per-arch outputs
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt
              nil
              lua-language-server
            ];
          };
        };
    };
}
