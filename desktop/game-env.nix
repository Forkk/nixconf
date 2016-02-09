# A FHS-compliant chroot environment for playing games.
{ pkgs, lib, config, ... }:

let
  fhsEnv = pkgs.buildFHSUserEnv {
    name = "game-env";
    targetPkgs = pkgs: with pkgs;
      [ alsaLib
        xlibs.libX11 xlibs.libXext xlibs.libXcursor xlibs.libXrandr xlibs.libXinerama
        rxvt_unicode.terminfo
      ];
    multiPkgs = pkgs: with pkgs;
      [
      ];
    runScript = "bash";
  };
in
{
  environment.systemPackages = [
    fhsEnv
  ];
}
