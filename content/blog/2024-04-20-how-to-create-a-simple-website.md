+++
title = "How to create a simple website using Zola, TailwindCSS and Nix"
description = "I created a blogging/protfolio website in 2 days using a simple stack: Zola, tailwindcss and Nix."
# updated =

[taxonomies]
tags = [ "web", "nix", "zola", "tailwindcss"]

[extra]
hero_file = "how-to-create-a-simple-website.jpg"
hero_caption = "A Vintage Typewriter - Photo by Suzy Hazelwood, source: Pexels"
+++

Well... I created a website.

After years of reading time saving blog posts on many different subjects, from tech to life tips, I decided to give back a bit of this gained time to this community by righting my own.

In this first article, I'm presenting to you how I bootstrapped this beauty.

## Choosing the right blogging tool

There are 2 options to my knowledge that make sens for a blog: 
**Content Management Systems** (CMS) and **Static Site Generators** (SSG).

I decided to use an SSG for the following reasons:
 - simple features tailored to my simple needs,
 - articles are written in markdown which I can edit directly in my editor of choice - *no mandatory online ui*,
 - the whole website (theme, content, static files) is versioned in git - *no need for database backups*,
 - use the front-end framework of your choice or bare html, 
 - it creates static html that can be served as is from your server, *no need for heavy setups with databases, wsgi servers or whatever*. 

Though there are still things to consider when choosing an SSG:
 - you need to be familiar with markdown which *can be harder* than an online editor - *though you could use a local editor I guess*,
 - less documentation, articles and videos than CMS meaning your are mainly by yourself - *even more if you use an exotic SSG like I do*,
 - you are working with source code directly thus you need to recompile the website and deploy it to the server to update the content.

Being a developer and an avid linux user, those drawbacks won't bother me much but they are still important to keep in mind and understand the journey you embark on.

## Choosing my Static Site Generator

When I learned about SSGs, it was when Hugo came out. Then I heard about Astro and its amazing support for front-end frameworks.

Since this was a few years ago, I want to look around what else came out in the mean time. Here is what I compared:

> I do not need nor wish complex features, and since they all provide the same basic features, I rooted out the 'feature' part of the comparison.

| SSG software | Distribution  | Front-end        |
| ------------ | ------------- | ---------------- |
| **Hugo**     | Binary (Go)   | Go templates     |
| **Astro**    | npm package   | Any js framework |
| **Pelican**  | python library| jinja2 templates |
| **Zola**     | Binary (Rust) | Tera templates   |

My criteria were:
 - I'd prefer a simple binary than having to maintain a development environment like with python or javascript,
 - I don't care about js front-end frameworks and plan to use basic html with a touch of tailwindcss for styling,
 - A simple templating engine is all I need, and I prefer the jinja2 simplicity than the Go Templates headaches.

In the end, I settled on Zola, a simple binary that provides Tera templating support, which is based on the jinja2 syntax.

## The Zola Static Site Generator

[Zola](https://getzola.org) is a fairly simple static site generator written in rust that parses markdown files to generate static html pages.
It uses the Tera templating engine and provide off the shelves themes (website templates) that you can directly use to create your website without having to write a line of html.
Styling your html is made easy with the native support of Sass that will be compiled automatically during the generation.
This SSG is simple in appearance, but offers a lot of possibilities if your are willing to compose with its more advanced features.

> This is not an article about using Zola so I'm not gonna talk about templating or content organisation much.
> Please refer to the great documentation on the [Zola website](https://www.getzola.org/documentation/getting-started/overview).

## Creating the website

### Setting up the development environment

I use Nix for all my development needs nowadays and luckily for us it has everything we need ! 
Let's create our devShell using flakes.

```nix
# flake.nix
{
  # ...
  devShells.default = pkgs.mkShell {
    name = "thewindevdev";
    packages = with pkgs; [ tailwindcss zola ];
  };
}
```

Starting our development environment is as simple as...

```bash
$ nix develop
```

We now have all the tools we need installed and available on our machine. Let's initialize Zola.

```sh
$ # Initialize zola
$ zola init
$ # Start our development server
$ zola serve 
```

Our website is now available at `http://127.0.0.1:1111`.

Now I'd like to add [tailwindcss](https://tailwindcss.com), and this is where we go a _little_ off-road.
First let's initialize it.

```sh
$ tailwincss init
```

And edit its configuration file so it works nicely with Zola.

```javascript
// tailwind.config.js
module.exports = {
  content: ['./templates/**/*.html', './content/**/*.md'],
  // ...
}
```

Along with creating our base CSS file as shown in the tailwindcss documentation.

```scss
/* src-styles/main.scss */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

> **But you said CSS, why are you using an SCSS file ?**
>
> The reason is that there are 2 styling parts to consider using Zola:
>  - the template part that you can style using tailwindcss classes as usual,
>  - and the markdown part that is generated and which you need to style 
>    using a css file and targeting the html elements directly.
>
> Using Sass allows me to style those html elements using the same tailwindcss classes
> by using the `@apply` Sass feature.
> And tailwindcss is able to manage Sass when compiling, thus it's a zero-cost solution !

We then need to let tailwindcss know it should compile our CSS assets before Zola can use them 
and run our server again.

```sh
$ tailwindcss -i src-styles/main.scss -o static/style.css
$ zola serve
```

Now our website can be styled using tailwindcss!
But we still need to run the command every time we make changes to our styling.
Tailwind offers a *watch* feature that is perfect for this !

Because running wild background jobs isn't *the way* 
and because I'm *to lazy* to type this long command every time I work on this website,
I'm gonna create a small bash script that does all this for me. And it can even be created easily with Nix !

```nix
# flake.nix
{
  # ...
  devShells.default = let
    serve = pkgs.writeShellApplication {
      name = "serve";
      runtimeInputs = with pkgs; [ tailwindcss zola ];

      text = ''
        tailwindcss -i src-styles/main.scss -o static/style.css --watch=always &
        zola serve
      '';
    };
  in pkgs.mkShell {
    name = "thewindevdev";
    packages = [ serve ];
  };
}
```

Now after entering our development shell with `nix develop`, all we need to do is run `serve` and we are good to go ! And even faster:

```bash
$ nix develop -c serve
```

> Note that the *tailwindcss* and *zola* binaries will not be available anymore in the development shell.
> If you still need them, you can add them back to the shell **packages** list.
>
> Though you should have no need for them from now on.

### Building the website

Being now satisfied with the looks of our creation, it is time to build the production version. Luckily it's pretty similar to our `serve` command.

```sh
$ tailwindcss -i src-styles/main.scss -o static/style.css --minify
$ zola build
```

But having to type and run these command every deployment is cumbersome...

You know it, we can make a Nix derivation out of this !

```nix
# flake.nix
{
  # ...
  packages.default = pkgs.stdenv.mkDerivation {
    name = "thewinterdev-fr";
    src = ./.;
    buildInputs = with pkgs; [ tailwindcss zola ];
    buildPhase = ''
      tailwindcss -i src-styles/main.scss -o static/style.css --minify
      zola build
    '';
    installPhase = ''
      mkdir -p $out/www
      cp -R public $out/www
    '';
  };
}
```

Now we can build our website using:

```bash
$ nix build
```

This will compile our files and make the whole static website available in the `./result` folder.

## Conclusion

This is it! How to setup a simple blog website using **Zola**, **TailwindCSS** and **Nix**.

If you are curious about how all this came together, sources of this website can be found on [GitHub](https://github.com/Jeosas/thewinterdev.fr).

See you in the next article where I'll show you how to deploy this website on a simple RaspberryPi using NixOS and the package we just created.
