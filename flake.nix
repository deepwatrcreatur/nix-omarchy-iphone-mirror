{
  description = "Nix packaging and NixOS module for Omarchy iPhone mirror and focused input";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        iphoneMirrorPkg = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          default = iphoneMirrorPkg;
          omarchy-iphone-mirror = iphoneMirrorPkg;
        };

        apps = {
          default = {
            type = "app";
            program = "${iphoneMirrorPkg}/bin/iphone-mirror";
          };
          setup-phone = {
            type = "app";
            program = "${iphoneMirrorPkg}/bin/iphone-setup-phone";
          };
          cli = {
            type = "app";
            program = "${iphoneMirrorPkg}/bin/iphone-mirror-cli";
          };
        };
      }
    )
    // {
      nixosModules = {
        default = self.nixosModules.omarchy-iphone-mirror;
        omarchy-iphone-mirror =
          { config, pkgs, ... }:
          {
            imports = [ ./module.nix ];
            services.omarchy-iphone-mirror.package =
              nixpkgs.lib.mkDefault self.packages.${pkgs.system}.omarchy-iphone-mirror;
          };
      };

      overlays.default = final: prev: {
        omarchy-iphone-mirror = self.packages.${prev.system}.omarchy-iphone-mirror;
      };
    };
}
