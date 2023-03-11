{
  lib,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    (self: _: {
      linuxPackages-rock5b = self.linuxPackagesFor self.linux-rock5b;
    })
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages-rock5b;
    kernelParams = lib.mkAfter [
      "console=ttyFIQ0,115200n8"
      "console=ttyS2,115200n8"
      "earlycon=uart8250,mmio32,0xfeb50000"
      "earlyprintk"
    ];
    initrd.availableKernelModules = lib.mkForce ["usbhid" "md_mod" "raid0" "raid1" "raid10" "raid456" "ext2" "ext4" "sd_mod" "sr_mod" "mmc_block" "uhci_hcd" "ehci_hcd" "ehci_pci" "ohci_hcd" "ohci_pci" "xhci_hcd" "xhci_pci" "usbhid" "hid_generic" "hid_lenovo" "hid_apple" "hid_roccat" "hid_logitech_hidpp" "hid_logitech_dj" "hid_microsoft" "hid_cherry"];
    # blacklistedKernelModules = [ "sata_nv" ];
  };
}
