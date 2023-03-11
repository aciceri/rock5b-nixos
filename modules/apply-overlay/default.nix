{
  config,
  lib,
  rock5bFlake,
  ...
}: let
  inherit (config.nixpkgs) localSystem;
  selectedPlatform = lib.systems.elaborate "aarch64-linux";
  isCross = localSystem != selectedPlatform.system;
  dynamicOverlay =
    if isCross
    then
      (self: super: {
        inherit
          (rock5bFlake.packages.${localSystem.system})
          mesa
          kodi-rock5b
          fan-control-rock5b
          linux-rock5b
          ;
      })
    else rock5bFlake.overlays.default;
in {
  nixpkgs.overlays = [
    dynamicOverlay
  ];
}
