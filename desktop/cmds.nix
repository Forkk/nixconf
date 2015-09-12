# Custom shell commands
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unclutter
    (writeScriptBin "toggle-cursor" ''
      killall unclutter || ${pkgs.unclutter}/unclutter -idle 0 -root &
    '')

    (writeScriptBin "monitor2" ''
      case $1 in
          "on" )
              ${pkgs.xlibs.xrandr}/bin/xrandr --output HDMI2 --auto --right-of eDP1
              ${pkgs.xlibs.xset}/bin/xset -dpms
              ;;
          "off" )
              ${pkgs.xlibs.xrandr}/bin/xrandr --output HDMI2 --off
      esac
    '')

    # This script fixes T-Mobile's stupid DNS configuration, which causes emacs
    # to lock up on startup when my computer is tethered to my phone. There's
    # probably a better way of fixing this (like permanently setting these as my
    # DNS servers), but I'm lazy and Nix won't let me set DNS servers on a
    # per-network basis.
    (writeScriptBin "fix-dns" ''
      cat <<EOF > /etc/resolv.conf
      nameserver 8.8.8.8
      nameserver 8.8.4.4
      EOF
    '')
  ];
}
