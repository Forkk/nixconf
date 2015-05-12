{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.buildbot;
  defUsers  = filterAttrs (name: cfg: cfg.user  == "buildbot");
  defGroups = filterAttrs (name: cfg: cfg.group == "buildbot");
  defUserMasters = defUsers cfg.masters;
  defUserSlaves = defUsers cfg.masters;
  defGroupMasters = defGroups cfg.masters;
  defGroupSlaves = defGroups cfg.masters;
in
{
  imports = [
    ./master.nix
    ./slave.nix
  ];

  # Add default "buildbot" user and group if there is at least one buildbot
  # master or slave using them.
  config = {
    # TODO: UID & GID?
    users.extraUsers.buildbot = mkIf (defUserMasters != {} && defUserSlaves != {}) {
      group = "buildbot";
      home = "/var/lib/buildbot";
    };

    users.extraGroups.buildbot = mkIf (defGroupMasters != {} && defGroupSlaves != {}) {
    };
  };
}
