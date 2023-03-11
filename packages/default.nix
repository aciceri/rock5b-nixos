{
  self,
  inputs,
  ...
}: {
  perSystem = {
    lib,
    system,
    self',
    pkgs,
    ...
  }: let
    pkgsCross = system: (import inputs.nixpkgs {
      localSystem = system;
      crossSystem = "aarch64-linux";
    });
    evalConfig = import "${inputs.nixpkgs}/nixos/lib/eval-config.nix";
    buildConfig = hostSystem: config:
      evalConfig {
        system = hostSystem;
        modules = [
          config
          self.nixosModules.cross
        ];
      };
  in {
    packages = {
      rootfs = (buildConfig system self.nixosModules.firstBoot).config.system.build.rootfsImage;

      fan-control = (pkgsCross system).callPackage ./fan-control {
        src = "${inputs.fan-control}/src";
      };

      linux_rock5b = (pkgsCross system).callPackage ./kernel {
        src = "${inputs.kernel-src}";
      };

      uboot =
        (import inputs.tow-boot {
          pkgs = import "${inputs.tow-boot}/nixpkgs.nix" {
            localSystem = system;
          };
          configuration.nixpkgs.localSystem.system = system;
        })
        .radxa-rock5b;

      flash = pkgs.callPackage ./flash {
        inherit (self'.packages) rootfs tow-boot;
      };

      default = self'.packages.rootfs;
    };
  };
}
