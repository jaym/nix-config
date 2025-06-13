{ pkgs, mcp-servers-nix, ... }:
{
  home.packages = with pkgs; [
    (callPackage ./github-mcp-server.nix {})
  ];
}