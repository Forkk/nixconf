# Module with common GUI applications.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefoxWrapper
    kde4.quasselClient

    rxvt_unicode
  ];

  nixpkgs.config = {
    allowUnfree = true;
    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };
  };
}
