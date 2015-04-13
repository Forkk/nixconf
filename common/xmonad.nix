# xmonad-specific config
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dmenu
    feh
    xlibs.xset
    xorg.xmessage
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
      '';
    };

    desktopManager.default = "none";
  };
}
