# Module for additional nginx configuration options.
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.nginx;
  siteConfigs = concatStringsSep "\n\n" cfg.sites;

  mkWwwDir = dir: ''
    mkdir -p /var/www/${dir.name}
    chown ${dir.user}:${dir.group} /var/www/${dir.name}
  '';
in
{
  options = {
    services.nginx = {
      sites = mkOption {
        type = types.listOf types.string;
        default = [];
        description = ''
          A list of strings defining sites to add to nginx's config.
        '';
      };

      siteDirs = mkOption {
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

              user = mkOption {
                type = types.str;
                default = cfg.user;
                description = ''
                  The name of the user who should be set as the site directory's
                  owner. Defaults to the same user as nginx.
                '';
              };

              group = mkOption {
                type = types.str;
                default = cfg.group;
                description = ''
                  The name of the group who should be set as the site
                  directory's owner. Defaults to the same group as nginx.
                '';
              };
            };

            config = {
              name = mkDefault name;
            };
          }
        ));
        default = {};
        description = ''
          Directories to create inside of /var/www for storing site files which
          need to be updated by external applications such as buildbot.
          Files that don't need to be updated like this should be put in the Nix
          store.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    # Sets up the /var/www directory.
    system.activationScripts.www = "echo \"setting up /var/www\"\n" +
      concatStrings (mapAttrsToList (name: dir: ''
        mkdir -p /var/www/${dir.name}
        chown ${dir.user}:${dir.group} /var/www/${dir.name}
      '') cfg.siteDirs);

    services.nginx = {
      config = ''
worker_processes 4;

events {
  worker_connections 1024;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    # server_tokens off;

    # server_names_hash_bucket_size 64;
    # server_name_in_redirect off;

    include ${pkgs.nginx}/conf/mime.types;
    default_type application/octet-stream;

    # access_log /var/log/nginx/access.log;
    # error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";

    ${siteConfigs}
}
      '';
    };
  };
}
