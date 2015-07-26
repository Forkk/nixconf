# Module with configuration options used on desktop systems.
# Note that "desktop" in this case refers to something that is not a server,
# including laptops.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefoxWrapper
    kde4.quasselClient
    teamspeak_client

    rxvt_unicode
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
