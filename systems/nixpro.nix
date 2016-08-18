# This is the NixOS configuration file for my laptop (hostname "nixpro").
{ config, pkgs, ... }:

{
  imports =
    [ ../common/base.nix
      ../desktop/base.nix
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

    # wireless.enable = true;
    networkmanager.enable = true;

    firewall.allowedTCPPorts = [
      5000 32400
      27036 27037
    ];

    firewall.allowedUDPPorts = [ 27031 ];
  };

  # Settings for modules in the ./desktop/ directory.
  desktop = {
    enable = true;
    xmonad.enable = true;
    sleepLock.enable = true;
  };

  # List services that you want to enable:
  services = {
    upower.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.hplip pkgs.gutenprint ];
    };

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

    tarsnap = {
      enable = true;
      keyfile = "/root/tarsnap.key";
      archives = {
        home = {
          directories = [ "/home/forkk" ];
          excludes = [
            "/home/forkk/.local/share/Steam/"
          ];
          period = "2:00";
          printStats = true;
        };
      };
    };
  };

  hardware.bluetooth.enable = true;

  hardware.pulseaudio.support32Bit = true;

  nixpkgs.config = {
    packageOverrides = {
      bluez = pkgs.bluez5;
    };
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8182;
    }
  ];
}
