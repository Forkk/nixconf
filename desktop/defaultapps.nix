# Modified from https://github.com/NixOS/nixpkgs/pull/5966. Hopefully we can get
# this merged once it's been cleaned up a lot, but for now it'll be here.
{ pkgs, lib, config, ... }:
with pkgs.lib;
let
  cfg = config.desktop.mimeapps;

  # From https://gist.github.com/nathan7/9179e4f081808dc57bc0
  attrsToList = attrs:
    let names  = builtins.attrNames  attrs;
        values = builtins.attrValues attrs;
        length = builtins.length     names;
        gen    = n: { name  = builtins.elemAt names  n;
                      value = builtins.elemAt values n; };
        in  builtins.genList gen length;

  mimetypeList = map (elem: {
    mimetype = elem.name;
    desktop = elem.value;
  }) (attrsToList cfg.defaults);

  defaultsListString = lib.concatStringsSep "\n" (
    map (item: item.mimetype+"="+item.desktop) mimetypeList
  );

  mimeappsListFile = pkgs.writeTextFile {
    name = "mimeapps.list";
    destination = "/etc/xdg/mimeapps.list";
    text = ''
      [Default Applications]
      ${defaultsListString}
    '';
  };

  defaultsListFile = pkgs.writeTextFile {
    name = "defaults.list";
    destination = "/etc/xdg/defaults.list";
    text = ''
      [Default Applications]
      ${defaultsListString}
    '';
  };

  pkg = pkgs.buildEnv {
    name = "defaultapps";
    paths = [ mimeappsListFile defaultsListFile ];
    pathsToLink = [ "/etc/xdg" "/share/applications" ];
  };
in
{
  options = {
    desktop.mimeapps = {
      extraDesktopFiles = mkOption {
        type = types.listOf types.path;
        default = [];
        description = ''
          List of extra desktop files to add to /share/applications/.
        '';
      };

      defaults = mkOption {
        type = types.attrsOf types.string;
        default = {};
        description = ''
          Mapping from mime types to desktop files used to open them. Doesn't
          check that the desktop files actually exist.
        '';
        example = literalExample ''
          {
            'application/pdf' = "evince.desktop";
          }
        '';
      };
    };
  };

  config = {
    environment.systemPackages = [ pkg ] ++ cfg.extraDesktopFiles;
  };
}
