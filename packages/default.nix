{
  self,
  inputs,
  ...
}: {
  perSystem = {
    lib,
    system,
    config,
    pkgs,
    ...
  }: let
    pkgsCross = import inputs.nixpkgs {
      localSystem = system;
      crossSystem = "aarch64-linux";
    };
    pkgsForKernelCross = import inputs.nixpkgs-kernel {
      localSystem = system;
      crossSystem = "aarch64-linux";
    };
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

      fan-control = pkgsCross.callPackage ./fan-control {
        src = "${inputs.fan-control.outPath}/src";
      };

      linux-rock5b = pkgsForKernelCross.callPackage ./kernel {
        src = inputs.kernel-src.outPath;
      };

      panfork = pkgsCross.callPackage ./panfork {
        src = inputs.panfork.outPath;
      };

      kodi = pkgsCross.callPackage ./kodi {
        x11Support = false;
        gbmSupport = true;
        jre_headless = pkgs.jdk11_headless;
      };

      uboot =
        (import inputs.tow-boot {
          pkgs = import "${inputs.tow-boot}/nixpkgs.nix" {
            localSystem = system;
            crossSystem = "aarch64-linux";
          };
          configuration.nixpkgs.localSystem.system = system;
        })
        .radxa-rock5b;

      flash = pkgs.callPackage ./flash {
        inherit (config.packages) rootfs uboot;
      };

      default = config.packages.rootfs;
    };
  };
}
