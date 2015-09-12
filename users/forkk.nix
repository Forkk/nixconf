{ ... }:

{
  users.extraUsers.forkk = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/forkk";
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
