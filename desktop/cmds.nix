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
        
    (writeScriptBin "toggle-compton" ''
      killall compton || ${pkgs.compton}/bin/compton -b --config ~/.compton.conf
    '')

    (writeScriptBin "wifi-reset" ''
      sudo systemctl restart wpa_supplicant
    '')
  ];
}
