# xmonad-specific config
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dmenu
    feh
    xlibs.xset
    xorg.xmessage
    compton
  ];

  services.xserver = {
    windowManager.default = "xmonad";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };

    displayManager = {
      sessionCommands = ''
        ${pkgs.xlibs.xset}/bin/xsetroot -cursor_name left_ptr
        ${pkgs.compton}/bin/compton -b --config /home/forkk/.compton.conf
      '';
    };

    desktopManager.default = "none";
  };
}
