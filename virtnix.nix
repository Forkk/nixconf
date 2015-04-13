# NixOS configuration file for my NixOS virtual machine.
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix

      # Include other modules.
      ./common/base.nix
      ./common/xmonad.nix
      ./common/gui.nix
      ./common/x11.nix

      # Users
      ./common/users/forkk.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "virtnix"; # Define your hostname.
  networking.hostId = "4f2fbcac";

  # List services that you want to enable:
  services = {
    virtualboxGuest.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };
}
