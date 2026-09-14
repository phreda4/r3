{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    gcc
    gnumake
  ];

  # Equivalente a libsdl2-dev, libsdl2-ttf-dev, etc.
  buildInputs = with pkgs; [
    SDL2
    SDL2_ttf
    SDL2_image
    SDL2_mixer
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (with pkgs; [
      SDL2
      SDL2_ttf
      SDL2_image
      SDL2_mixer
    ])}:$LD_LIBRARY_PATH"
  '';
}