# Some basic standard configuration options for all of my systems.
{ pkgs, ... }:

{
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # Shell utils
    wget
    curl

    # Dev utils
    git
    gcc

    # Editors and stuff
    vim
    emacs
    emacs24Packages.cask

    # Misc.
    rxvt_unicode.terminfo
    vcsh
  ];
}
