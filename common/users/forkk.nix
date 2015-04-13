{ ... }:

{
  users.extraUsers.forkk = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/forkk";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACAndC8BKL7JLG+7BxvHzXg9AkBd8iKRPdVuIKH6Z6onrSeiP5iPf5UiCQS096tn6Te+96ZgBSwIX2IZ+6rO+0qOwDYMwm3/711fG1eWhFWXwehHWcdyJGs13FByXSc/MhpYg/bqJgjfeM4MVYsSkIQSm+tPGsqlddMr1iw6cdmQFNwQQ== forkk@forkk.net"
    ];
  };
}
