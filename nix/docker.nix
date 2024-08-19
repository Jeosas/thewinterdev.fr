{
  pkgs,
  website,
}: let
  nginxPort = "8080";
  nginxConf = pkgs.writeText "nginx.conf" ''
    user nobody nobody;
    daemon off;
    error_log /dev/stdout info;
    pid /dev/null;
    events {}
    http {
      include ${pkgs.nginx}/conf/mime.types;
      access_log /dev/stdout;
      server {
        listen ${nginxPort};
        index index.html;
        error_page 404 /404.html;
        location / {
          root ${website}/www/public;
        }
      }
    }
  '';
in
  pkgs.dockerTools.buildLayeredImage {
    name = "thewinterdev-website";
    tag = "latest";
    contents = [
      pkgs.fakeNss
      pkgs.nginx
    ];

    extraCommands = ''
      mkdir -p tmp/nginx_client_body

      # nginx still tries to read this directory even if error_log
      # directive is specifying another file :/
      mkdir -p var/log/nginx
    '';

    config = {
      Cmd = ["nginx" "-c" nginxConf];
      ExposedPorts = {
        "${nginxPort}/tcp" = {};
      };
    };
  }
