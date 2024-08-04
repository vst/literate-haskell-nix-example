{ pkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05") { }
, ...
}:

let
  ## Our ghc:
  ghc = pkgs.haskellPackages.ghcWithPackages (pkgs: [
    pkgs.doctest
    pkgs.markdown-unlit
    pkgs.unordered-containers
  ]);
in
## Build and export the shell:
pkgs.mkShell {
  ## Our build inputs:
  buildInputs = [
    ## Haskell input:
    ghc

    ## Further development dependencies:
    pkgs.marksman
    pkgs.nil
    pkgs.nixpkgs-fmt
    pkgs.nodePackages.prettier
  ];

  ## Our environment variables which are used by the Haskell
  ## build tools, especially `doctest` in our case:
  NIX_GHC = "${ghc}/bin/ghc";
  NIX_GHCPKG = "${ghc}/bin/ghc-pkg";
  NIX_GHC_DOCDIR = "${ghc}/share/doc/ghc/html";
  NIX_GHC_LIBDIR = "${ghc}/lib/ghc-9.6.5/lib";
}
