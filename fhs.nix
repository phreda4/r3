{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  customSteamRun = pkgs.steam-run.override {
    extraLibraries = pkgs: with pkgs; [
      SDL2
      SDL2_image
      SDL2_ttf
      SDL2_mixer
    ];
  };
in
pkgs.mkShell {
  buildInputs = [ customSteamRun ];
  shellHook = ''
    exec steam-run ./r3lin "$@"
  '';
}