# xmonad-specific config
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dmenu
    feh
    xlibs.xset
    xorg.xmessage
    compton
    slock

    haskellPackages.ghc
    haskellPackages.xmonad
    haskellPackages.taffybar
    haskellPackages.xmobar # TODO: Switch to taffybar
  ];

  security.setuidPrograms = [ "slock" ];

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
        ${pkgs.xlibs.xset}/bin/xsetroot -cursor_name left_ptr
        ${pkgs.xlibs.xset}/bin/xset -dpms
        ${pkgs.xlibs.xset}/bin/xset s off
        ${pkgs.compton}/bin/compton -b --config /home/forkk/.compton.conf
      '';
    };

    desktopManager.default = "none";
  };
}
