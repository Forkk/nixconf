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
    curl
    file
    htop
    mosh
    mtr
    psmisc
    tmux
    wget

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
    lm_sensors
    nixops
    pandoc
    rxvt_unicode.terminfo
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };
}
