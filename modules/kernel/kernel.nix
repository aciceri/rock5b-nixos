{
  lib,
  fetchFromGitHub,
  buildLinux,
  kernelSrc,
  ...
} @ args: let
  kernelVersion = "5.10.110";
  vendorVersion = "";
  version = "${kernelVersion}${vendorVersion}";
in
  buildLinux (args
    // {
      inherit version;

      # https://github.com/radxa/build/blob/428769f2ab689de27927af4bc8e7a9941677c366/board_configs.sh#L304
      defconfig = "rockchip_linux_defconfig";

      # branchVersion needs to be x.y
      extraMeta.branch = lib.versions.majorMinor version;
      # NOTE: The NixOS infra automatically enables all unspecified modules as `=m`.
      #       This is why there's a lot of crap to disable.
      structuredExtraConfig = with lib.kernel; {
        # Not needed, and implementation iffy / does not build / used for testing
        MALI_KUTF = no;
        MALI_IRQ_LATENCY = no;
        # Build fails, "legacy/webcam.c" we don't need no legacy stuff.
        USB_G_WEBCAM = no;
        # Poor quality drivers, bad implementation, not needed
        WL_ROCKCHIP = no; # A lot of badness
        RK628_EFUSE = no; # Not needed, used to "dump specified values"
        # Used on other rockchip platforms
        ROCKCHIP_DVBM = no;
        RK_FLASH = no;
        PCIEASPM_EXT = no;
        ROCKCHIP_IOMUX = no;
        RSI_91X = no;
        RSI_SDIO = no;
        RSI_USB = no;

        # Driver conflicts with the mainline ones
        # > error: the following would cause module name conflict:
        COMPASS_AK8975 = no;
        LS_CM3232 = no;
        GS_DMT10 = no;
        GS_KXTJ9 = no;
        GS_MC3230 = no;
        GS_MMA7660 = no;
        GS_MMA8452 = no;

        # This is not a good console...
        # FIQ_DEBUGGER = no;
        # TODO: Fix 8250 console not binding as a console

        # from vendor config
        #DRM_DP = no; # ????? does not build with it disabled ffs
        DRM_DEBUG_SELFTEST = no;

        # Ugh...
        ROCKCHIP_DEBUG = no;
        RK_CONSOLE_THREAD = no;
      };

      src = kernelSrc;
    }
    // (args.argsOverride or {}))
