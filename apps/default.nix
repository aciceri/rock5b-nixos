{inputs, ...}: {
  perSystem = {self', ...}: {
    apps = {
      flash.program = "${self'.packages.flash}/bin/flash";
      default = self'.apps.flash;
    };
  };
}
