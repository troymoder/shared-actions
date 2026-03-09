{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    alejandra,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        formatter = pkgs.writeShellScriptBin "alejandra" ''
          ${alejandra.defaultPackage.${system}}/bin/alejandra --exclude node_modules "$@"
        '';
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            dprint
            just
            shfmt
          ];
        };
      }
    );
}
