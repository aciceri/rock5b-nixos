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
    inherit src;
    version = "1.0.0";

    rkbin = fetchFromGitHub {
      owner = "armbian";
      repo = "rkbin";
      rev = "1f2bd43aa12942849ec0f0e7ce26930865076bf3";
      sha256 = "sha256-TvDvLpZmv/Xm1MHwoOwKmH9kGDyK42YSBxSWVSzDlZE=";
    };

    radax_spi_loader = fetchurl {
      url = "https://dl.radxa.com/rock5/sw/images/loader/rock-5b/release/rk3588_spl_loader_v1.08.111.bin";
      sha256 = "sha256-pHZbzNJJZ5bmH2Q/PpV/ncWTU/OcP6p1leQ3msCEgN4=";
    };

    patches = [];
    postPatch = ''
      substituteInPlace configs/rock-5b-rk3588_defconfig \
        --replace 'CONFIG_DISABLE_CONSOLE=y' 'CONFIG_DISABLE_CONSOLE=n' \
        --replace 'CONFIG_BAUDRATE=1500000' 'CONFIG_BAUDRATE=1228800'

      patchShebangs tools
      patchShebangs arch/arm/mach-rockchip
    '';
#    extraConfig = ''
#      CONFIG_BAUDRATE=1228800
#      CONFIG_DISABLE_CONSOLE=n
#    '';
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
        "rk3588_spl_loader_v1.08.111.bin"
    ];

    postBuild = ''
       cp ${radax_spi_loader} rk3588_spl_loader_v1.08.111.bin
       ./tools/mkimage -n rk3588 -T rksd -d ${rkbin}/rk35/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin:spl/u-boot-spl.bin idbloader.img
    '';

    postInstall = rock5b_spi_image;
  };
in rock5b_uboot
