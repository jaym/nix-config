{
  lib,
  writeShellApplication,
  claude-code,
}:
writeShellApplication {
  name = "claude";
  runtimeInputs = [
    claude-code
  ];
  inheritPath = false;
  text = ''
    exec claude --mcp-config ~/.config/claude/servers.json "$@"
  '';
  meta = {
    inherit (claude-code.meta) description homepage;
    platforms = lib.platforms.all;
  };
}
