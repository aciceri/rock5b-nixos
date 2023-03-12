{inputs, ...}: {
  perSystem = {config, ...}: {
    apps = {
      flash.program = "${config.packages.flash}/bin/flash";
      default = config.apps.flash;
    };
  };
}
