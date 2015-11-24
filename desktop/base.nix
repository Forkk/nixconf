# Module with configuration options used on desktop systems.
# Note that "desktop" in this case refers to something that is not a server,
# including laptops.
{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.desktop;

  comptonStart =
    (pkgs.writeScriptBin "compton-start" ''
      ${pkgs.compton}/bin/compton -b --config $HOME/.compton.conf
    '');
  comptonToggle =
    (pkgs.writeScriptBin "compton-toggle" ''
      killall compton || ${comptonStart}/bin/compton-start
    '');

  lockScreen =
    (pkgs.writeScriptBin "lock-screen" ''
      revert() {
        ${pkgs.xlibs.xset}/bin/xset -dpms
      }
      trap revert SIGHUP SIGINT SIGTERM
      ${pkgs.xlibs.xset}/bin/xset +dpms dpms 600

      tmpdir=/run/user/$UID/lock-screen
      [ -d $tmpdir ] || mkdir $tmpdir
      ${pkgs.scrot}/bin/scrot $tmpdir/screen.png
      # ${pkgs.i3lock}/bin/i3lock -n -i $tmpdir/screen.png &
      # temp_pid=$!
      ${pkgs.imagemagick}/bin/convert $tmpdir/screen.png -scale 10% -scale 1000% $tmpdir/screen.png
      # ${pkgs.imagemagick}/bin/convert -blur 0x2 $tmpdir/screen.png $tmpdir/screen.png
		  ${pkgs.imagemagick}/bin/convert -gravity center -composite -matte \
        $tmpdir/screen.png ${lockIcon} $tmpdir/screen.png
      ${pkgs.i3lock}/bin/i3lock -n -i $tmpdir/screen.png &
      i3pid=$!
      # kill $temp_pid
      wait $i3pid
      rm $tmpdir/screen.png
      revert
    '');
  lockIcon = ./lockicon.png;
in
{
  imports = [
    ./xmonad.nix
    ./cmds.nix
    ./gtktheme.nix
  ];

  options = {
    desktop = {
      enable = mkEnableOption "desktop";

      sleepLock.enable = mkEnableOption "sleepLock";
    };
  };


  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      audacity
      dropbox
      evince
      firefoxWrapper
      chromium
      kde4.quasselClient
      libreoffice
      # screencloud
      skype
      teamspeak_client
      vlc
      pavucontrol
      lxappearance
      networkmanagerapplet
      compton
      i3lock

      glxinfo
      rxvt_unicode

      xbrightness
      xlibs.xbacklight
      xlibs.xev
      xlibs.xkill
      xlibs.xmodmap
      xlibs.xwininfo
      xsel

      lockScreen
      comptonStart
      comptonToggle

      (st.override {
        conf = readFile ./st-config.h;
      })
    ];

    nixpkgs.config = {
      firefox = {
        enableGoogleTalkPlugin = true;
        enableAdobeFlash = true;
      };
    };


    services = {
      xserver = {
        enable = true;
        layout = "us";

        displayManager = {
          lightdm.enable = true;
          sessionCommands = ''
            ${pkgs.xlibs.xset}/bin/xset r rate 250 42
            ${pkgs.xlibs.xset}/bin/xset -b
            ${pkgs.xlibs.xset}/bin/xset -dpms
            ${pkgs.xlibs.xset}/bin/xset s off
            ${pkgs.xlibs.xmodmap}/bin/xmodmap ~/.Xmodmap
            ${comptonStart}
          '';
        };
      };
    };

    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };

    hardware.pulseaudio.enable = true;

    # Font Settings
    fonts = {
      enableFontDir = true;
      enableGhostscriptFonts = true;
      fonts = with pkgs; [
        corefonts  # Micrsoft free fonts
        inconsolata  # monospaced
        ipafont
        ubuntu_font_family  # Ubuntu fonts
        source-code-pro
      ];
    };


    # Lock the screen when entering sleep mode.
    # TODO: Make this a bit more robust.
    systemd.services.sleeplock = mkIf cfg.sleepLock.enable {
      description = "Lock Screen on Sleep";
      requires = [ "display-manager.service" ];
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      script = ''
        export DISPLAY=`${pkgs.procps}/bin/w -f | tail -n +3 | ${pkgs.gawk}/bin/awk '{print $2}'`
        # export USER=forkk
        ${pkgs.i3lock}/bin/i3lock -n
      '';
      environment = { DISPLAY = ":0"; };
      serviceConfig.Type = "simple";
      serviceConfig.User = "forkk";
      serviceConfig.Group = "users";
    };
  };
}
