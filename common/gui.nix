# Module with common GUI applications.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox
    kde4.quasselClient

    rxvt_unicode
  ];
}
