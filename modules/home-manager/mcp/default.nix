{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (callPackage ./github-mcp-server.nix {})
  ];
}