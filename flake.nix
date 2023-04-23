{
  description = "Rocketpool Smartnode Flake";

  inputs = {
    gomod2nix = {
      url = "github:tweag/gomod2nix";
      #inputs.nixpkgs.follows = "nixpkgs";
      #inputs.utils.follows = "utils";
    };
  };

  outputs = { self, nixpkgs, gomod2nix }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [gomod2nix.overlays.default];
      };
      rocketpool = pkgs.callPackage ./rocketpool.nix { };
      # module = { ... }: {
      #   imports = [ ./module.nix ];
      #   nixpkgs.overlays = [ overlay ];
      # };
    in
      {
        packages.x86_64-linux = {
          inherit rocketpool;
        };
        defaultPackage.x86_64-linux = rocketpool;
        overlay = import ./overlay.nix;
        nixosModule = import ./module.nix;
      };
}
