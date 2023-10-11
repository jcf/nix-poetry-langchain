{
  inputs = {
    # Because devenv doesn't give you reproducible builds without the Python rewrite.
    #
    # https://github.com/cachix/devenv/pull/745
    devenv.url = "github:cachix/devenv/python-rewrite";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    systems.url = "github:nix-systems/default";
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
