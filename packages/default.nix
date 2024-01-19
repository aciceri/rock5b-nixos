{
  self,
  inputs,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];
  perSystem = {
    lib,
    system,
    config,
    pkgs,
    final,
    ...
  }: let
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
    overlayAttrs = {
      mesa = final.callPackage ./panfork {
        src = inputs.panfork.outPath;
        prev = pkgs;
      };
      kodi-rock5b = final.callPackage ./kodi rec {
        x11Support = false;
        gbmSupport = true;
        mesa = final.mesa;
      };
      fan-control-rock5b = final.callPackage ./fan-control {
        src = "${inputs.fan-control.outPath}/src";
      };
      linux-rock5b = final.callPackage ./kernel {
        src = inputs.kernel-src.outPath;
      };
    };
    # export pkgsCross for building on a x86_64 machine
    packages = builtins.mapAttrs (name: value: final.pkgsCross.aarch64-multiplatform.${value}) {
      fan-control = "fan-control-rock5b";
      linux-rock5b = "linux-rock5b";
      panfork = "mesa";
      kodi = "kodi-rock5b";
    } // {
      # not injecting these into nixpkgs
      rootfs = (buildConfig system self.nixosModules.firstBoot).config.system.build.rootfsImage;

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
