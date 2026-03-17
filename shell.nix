{
  pkgs ? import (if builtins ? getFlake then (builtins.getFlake "nixpkgs") else <nixpkgs>) { },
}:
let
  fonts = pkgs.symlinkJoin {
    name = "fonts";
    paths = with pkgs; [
      culmus
      liberation_ttf
    ];
  };

  openuPackages = pkgs.stdenvNoCC.mkDerivation (final: {
    pname = "latex-openu-packages";
    version = "0.0.1";

    outputs = [ "tex" ];
    passthru.tlDeps = with pkgs.texlive; [
      iftex
      luatex
      babel
      parskip
      amsmath
      cancel
      witharrows
      # centernot
      ulem
      unicode-math
      mathtools
      lualatex-math
      enumitem
      pgfplots
      hyperref
      physics
      xfrac
      systeme
      caption
      algorithms
      clrscode
    ];

    src = ./pkgs;

    nativeBuildInputs = [
      (pkgs.writeShellScript "force-tex-output.sh" ''
        out="''${tex-}"
      '')
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      path="$tex/tex/latex/openu"
      mkdir -p "$path"
      cp *.{cls,def,clo,sty} "$path/"

      runHook postInstall
    '';

    meta.platforms = pkgs.lib.platforms.all;
    passthru.pkgs = [ final.finalPackage ];
  });

  # fcConfig = makeFontsConf { fontDirectories = fonts; };
  # fcCache = makeFontsCache { fontDirectories = fonts; };
in
with pkgs;
mkShellNoCC {
  packages = [
    (texliveMedium.withPackages (
      ps: with ps; [
        # Text
        ulem
        wrapfig
        hyperref
        capt-of
        booktabs
        marginnote
        titling
        enumitem
        csquotes

        # Formats
        dvisvgm
        dvipng

        # Math
        amsmath
        mathtools
        cancel
        pgfplots
        tkz-euclide
        witharrows
        tikz-cd
        stix2-otf
        physics

        # Misc
        latexmk
        tagpdf
        varwidth

        # My packages
        openuPackages
      ]
    ))
  ];

  shellHook = ''
    export OSFONTDIR=${fonts}/share/fonts
    # fc-cache -r
  '';
}
