# nix-omarchy-iphone-mirror

Nix flake and NixOS module packaging for **iPhone Mirroring** using [`DanielLemky/omarchy-iphone-mirror`](https://github.com/DanielLemky/omarchy-iphone-mirror).

## Features

- **On-Demand iPhone Mirroring**: Stream your iPhone screen directly to your Linux desktop over USB or Wi-Fi.
- **Two-Way Interaction**: Mouse clicks, drags, mouse-wheel scrolling, and keyboard input forwarded into the phone.
- **Low-Latency Video**: Direct HEVC streaming using `mpv`.
- **Works on Any Wayland Desktop**: Runs natively on Niri, Hyprland, Sway, GNOME, etc.
- **Declarative NixOS Setup**: Automatically manages `usbmuxd` service and command line helpers.

## Requirements

- An iPhone with **Developer Mode** enabled.
- A mounted Developer Disk Image (handled via `iphone-setup-phone`).
- `services.usbmuxd.enable = true;` on NixOS.

## Quick Run

```bash
# Pair and inspect device
nix run github:deepwatrcreatur/nix-omarchy-iphone-mirror#setup-phone -- check

# Launch viewer
nix run github:deepwatrcreatur/nix-omarchy-iphone-mirror
```

## NixOS Module Usage

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-omarchy-iphone-mirror.url = "github:deepwatrcreatur/nix-omarchy-iphone-mirror";
  };

  outputs = { self, nixpkgs, nix-omarchy-iphone-mirror, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        nix-omarchy-iphone-mirror.nixosModules.default
        {
          services.omarchy-iphone-mirror.enable = true;
        }
      ];
    };
  };
}
```
