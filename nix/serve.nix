{ pkgs }:

pkgs.writeShellApplication {
  name = "serve";
  runtimeInputs = with pkgs; [ tailwindcss zola ];

  text = ''
    tailwindcss -i src-styles/main.scss -o static/style.css --watch=always &
    zola serve
  '';
}
