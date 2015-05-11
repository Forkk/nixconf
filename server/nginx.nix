# Module for additional nginx configuration options.
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.nginx;
  siteConfigs = concatStringsSep "\n\n" (map readFile cfg.sites);
in
{
  options = {
    services.nginx = {
      sites = mkOption {
        type = types.listOf types.path;
        default = [];
        description = ''
          A list of files defining sites to add to nginx's config.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
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
