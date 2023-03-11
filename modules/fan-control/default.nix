{
  config,
  lib,
  pkgs,
  ...
}: {
  options.rock5b-fan-control = {
    enable = lib.mkEnableOption {
      default = true;
    };
    settings = lib.mkOption {
      description = "Settings for Radxa Rock 5B";
      type = lib.types.attrs;
      default = {
        pwmchip = -1;
        gpio = 0;
        pwm-period = 10000;
        temp-map = [
          {
            temp = 40;
            duty = 0;
            duration = 20;
          }
          {
            temp = 44;
            duty = 55;
            duration = 25;
          }
          {
            temp = 49;
            duty = 60;
            duration = 35;
          }
          {
            temp = 54;
            duty = 70;
            duration = 45;
          }
          {
            temp = 59;
            duty = 80;
            duration = 60;
          }
          {
            temp = 64;
            duty = 90;
            duration = 120;
          }
          {
            temp = 67;
            duty = 100;
            duration = 180;
          }
        ];
      };
    };
  };

  config = lib.mkIf config.rock5b-fan-control.enable {
    systemd.services.fan-control = {
      description = "Fan control for Radxa Rock5B";
      after = ["networking.target"];
      startLimitBurst = 0;
      startLimitIntervalSec = 60;
      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/fan-control.pid";
        ExecStart = "${pkgs.fan-control}/bin/fan-control -d -p /run/fan-control.pid";
        Restart = "always";
        RestartSec = "2";
        TimeoutStopSec = "15";
      };
    };

    environment.etc."fan-control.json".text = builtins.toJSON config.rock5b-fan-control.settings;
  };
}
