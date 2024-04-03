{
  description = "Jeosas' personal website.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/main";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      serve = pkgs.writeShellApplication {
        name = "serve";
        runtimeInputs = with pkgs; [ tailwindcss zola ];

        text = ''
          tailwindcss -i src-styles/main.scss -o static/style.css --watch=always &
          zola serve
        '';
      };
    in 
    {
      apps.serve = {type="app"; program="${serve}/bin/serve";};
    }
  );
}
