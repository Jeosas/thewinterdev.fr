{
  description = "Jeosas' personal website.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils/main";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        serve = pkgs.writeShellApplication {
          name = "serve";
          runtimeInputs = with pkgs; [
            tailwindcss
            zola
          ];

          text =
            #bash
            ''
              trap 'kill -9 $twpid | true; exit' EXIT
              tailwindcss -i src-styles/main.scss -o static/style.css --watch=always &
              twpid=$!

              zola serve
            '';
        };
        cv = pkgs.writeShellApplication {
          name = "cv";
          runtimeInputs = with pkgs; [
            yq-go
            tera-cli
            (texliveBasic.withPackages (
              ps: with ps; [
                xetex
                etoolbox
                datetime
                pgf
                fmtcount
                enumitem
                ragged2e
                xifthen
                tikzfill
                xstring
                setspace
                unicode-math
                tcolorbox
                parskip
                ifmtarg
                environ
                roboto
                sourcesanspro
                fontawesome5
                fontspec
                xkeyval
              ]
            ))
          ];

          text = ''
            BUILD_DIR=build
            rm -r $BUILD_DIR || true
            mkdir $BUILD_DIR

            EN_DIR="$BUILD_DIR/en" 
            mkdir "$EN_DIR"
            cp cv/pp.jpeg "$EN_DIR/pp.jpeg"
            cp cv/awesome-cv.cls "$EN_DIR/awesome-cv.cls"
            tera -t cv/cv.tpl.tex -o "$EN_DIR/cv.tex" data/cv.yml
            cd $EN_DIR && xelatex cv.tex 

            cd ../..

            FR_DIR="$BUILD_DIR/fr" 
            mkdir "$FR_DIR"
            cp cv/pp.jpeg "$FR_DIR/pp.jpeg"
            cp cv/awesome-cv.cls "$FR_DIR/awesome-cv.cls"
            yq eval-all -o=j -I=0 ". as \$item ireduce ({}; . *d \$item )" data/cv.yml data/cv-fr.yml \
              | tera -t cv/cv.tpl.tex -o "$FR_DIR/cv.tex" --stdin
            cd $FR_DIR && xelatex cv.tex 
          '';
        };
      in
      {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            name = "thewinterdev-fr";
            src = ./.;
            buildInputs = with pkgs; [
              cv
              tailwindcss
              zola
            ];
            buildPhase = ''
              tailwindcss -i src-styles/main.scss -o static/style.css --minify
              zola build
              cv
            '';
            installPhase = ''
              mkdir -p "$out/www"
              cp -R public "$out/www"
              cp build/en/cv.pdf "$out/www/public/cv-jeanbaptiste-wintergerst-en.pdf"
              cp build/fr/cv.pdf "$out/www/public/cv-jeanbaptiste-wintergerst-fr.pdf"
            '';
          };
          docker-image = import ./nix/docker.nix {
            inherit pkgs;
            website = self.packages.${system}.default;
          };
        };

        devShells.default = pkgs.mkShell {
          name = "thewindevdev";
          packages = [
            serve
            cv
          ];
        };
      }
    );
}
