{
  inputs,
  ...
}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];
  perSystem = {pkgs, ...}: {
    treefmt.config = {
      projectRootFile = ".git/config";
      programs.alejandra.enable = true;
    };
    packages.formatter = pkgs.alejandra;
  };
}
