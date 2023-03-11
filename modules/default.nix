{
  self,
  inputs,
  ...
}: {
  flake.nixosModules = {
    kernel = ./kernel;
    panfork = ./panfork;
    fan-control = ./fan-control;
    cross = ./cross;

    rootfs = {
      imports = [./rootfs];
      _module.args = {nixpkgsPath = "${inputs.nixpkgs}";};
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

    default = {lib, ...}: {
      nixpkgs = {
        overlays = [
          self.overlays.default
        ];
        hostPlatform = lib.mkForce {
          config = "aarch64-unknown-linux-gnu";
          system = "aarch64-linux";
        };
      };
      imports = [
        self.nixosModules.kernel
        self.nixosModules.panfork
        self.nixosModules.fan-control
        # self.nixosModules.cross
      ];
    };
  };
}
