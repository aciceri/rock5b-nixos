{ config, lib, ... }:

{
  options = {
    infra = {
      hostPlatform = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  config = let
    hostPlatform = lib.systems.elaborate config.infra.hostPlatform;
    selectedPlatform = lib.systems.elaborate "aarch64-linux";
    isCross = hostPlatform != selectedPlatform;
  in lib.mkMerge [
    {
      nixpkgs.overlays = [
        (final: super: {
          # Workaround for modules expected by NixOS not being built more often than not.
          makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
    }
    (lib.mkIf isCross {

      # Some filesystems (e.g. zfs) have some trouble with cross (or with BSP kernels?) here.
      boot.supportedFilesystems = lib.mkForce [ "vfat" ];

      nixpkgs.crossSystem =
        builtins.trace ''
          Building with a crossSystem?: ${selectedPlatform.system} != ${hostPlatform.system} → ${if isCross then "we are" else "we're not"}.
                  crossSystem: config: ${selectedPlatform.config}''
        selectedPlatform
      ;
    })
  ];
}
