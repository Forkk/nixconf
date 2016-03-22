# Module for setting up GTK themes.
{ pkgs, config, ... }:

let
  arc-theme = with pkgs; stdenv.mkDerivation rec {
    version = "20151002";
    name = "arc-gtk-theme-${version}";

    src = fetchFromGitHub {
      owner = "horst3180";
      repo = "Arc-theme";
      rev = version;
      sha256 = "0ks6dgcrhbks73nn3x8zj7lwbkf5alr97ii6v6chy2x2q19h30kv";
    };

    buildInputs = [ autoconf automake pkgconfig ];

    dontBuild = true;

    installPhase = ''
      ./autogen.sh --prefix=$out
      make install
    '';

    meta = {
      description = "Arc GTK theme";
      homepage =  https://github.com/horst3180/Arc-theme;
      license = stdenv.lib.licenses.gpl3;
      platforms = stdenv.lib.platforms.all;
    };
  };
in
{
  environment = {
    systemPackages = with pkgs; [
      gtk-engine-murrine
      gtk_engines
      numix-gtk-theme
      arc-theme
      numix-icon-theme
      numix-icon-theme-circle
      hicolor_icon_theme
      gnome.gnomeicontheme
    ];

    variables = {
      GTK_DATA_PREFIX = "/run/current-system/sw";
    };

    pathsToLink = [
      "/share/themes"
      "/share/icons"
      "/share/pixmaps"
    ];
  };

  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      qt4 = pkgs.qt4.override { gtkStyle = true; };
      qt5.base = pkgs.qt5.base.override { gtkStyle = true; };
    };
  };

  services.xserver.displayManager.sessionCommands = ''
    # This allows GTK to load SVG icons.
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg}/lib/gdk-pixbuf-2.0/*/loaders.cache)
    #*/) <- This fools emacs syntax highlighting. It thinks there's a comment on the above line.
  '';
}
