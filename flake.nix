{
  description = "Opinionated NixOS modules and building infrastructure for Radxa Rock5B";

  nixConfig = {
    extra-substituters = ["https://rock5b-nixos.cachix.org"];
    extra-trusted-public-keys = ["rock5b-nixos.cachix.org-1:bXHDewFS0d8pT90A+/YZan/3SjcyuPZ/QRgRSuhSPnA="];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/f2537a505d45c31fe5d9c27ea9829b6f4c4e6ac5";
    kernel-src = {
      url = "github:samueldr/linux/wip/rock5-bsp-2022-12-06";
      flake = false;
    };
    fan-control = {
      url = "github:pymumu/fan-control-rock5b";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    kernel-src,
    fan-control,
  }: let
    lib = nixpkgs.lib.extend (selfLib: superLib: {
      supportedSystems = selfLib.intersectLists selfLib.systems.flakeExposed [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: selfLib.genAttrs selfLib.supportedSystems (system: f system);
      evalConfig = import "${nixpkgs}/nixos/lib/eval-config.nix";
      buildConfig = hostSystem: config:
        selfLib.evalConfig {
          system = hostSystem;
          modules = [
            config
            ./modules/cross
          ];
        };
    });
  in {
    nixosModules = {
      kernel = {
        imports = [./modules/kernel];
        _module.args = {kernelSrc = kernel-src;};
      };

      fan-control = {pkgs, ...}: {
        imports = [./modules/fan-control];
        nixpkgs.overlays = [
          (_: _: {
            inherit (self.packages.${pkgs.system}) fan-control;
          })
        ];
      };

      rootfs = {
        imports = [./modules/rootfs];
        _module.args = {nixpkgsPath = "${nixpkgs}";};
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
        ];
      };
    };

    packages = lib.forAllSystems (system: {
      rootfs = (lib.buildConfig system self.nixosModules.firstBoot).config.system.build.rootfsImage;
      fan-control = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/fan-control {src = "${fan-control}/src";};
      default = self.packages.${system}.rootfs;
    });
  };
}
