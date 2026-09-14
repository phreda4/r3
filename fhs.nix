{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
  name = "r3-env";
  targetPkgs = pkgs: with pkgs; [
    SDL2
    SDL2_image
    SDL2_ttf
    SDL2_mixer
  ];
}).env