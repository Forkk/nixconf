# Module with configuration options used on desktop systems.
# Note that "desktop" in this case refers to something that is not a server,
# including laptops.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    audacity
    dropbox
    evince
    firefoxWrapper
    kde4.quasselClient
    libreoffice
    screencloud
    skype
    teamspeak_client
    vlc

    glxinfo
    rxvt_unicode

    xbrightness
    xlibs.xbacklight
    xlibs.xev
    xlibs.xkill
    xlibs.xmodmap
    xlibs.xwininfo
    xsel
  ];

  nixpkgs.config = {
    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };
  };

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
  };
}
