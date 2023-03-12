{
  pkgs,
  rootfs,
  uboot,
  ...
}:
pkgs.writeShellApplication {
  name = "flash";
  text =
    ''
      TOW_BOOT=${uboot}/shared.disk-image.img
      ROOTFS_ZST=${rootfs}
    ''
    + builtins.readFile ./flash.sh;
  runtimeInputs = with pkgs; [
    coreutils
    zstd
  ];
}
