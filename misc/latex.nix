# NixOS module for LaTeX stuff.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (texLiveAggregationFun { paths = [
      texLive
      texLiveExtra
      texLiveBeamer
      tex4ht
    ]; })
    biber
    tex4ht

    # A latexmk alias which runs the command with the -pdf flag.
    # This is used to get emacs's latex-preview-mode to work properly with latexmk.
    (writeScriptBin "pdflatexmk" "latexmk -pdf $@")
  ];
}
