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
  };

  outputs = {
    self,
    nixpkgs,
    kernel-src,
  }: let
    lib = nixpkgs.lib.extend (superLib: selfLib: {
      forAllSystems = f: selfLib.genAttrs selfLib.systems.flakeExposed (system: f system);
      evalConfig = import "${nixpkgs}/nixos/lib/eval-config.nix";
      buildConfig = hostSystem: config:
        superLib.evalConfig {
          system = "aarch64-linux";
          modules = [
            config
            ./modules/kernel/cross.nix
            { infra.hostPlatform = hostSystem; }
          ];
        };
    });
  in {
    nixosModules = {
      kernel = {
        imports = [./modules/kernel/default.nix];
        _module.args = {kernelSrc = kernel-src;};
      };

      rootfs = {
        imports = [./modules/rootfs/default.nix];
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
      default = self.packages.${system}.rootfs;
    });
  };
}
