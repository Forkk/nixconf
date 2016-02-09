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
    curl wget
    file ncdu
    htop iotop
    mtr traceroute
    usbutils pciutils
    lm_sensors
    psmisc
    mosh
    tmux

    # Archive tools
    p7zip
    unrar
    unzip

    # Network tools
    telnet

    # Dev utils and version control
    gcc
    git
    vcsh

    # Editors and stuff
    emacs
    emacs24Packages.cask
    vim

    # Misc.
    aspell
    nixops
    pandoc
    rxvt_unicode.terminfo
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };
}
