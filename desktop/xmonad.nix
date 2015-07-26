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
    openbox

    haskellPackages.ghc
    haskellPackages.xmonad
    haskellPackages.taffybar
    
    (pkgs.writeScriptBin "lock-screen" ''
      ${pkgs.xlibs.xset}/bin/xset dpms force off
      ${pkgs.xlibs.xset}/bin/xset dpms 5
      slock
      ${pkgs.xlibs.xset}/bin/xset -dpms
    '')

    (pkgs.writeScriptBin "temp-openbox" ''
      openbox
      ~/.xmonad/xmonad-x86_64-linux "$@"
    '')
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
        ${pkgs.compton}/bin/compton -b --config /home/forkk/.compton.conf
      '';
    };

    desktopManager.default = "none";
  };
}
