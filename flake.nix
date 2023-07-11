{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
  };

  outputs = { self, nixpkgs, devenv, systems, ... }@inputs:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      devShells = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;

            modules = [
              ({ pkgs, ... }: {
                dotenv.enable = true;

                languages.python = {
                  enable = true;
                  version = "3.9.17";
                  poetry.enable = true;
                  poetry.activate.enable = true;
                  poetry.install.enable = true;
                };
              })
            ];
          };
        });
    };
}
