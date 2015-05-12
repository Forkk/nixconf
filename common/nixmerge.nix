# Provides a shell script for maintaining and updating a patched copy of
# nixpkgs.
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.nixpkgs.nixmerge;
in
{
  options = {
    nixpkgs.nixmerge = {
      enable = mkEnableOption "nixpkgs repo updater";

      repoDir = mkOption {
        # This must be a string instead of a path or Nix will change it to point
        # somewhere in the Nix store.
        type = types.str;
        default = "/etc/nixos/nixpkgs";
        description = ''
          Path to store the repository in.
        '';
      };

      upstreamRepo = mkOption {
        type = types.str;
        default = https://github.com/NixOS/nixpkgs.git;
        description = ''
          Path to store the repository at.
        '';
      };

      mergeRepo = mkOption {
        type = types.str;
        default = https://github.com/NixOS/nixpkgs.git;
        description = ''
          Path to store the repository at.
        '';
      };

      channelUrl = mkOption {
        type = types.str;
        default = http://nixos.org/channels/nixos-unstable;
        description = ''
          The channel to patch against.
        '';
      };

      branches = mkOption {
        type = types.listOf types.str;
        default = "";
        description = ''
          A list of branches to merge into the channel.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (writeScriptBin "nixpkgs-update" (''
        UPSTREAM="${cfg.upstreamRepo}"
        REMOTE="${cfg.mergeRepo}"
        BRANCHES="${toString cfg.branches}"
        CHANNEL="${cfg.channelUrl}"
        DEST="${cfg.repoDir}"
      '' + (lib.readFile ./nixmerge.sh)))
    ];
  };
}
