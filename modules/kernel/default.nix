{
  config,
  lib,
  pkgs,
  kernelSrc,
  ...
}: {
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rock5;
  boot.kernelParams = lib.mkAfter [
    "console=ttyFIQ0,115200n8"
    "console=ttyS2,115200n8"
    "earlycon=uart8250,mmio32,0xfeb50000"
    "earlyprintk"
  ];
  nixpkgs.overlays = [
    (self: super: {
      linuxPackages_rock5 = self.linuxPackagesFor self.linux_rock5;
      linux_rock5 = super.callPackage ./kernel.nix {
        inherit kernelSrc;
        kernelPatches = [
          self.kernelPatches.bridge_stp_helper
          self.kernelPatches.request_key_helper
        ] ++ builtins.map (patch: { inherit patch; }) [
          ./0001-Ignore-implementation-defects-warned-by-newer-GCC.patch
          ./0002-rk630phy-Fix-implementation.patch
          ./0003-usb-gadget-legacy-webcam-Fix-implementation.patch
        ];
      };
    })
  ];
}
