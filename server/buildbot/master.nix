# Nix module for running one or more buildbot masters.
{ config, lib, pkgs, ... }:

with lib;

let
  bbcfg = config.services.buildbot;
  configFile = name: cfg: pkgs.writeText "buildbot-${cfg.name}" cfg.config;
in
{
  options = {
    services.buildbot = {
      masters = mkOption {
        type = types.attrsOf (types.submodule (
          { name, config, ... }:
          {
            options = {
              name = mkOption {
                type = types.str;
                description = ''
                  Name used as a suffix for this build master's service. If
                  undefined, the name of the attribute set will be used.
                '';
              };

              dataDir = mkOption {
                type = types.path;
                description = ''
                  Directory where the build master's mutable data will be
                  stored. Defaults to /var/lib/buildbot/master/<name>.
                '';
              };

              config = mkOption {
                type = types.str;
                example = literalExample "readFile ./site-bbot.cfg";
                description = ''
                  String containing the contents of this build master's config
                  file.
                '';
              };

              user = mkOption {
                type = types.str;
                default = "buildbot";
                description = ''
                  User to run this build master under.
                '';
              };

              group = mkOption {
                type = types.str;
                default = "buildbot";
                description = ''
                  Group to run this build master under.
                '';
              };
            };

            config = mkMerge [{
              inherit name;
              dataDir = mkDefault "/var/lib/buildbot/master/${name}";
            }];}));
        default = {};
        description = ''
          Buildbot masters to run on this system.
        '';
      };
    };
  };

  config = {
    systemd.services = mapAttrs' (name: cfg: nameValuePair "buildbot-${name}" {
      description = "Buildbot master \"${name}\"";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.buildbot ];
      preStart = ''
        echo "Initializing buildbot directory for master \"${name}\"."
        mkdir -p ${cfg.dataDir}
        # We should be fine replacing this file on every startup, as it
        # shouldn't ever change.
        test -f ${cfg.dataDir}/buildbot.tac && rm ${cfg.dataDir}/buildbot.tac
        buildbot create-master -r --config=${configFile name cfg} ${cfg.dataDir}
        chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
      '';
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        PermissionsStartOnly = "true";
        ExecStart = "${pkgs.buildbot}/bin/buildbot start --nodaemon ${cfg.dataDir}";
      };
    }) bbcfg.masters;
  };
}
