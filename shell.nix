{ pkgs ? import <nixpkgs> {} }:

let
  nodePkgs = import ./nix/default.nix {};
in pkgs.mkShell {
  packages = with pkgs; [
    gnumake
    asciidoctor-with-extensions
    nodePkgs."bytefield-svg-1.10.0"
  ];
}
