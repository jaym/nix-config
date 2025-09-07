{
  lib,
  writeShellScriptBin,
  claude-code,
}:
writeShellScriptBin "claude" ''
  exec ${lib.getExe claude-code} --mcp-config ~/.config/claude/servers.json "$@"
''
