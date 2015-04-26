# This is the NixOS configuration file for my laptop (hostname "nixpro").
{ config, pkgs, ... }:

{
  imports =
    [ ../common/base.nix

      ../desktop/xmonad.nix
      ../desktop/base.nix
      ../desktop/x11.nix

      ../users/forkk.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;
    # Define on which hard drive you want to install Grub.
    device = "/dev/sdb";
  };

  networking = {
    hostName = "nixpro";
    hostId = "c6e0bc2a";

    wireless.enable = true;
  };

  # List services that you want to enable:
  services = {
    upower.enable = true;

    xserver = {
      synaptics = {
        enable = true;
        twoFingerScroll = true;
        tapButtons = false;
        palmDetect = false;
        horizontalScroll = false;
        maxSpeed = "1.0";
        minSpeed = "0.5";
        accelFactor = "0.04";
        additionalOptions = ''
          Option "SoftButtonAreas" "50% 0 82% 0 0 0 0 0"
        '';
      };
    };
  };
}