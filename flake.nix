{
  description = "Classes and instructions for authors of LIPICS papers.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let 
        pkgs = import nixpkgs { inherit system; };
        texlive = pkgs.texliveFull.withPackages (ps: [
          ps.latexmk
          ps.pdflatex
          ps.pgf # TikZ
          pkgs.inkscape
          ps.luatex
        ]);
      in
      {
        packages.devShell = pkgs.stdenv.mkShell {
          nativeBuildInputs = [ 
            pkgs.gnumake
            texlive
          ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "lipics-example";
          src = ./.;
          
          nativeBuildInputs = [ texlive ];

          buildPhase = ''
            export XDG_CACHE_HOME=$(mktemp -d)
            latexmk -pdf --shell-escape lipics-v2021-sample-article.tex
          '';

          installPhase = ''
            mkdir -p $out
            cp paper.pdf $out/
          '';
        };
      });
}