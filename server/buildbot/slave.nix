# Nix module for running one or more buildbot slaves.
{ config, lib, pkgs, ... }:

with lib;

let
  bbcfg = config.services.buildbot;
  buildslave = pkgs.buildbot-slave;

  configFile = name: cfg: pkgs.writeText "buildslave-${cfg.name}" ''
    import os

    from buildslave.bot import BuildSlave
    from twisted.application import service

    basedir = '.'
    rotateLength = 10000000
    maxRotatedFiles = 10

    # if this is a relocatable tac file, get the directory containing the TAC
    if basedir == '.':
        import os.path
        basedir = os.path.abspath(os.path.dirname(__file__))

    # note: this line is matched against to check that this is a buildslave
    # directory; do not edit it.
    application = service.Application('buildslave')

    try:
      from twisted.python.logfile import LogFile
      from twisted.python.log import ILogObserver, FileLogObserver
      logfile = LogFile.fromFullPath(os.path.join(basedir, "twistd.log"), rotateLength=rotateLength,
                                     maxRotatedFiles=maxRotatedFiles)
      application.setComponent(ILogObserver, FileLogObserver(logfile).emit)
    except ImportError:
      # probably not yet twisted 8.2.0 and beyond, can't set log yet
      pass

    buildmaster_host = '${cfg.masterHost}'
    port = ${toString cfg.masterPort}
    slavename = '${cfg.slaveName}'
    passwd = '${cfg.password}'
    keepalive = 600
    usepty = 0
    umask = None
    maxdelay = 300
    allow_shutdown = None

    s = BuildSlave(buildmaster_host, port, slavename, passwd, basedir,
                   keepalive, usepty, umask=umask, maxdelay=maxdelay,
                   allow_shutdown=allow_shutdown)
    s.setServiceParent(application)
  '';
in
{
  options = {
    services.buildbot = {
      slaves = mkOption {
        type = types.attrsOf (types.submodule (
          { name, config, ... }:
          {
            options = {
              name = mkOption {
                type = types.str;
                description = ''
                  Name used as a suffix for this slave's service. If undefined,
                  the name of the attribute set will be used.
                '';
              };

              slaveName = mkOption {
                type = types.str;
                description = ''
                  The name this slave uses when it registers with the master. If
                  undefined, the name of the attribute set will be used.
                '';
              };

              masterHost = mkOption {
                type = types.str;
                description = ''
                  Hostname of the buildbot master to connect to.
                '';
              };

              masterPort = mkOption {
                type = types.int;
                default = 9989;
              };

              password = mkOption {
                type = types.str;
              };

              dataDir = mkOption {
                type = types.path;
                description = ''
                  Directory where the buildslave's mutable data will be
                  stored. Defaults to /var/lib/buildbot/slave/<slavename>.
                '';
              };

              packages = mkOption {
                type = types.listOf types.path;
                default = [];
                description = ''
                  Packages which should be available to this buildslave.
                '';
              };

              info.admin = mkOption {
                type = types.str;
                description = ''
                  Name to list as the admin for this build slave.
                '';
              };
              
              info.host = mkOption {
                type = types.str;
                default = "Buildbot slave running on NixOS.";
                description = ''
                  Host information for this build slave.
                '';
              };

              user = mkOption {
                type = types.str;
                default = "buildbot";
                description = ''
                  User to run this buildslave under.
                '';
              };

              group = mkOption {
                type = types.str;
                default = "buildbot";
                description = ''
                  Group to run this buildslave under.
                '';
              };
            };

            config = mkMerge [{
              inherit name;
              slaveName = mkDefault name;
              dataDir = mkDefault "/var/lib/buildbot/slave/${name}";
            }];
        }));
        default = {};
        description = ''
          Buildbot slaves to run on this system.
        '';
      };
    };
  };

  config = {
    systemd.services = mapAttrs' (name: cfg: nameValuePair "buildslave-${name}" {
      description = "Buildbot slave \"${name}\"";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ buildslave ] ++ cfg.packages;
      preStart = ''
        if [[ ! -d ${cfg.dataDir} ]]; then
          echo "Initializing buildslave directory for slave \"${name}\"."
          mkdir -p ${cfg.dataDir}
          buildslave create-slave -r ${cfg.dataDir} MASTER NAME PASSWORD
          echo "Installing config file..."
          rm "${cfg.dataDir}/buildbot.tac"
          ln -s ${configFile name cfg} "${cfg.dataDir}/buildbot.tac"
          chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
        fi

        # Set up info files.
        echo "${cfg.info.admin}" > ${cfg.dataDir}/info/admin
        echo "${cfg.info.host}" > ${cfg.dataDir}/info/host
      '';
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        PermissionsStartOnly = "true";
        ExecStart = "${buildslave}/bin/buildslave start --nodaemon ${cfg.dataDir}";
      };
    }) bbcfg.slaves;


    # FIXME: Don't add these users if we don't need to.

  };
}
