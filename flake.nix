{
  description = "Opinionated NixOS modules and building infrastructure for Radxa Rock5B";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/f2537a505d45c31fe5d9c27ea9829b6f4c4e6ac5";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    kernel-src = {
      url = "github:radxa/kernel";
      flake = false;
    };
    tow-boot = {
      url = "github:aciceri/Tow-Boot/rock5b";
      flake = false;
    };
    fan-control = {
      url = "github:pymumu/fan-control-rock5b";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ...}: flake-parts.lib.mkFlake {inherit inputs;} {
    imports = [
      ./modules
      ./packages
      ./apps
      ./formatting
    ];
    systems = [ "x86_64-linux" "aarch64-linux" ];
  };

  nixConfig = {
    extra-substituters = ["https://rock5b-nixos.cachix.org"];
    extra-trusted-public-keys = ["rock5b-nixos.cachix.org-1:bXHDewFS0d8pT90A+/YZan/3SjcyuPZ/QRgRSuhSPnA="];
  };
}
