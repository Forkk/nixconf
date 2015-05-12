# This is the NixOS configuration file for my server. This server hosts my
# website and Plex Media Server.
{ config, pkgs, lib, ... }:

{
  imports =
    [ ../common/base.nix
      ../common/nixmerge.nix

      ../server/nginx
      ../server/buildbot

      ../users/forkk.nix
    ];

  # Use the GRUB 1 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 1;
    extraPerEntryConfig = "root (hd0)";
    # Define on which hard drive you want to install Grub.
    device = "nodev";
  };

  networking = {
    hostName = "forkknet";
    hostId = "f96b21c2";
  };

  # Open the firewall for HTTP and SSH.
  # TODO: Individual modules should set this up.
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  # Service configuration.
  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
    };

    # Web Server
    nginx = {
      enable = true;
      sites = [ ../server/sites/forkknet ];
      siteDirs = {
        "forkk.net" = {
          user = "buildbot";
          group = "buildbot";
        };
      };
    };

    buildbot.masters = {
      fnet-site = {
        config = lib.readFile ../server/buildbot/bbot-fnetsite.py;
      };
    };
  };

  containers = {
    # Container for forkk.net's Buildbot slave
    fnet-slave = {
      autoStart = true;
      config = { config, pkgs, ... }:
      {
        imports = [ ../common/base.nix ../server/buildbot/slave.nix ];

        services.buildbot.slaves = {
          forkknet = {
            masterHost = "localhost";
            password = "password";
            packages = with pkgs; [
              git
              (haskellngPackages.ghcWithPackages (p: with p; [
                hakyll
              ]))
            ];
            info.admin = "Forkk";
            info.host = ''
              Buildslave running on NixOS with git, GHC, and Hakyll.
            '';
          };
        };
      };
    };
  };


  nixpkgs.nixmerge = {
    enable = true;
    mergeRepo = https://github.com/Forkk/nixpkgs.git;
    branches = [ "plex-media-server" ];
  };

  # Use a bash prompt that doesn't break TRAMP.
  # TODO: Fix this within emacs instead.
  programs.bash.promptInit = "PS1=\"[\\u@\\h \\W]\$ \"";
}
