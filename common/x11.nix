# Configuration options for X11
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    numix-gtk-theme
  ];

  services.xserver = {
    enable = true;
    layout = "us";

    displayManager = {
      lightdm.enable = true;
      sessionCommands = ''
        ${pkgs.xlibs.xset}/bin/xset r rate 250 42
        ${pkgs.xlibs.xset}/bin/xset -b
      '';
    };
  };
}
