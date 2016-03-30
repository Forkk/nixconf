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

    firewall.allowedTCPPorts = [ 32400 ];
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

    plex = {
      enable = true;
      managePlugins = false;
      package = pkgs.plex.overrideDerivation (old: {
        version = "0.9.16.3.1840";
        vsnHash = "cece46d";

        src = pkgs.fetchurl {
          url = "https://downloads.plex.tv/plex-media-server/0.9.16.3.1840-cece46d/plexmediaserver-0.9.16.3.1840-cece46d.x86_64.rpm";
          sha256 = "0p1rnia18a67h05f7l7smkpry1ldkpdkyvs9fgrqpay3w0jfk9gd";
        };
      });
    };

    tarsnap = {
      enable = true;
      archives = {
        home = {
          keyfile = "/root/tarsnap/home.key";
          directories = [ "/home/forkk" ];
          excludes = [
            "/home/forkk/.local/share/Steam/"
            "/home/forkk/VirtualBox VMs/"
            "/home/forkk/trash/"
            "/home/forkk/Downloads/"
            "/home/forkk/Dropbox/"
            "/home/forkk/.cache/"
          ];
          period = "4:00";
          printStats = true;
          checkpointBytes = "5GB";
        };
        var = {
          keyfile = "/root/tarsnap/var.key";
          directories = [ "/var/lib/plex" ];
          period = "2:00";
          printStats = true;
        };
      };
    };
  };

  virtualisation = {
    virtualbox = {
      host.enable = true;
    };
  };

  environment.variables = {
    __GL_SYNC_TO_VBLANK="1";
    __GL_SYNC_DISPLAY_DEVICE="DP-0";
    __VDPAU_NVIDIA_SYNC_DISPLAY_DEVICE="DP-0";
  };
}
