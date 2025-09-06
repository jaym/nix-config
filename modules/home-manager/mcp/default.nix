{ pkgs, inputs, ... }:
let
  github-mcp-server = (pkgs.callPackage ./github-mcp-server.nix { });
  claude-code = (pkgs.callPackage ./claude-code.nix { });
  mcp-servers-config = inputs.mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      fetch.enable = false;
      playwright.enable = true;
      context7.enable = true;
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
      hcp-terraform = {
        command = "docker";
        args = [
          "run"
          "-i"
          "--rm"
          "hashicorp/terraform-mcp-server:0.1.0"
        ];
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
    enable = stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isDarwin;
    # claude --mcp-config ~/.config/claude/servers.json
    source = mcp-servers-config;
  };
}
