{
  config,
  lib,
  pkgs,
  ...
}: {
  systemd.services.fan-control = {
    description = "Fan control for Radxa Rock5B";
    after = ["networking.target"];
    startLimitBurst = 0;
    startLimitIntervalSec = 60;
    serviceConfig = {
      Type = "forking";
      PIDFile = "@RUNSTATEDIR@/fan-control.pid";
      ExecStart = "${pkgs.fan-control}/bin/fan-control -d -p @RUNSTATEDIR@/fan-control.pid";
      Restart = "always";
      RestartSec = "2";
      TimeoutStopSec = "15";
    };
  };
}
