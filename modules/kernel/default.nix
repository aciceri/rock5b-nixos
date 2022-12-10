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
          ./0000-Set-RK3588-FIQ-at-115200-bauds.patch
          ./0001-Ignore-implementation-defects-warned-by-newer-GCC.patch
          ./0002-rk630phy-Fix-implementation.patch
          ./0003-usb-gadget-legacy-webcam-Fix-implementation.patch
          ./0004-revert-commit-f7382476af9d5e3d94bacc769bbf23d5fafd5cdb.patch
          ./0005-arm64-dts-rk3588-rock-5b-Use-serial-instead-of-FIQ.patch
          ./0006-arm64-boot-dts-rk3588-rock-5b-Enable-sfc-and-SPI-Flash.patch
          ./0007-rock-5b-Configure-FIQ-debugger-as-115200.patch
          ./0008-rock-5b-disable-uart2-wont-bind-as-a-console.patch
        ];
      };
    })
  ];
}
