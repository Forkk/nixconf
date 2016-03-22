{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.buildbot;
  defUsers  = filterAttrs (name: cfg: cfg.user  == "buildbot");
  defGroups = filterAttrs (name: cfg: cfg.group == "buildbot");
  defUserMasters = defUsers cfg.masters;
  defUserSlaves = defUsers cfg.slaves;
  defGroupMasters = defGroups cfg.masters;
  defGroupSlaves = defGroups cfg.slaves;
in
{
  options = {
    services.buildbot = {
      enable = mkEnableOption "buildbot";
    };
  };

  imports = [
    ./master.nix
    ./slave.nix
  ];

  config = {
    # TODO: UID & GID?

    # We always create users when this module is imported. If this were in
    # nixpkgs, we would need a different approach here.
    users.extraUsers.buildbot = {
      group = "buildbot";
      home = "/var/lib/buildbot";
    };

    users.extraGroups.buildbot = {
    };
  };
}
