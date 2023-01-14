{
  lib,
  fetchurl,
  fetchFromGitHub,
  src,
  pkgs,
  buildUBoot,
  ...
} @ args:
let
  rock5b_spi_image = ''
    SPI_IMAGE="$out/rock-5b-spi.img"

    dd if=/dev/zero of=$SPI_IMAGE bs=1M count=0 seek=16
    ${pkgs.parted}/bin/parted -s $SPI_IMAGE mklabel gpt
    ${pkgs.parted}/bin/parted -s $SPI_IMAGE unit s mkpart idbloader 64 7167
    ${pkgs.parted}/bin/parted -s $SPI_IMAGE unit s mkpart vnvm 7168 7679
    ${pkgs.parted}/bin/parted -s $SPI_IMAGE unit s mkpart reserved_space 7680 8063
    ${pkgs.parted}/bin/parted -s $SPI_IMAGE unit s mkpart reserved1 8064 8127
    ${pkgs.parted}/bin/parted -s $SPI_IMAGE unit s mkpart uboot_env 8128 8191
    ${pkgs.parted}/bin/parted -s $SPI_IMAGE unit s mkpart reserved2 8192 16383
    ${pkgs.parted}/bin/parted -s $SPI_IMAGE unit s mkpart uboot 16384 32734

    dd if=$out/idbloader.img of=$SPI_IMAGE seek=64 conv=notrunc
    dd if=$out/u-boot.itb of=$SPI_IMAGE seek=16384 conv=notrunc
  '';

  rock5b_uboot = buildUBoot rec {
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "radxa";
      repo = "u-boot";
      rev = "5753b21aa92481ec3191fdf1f4d53274590ac5aa";  # branch: stable-5.10-rock5
      sha256 = "sha256-52OZBfKaWQaq7t/55PXKuQrC8jcOrjb+XW41OTqYKPE=";
    };

    rkbin = fetchFromGitHub {
      owner = "armbian";
      repo = "rkbin";
      rev = "1f2bd43aa12942849ec0f0e7ce26930865076bf3";
      sha256 = "sha256-TvDvLpZmv/Xm1MHwoOwKmH9kGDyK42YSBxSWVSzDlZE=";
    };

    patches = [
      ./000-fix.patch
    ];
    postPatch = ''
      patchShebangs tools
      patchShebangs arch/arm/mach-rockchip
    '';

    extraConfig = ''
      CONFIG_DISABLE_CONSOLE=n
      CONFIG_CMD_NVME=y
      CONFIG_BOOTDELAY=5
      CONFIG_CMD_LOG=y
      CONFIG_LOG=y
      CONFIG_SPL_LOG=n  # won't compile /build/source/common/log.c:141: undefined reference to `vsnprintf'
      CONFIG_LOGLEVEL=7
      CONFIG_LOG_MAX_LEVEL=7
      CONFIG_SPL_LOGLEVEL=7
      CONFIG_SPL_LOG_MAX_LEVEL=7
      CONFIG_LOG_CONSOLE=y
      CONFIG_LOG_TEST=n
      CONFIG_HUSH_PARSER=y
    '';
    extraMeta.platforms = ["aarch64-linux"];

    defconfig = "rock-5b-rk3588_defconfig";
    BL31="${rkbin}/rk35/rk3588_bl31_v1.28.elf";
    extraMakeFlags = [
      "spl/u-boot-spl.bin"
      "u-boot.dtb"
      "u-boot.itb"
    ];

    filesToInstall = [
        "u-boot.itb"
        "idbloader.img"
    ];

    postBuild = ''
       ./tools/mkimage -n rk3588 -T rksd -d ${rkbin}/rk35/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin:spl/u-boot-spl.bin idbloader.img
    '';

    postInstall = rock5b_spi_image;
  };
in rock5b_uboot
