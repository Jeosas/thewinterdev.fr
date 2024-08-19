{
  description = "Jeosas' personal website.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/main";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        serve = import ./nix/serve.nix {inherit pkgs;};
        cv = import ./nix/cv.nix {inherit pkgs;};
      in {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            name = "thewinterdev-fr";
            src = ./.;
            buildInputs = with pkgs; [cv tailwindcss zola];
            buildPhase = ''
              tailwindcss -i src-styles/main.scss -o static/style.css --minify
              zola build
              cv
            '';
            installPhase = ''
              mkdir -p $out/www
              cp -R public $out/www
              cp build/en/cv.pdf $out/www/public/cv-jeanbaptiste-wintergerst-en.pdf
              cp build/fr/cv.pdf $out/www/public/cv-jeanbaptiste-wintergerst-fr.pdf
            '';
          };
          docker-image = import ./nix/docker.nix {
            inherit pkgs;
            website = self.packages.${system}.default;
          };
        };

        devShells.default = pkgs.mkShell {
          name = "thewindevdev";
          packages = [serve cv];
        };
      }
    );
}
