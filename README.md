# thewinterdev.fr

[![Website](httpr://img.shields.io/website?url=https%3A%2F%2Fthewinterdev.fr&up_message=online&down_message=offline)](https://thewinterdev.fr)

My personal/portfolio website.

This website is build using the [Zola](https://www.getzola.org) Static Site Generator, and styled using [Tailwind CSS](https://tailwindcss.com). More information in the *coming* [blog article](#).

## Developing

> Assuming nix is already setup on your machine.

```console
$ nix run .#serve
```

## Building

> Coming

## Notes

### Create favicon

> Require `imagemagick`

```console
$ convert -background transparent -define 'icon:auto-resize=16,24,32,64' [INPUT] favicon.ico
```
