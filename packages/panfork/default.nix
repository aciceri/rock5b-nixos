{
  src,
  mesa,
  ...
}:
(mesa.override {
  enableOSMesa = false;
  vulkanDrivers = [];
  vulkanLayers = [];
  galliumDrivers = ["panfrost"];
})
.overrideAttrs (old: {
  inherit src;
  name = "mesa-panfork";
  mesonFlags = old.mesonFlags ++ ["-Dllvm=disabled"];
})
