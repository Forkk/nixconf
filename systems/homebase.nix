{ config, pkgs, ... }:

{
  imports =
    [ ../common/base.nix
      ../desktop/base.nix
      ../desktop/game-env.nix
      ../misc/latex.nix
      ../users/forkk.nix

      /etc/nixos/secrets.nix
    ];

  # Open source drivers don't support GTX 9xx cards. :(
  boot.blacklistedKernelModules = [ "nouveau" ];

  networking = {
    hostName = "homebase"; # Define your hostname.
    networkmanager.enable = true;
  };

  desktop = {
    enable = true;
    xmonad.enable = true;
    sleepLock.enable = true;
  };

  services = {
    openssh.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.hplip pkgs.gutenprint ];
    };

    xserver = {
      vaapiDrivers = [ pkgs.vaapiVdpau ];
      videoDrivers = [ "nvidia" ];
      screenSection = ''
        Option         "Stereo" "0"
        Option         "nvidiaXineramaInfoOrder" "DFP-2"
        Option         "metamodes" "DVI-I-1: nvidia-auto-select +1920+0, DP-0: nvidia-auto-select +0+0"
        Option         "SLI" "Off"
        Option         "MultiGPU" "Off"
        Option         "BaseMosaic" "off"
      '';
      monitorSection = ''
      '';
    };
  };

  virtualisation = {
    virtualbox = {
      host.enable = true;
    };
  };
}
