# Module for setting up GTK themes.
{ pkgs, config, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      gtk-engine-murrine
      gtk_engines
      numix-gtk-theme
    ];

    variables = {
      GTK_DATA_PREFIX = "/run/current-system/sw";
    };

    pathsToLink = [
      "/share/themes"
    ];
  };
}
