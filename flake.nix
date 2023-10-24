{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
  let
    systems = (with flake-utils.lib.system; [
      aarch64-linux
      x86_64-linux
    ]);
  in {
    overlays = {
      default = (final: prev: {
        swayimg = prev.swayimg.overrideAttrs(prev: {
          src = ./.;
          buildInputs = prev.buildInputs ++ (with final; [
            wlr-protocols
            openexr_3
          ]);
        });
      });
    };
  } // flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };
      in rec {
        packages = rec {
          swayimg = pkgs.swayimg;
          default = swayimg;
        };

        devShells = {
          default = pkgs.mkShell {
            inherit (packages.swayimg) nativeBuildInputs buildInputs;
          };
        };
      }
    );
}
