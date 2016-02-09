# Nix module to set my USB headset as the default PulseAudio sink when it is
# plugged in.
{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeScriptBin "set-headset" ''
      pacmd set-default-sink alsa_output.usb-Logitech_Logitech_G930_Headset-00-Headset.analog-stereo
      pacmd set-default-source alsa_input.usb-Logitech_Logitech_G930_Headset-00.analog-mono
    '')
   ];
}
