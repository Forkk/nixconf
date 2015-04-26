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
    file
    tmux
    mtr
    mosh

    # Dev utils and version control
    gcc
    git
    vcsh

    # Editors and stuff
    vim
    emacs
    emacs24Packages.cask

    # Misc.
    rxvt_unicode.terminfo
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };
}
