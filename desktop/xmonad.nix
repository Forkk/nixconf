# xmonad-specific config
{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.desktop.xmonad;
in
{
  options = {
    desktop.xmonad = {
      enable = mkEnableOption "xmonad";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dmenu
      feh
      xlibs.xset
      xorg.xmessage
      openbox

      haskellPackages.ghc
      haskellPackages.xmonad
      haskellPackages.taffybar

      (pkgs.writeScriptBin "temp-openbox" ''
        openbox
        ~/.xmonad/xmonad-x86_64-linux "$@"
      '')
    ];

    services.xserver = {
      windowManager = {
        default = "xmonad";
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = haskellPackages: [
            haskellPackages.taffybar
          ];
        };
      };

      displayManager = {
        sessionCommands = ''
          eval `${pkgs.dbus_daemon}/bin/dbus-launch --auto-syntax`
        '';
      };

      desktopManager.default = "none";
    };
  };
}
