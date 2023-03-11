{pkgs, ...}: {
  hardware = {
    firmware = [
      ((
          pkgs.runCommandNoCC
          "mali_csffw.bin"
          {}
          "mkdir -p $out/lib/firmware && cp ${./mali_csffw.bin} $out/lib/firmware/mali_csffw.bin"
        )
        // {
          compressFirmware = false; # TODO can I re-enable compression?
        })
    ];

    opengl.extraPackages = with pkgs; [
      # TODO are these needed?
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  services.udev.extraRules = ''
    KERNEL=="mpp_service", MODE="0660", GROUP="video"
    KERNEL=="rga", MODE="0660", GROUP="video"
    KERNEL=="system-dma32", MODE="0666", GROUP="video"
    KERNEL=="system-uncached-dma32", MODE="0666", GROUP="video" RUN+="${pkgs.busybox}/bin/chmod a+rw /dev/dma_heap"
  '';
}
