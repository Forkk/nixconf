# Module for additional nginx configuration options.
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.nginx;
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
      httpConfig = concatStringsSep "\n\n" (map readFile cfg.sites);
    };
  };
}
