{ pkgs }:

pkgs.writeShellApplication {
  name = "cv";
  runtimeInputs = with pkgs; [ 
    yq-go
    tera-cli
    (texliveBasic.withPackages (ps: with ps; [ 
      xetex
      etoolbox datetime pgf fmtcount enumitem ragged2e xifthen tikzfill
      xstring setspace unicode-math tcolorbox parskip ifmtarg environ
      roboto sourcesanspro fontawesome5 fontspec xkeyval 
    ]))
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
}

