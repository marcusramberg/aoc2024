{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ pkgs.git ];

  # https://devenv.sh/languages/
  languages.zig = {
    enable = true;
    package = pkgs.zig_0_13.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./zig-asahi.patch
      ];
    });
  };
}
