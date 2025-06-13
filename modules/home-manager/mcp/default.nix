{ pkgs, inputs, ... }:
let
  github-mcp-server = (pkgs.callPackage ./github-mcp-server.nix { });
  claude-code = (pkgs.callPackage ./claude-code.nix { });
  mcp-servers-config = inputs.mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      fetch.enable = true;
      playwright.enable = true;
    };

    settings.servers = {
      github = with pkgs; {
        command = "${lib.getExe github-mcp-server}";
        args = [ ];
      };
      nixos = with pkgs; {
        command = "${lib.getExe mcp-nixos}";
        args = [ ];
      };
    };
  };
  inherit (pkgs) stdenv;
in
{
  home.packages = with pkgs; [
    claude-code
  ];
  xdg.configFile."claude/servers.json" = {
    enable = stdenv.hostPlatform.isLinux;
    # claude --mcp-config ~/.config/claude/servers.json
    source = mcp-servers-config;
  };
}
