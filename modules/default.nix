{
  self,
  inputs,
  ...
}: {
  flake.nixosModules = {
kernel = {config, ...}: {
        imports = [./kernel];
        nixpkgs.overlays = [
          (_: _: {
            inherit (self.packages.${config.nixpkgs.localSystem.system}) linux_rock5b;
          })
        ];
      };

      cross = ./cross;  
      
      fan-control = {config, ...}: {
        imports = [./fan-control];
        nixpkgs.overlays = [
          (_: _: {
            inherit (self.packages.${config.nixpkgs.localSystem.system}) fan-control;
          })
        ];
      };

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

      default = {
        imports = [
          self.nixosModules.kernel
          self.nixosModules.fan-control
          self.nixosModules.cross
        ];
      };
  };
}
