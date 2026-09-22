{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.omarchy-iphone-mirror;
in
{
  options.services.omarchy-iphone-mirror = {
    enable = lib.mkEnableOption "Omarchy iPhone mirroring and focused input application";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.omarchy-iphone-mirror or (pkgs.callPackage ./package.nix { });
      description = "The omarchy-iphone-mirror package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    # usbmuxd is required for iOS USB socket communication
    services.usbmuxd.enable = true;

    environment.systemPackages = [
      cfg.package
      pkgs.libimobiledevice
      pkgs.usbmuxd
    ];
  };
}
