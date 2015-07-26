# Configuration options for X11
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pavucontrol
    lxappearance
  ];

  environment.variables = {
    GTK_DATA_PREFIX = "$HOME/.nix-profile";
  };

  services.xserver = {
    enable = true;
    layout = "us";

    displayManager = {
      lightdm.enable = true;
      sessionCommands = ''
        ${pkgs.xlibs.xset}/bin/xset r rate 250 42
        ${pkgs.xlibs.xset}/bin/xset -b
        ${pkgs.xlibs.xset}/bin/xset -dpms
        ${pkgs.xlibs.xset}/bin/xset s off
        ${pkgs.xlibs.xmodmap}/bin/xmodmap ~/.Xmodmap
      '';
    };
  };

  hardware.pulseaudio = {
    enable = true;
  };
}
