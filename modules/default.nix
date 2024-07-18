{
  self,
  inputs,
  ...
}: {
  flake.nixosModules = {
    kernel = ./kernel;

    fan-control = ./fan-control;

    cross = ./cross;

    rootfs = {
      imports = [./rootfs self.nixosModules.cross];
      _module.args.nixpkgsPath = "${inputs.nixpkgs}";
    };

    apply-overlay = {
      imports = [./apply-overlay];
      _module.args.rock5bFlake = self;
    };

    firstBoot = {
      imports = [
        self.nixosModules.default
        self.nixosModules.rootfs
      ];
      services.openssh = {
        enable = true;
      };
      users.users.root.password = "";
    };

    default = {
      imports = [
        self.nixosModules.apply-overlay
        self.nixosModules.kernel
        self.nixosModules.fan-control
      ];
    };
  };
}
