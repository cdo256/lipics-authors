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
        ]);
      in
      {
        devShell.default = pkgs.stdenv.mkShell {
          nativeBuildInputs = [ 
            pkgs.gnumake
            texlive
          ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "lipics";
          pname = "lipics";
          src = ./.;
          
          outputs = [ "out" "tex" ];

          nativeBuildInputs = [ texlive ];

          buildPhase = ''
            export XDG_CACHE_HOME=$(mktemp -d)
            latexmk -pdf --shell-escape lipics-v2021-sample-article.tex
          '';

          installPhase = ''
            # Use /share/texmf-cdo to avoid collsion.
            # Really I only need tex output, but that requires a lot of overloading.
            # See https://github.com/NixOS/nixpkgs/issues/16182.
            mkdir -p $out/share/texmf-cdo/tex/latex/lipics/
            mkdir -p $tex/tex/latex/lipics/
            cp *.pdf *.cls *.sty $out/share/texmf-cdo/tex/latex/lipics/
            cp *.pdf *.cls *.sty $tex/tex/latex/lipics/
          '';
        };
      });
}
