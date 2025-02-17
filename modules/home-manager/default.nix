{
  config,
  pkgs,
  lib,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  flakeDir = "${homeDir}/nix-config";
  dotsDir = "${flakeDir}/dotfiles";
  mkConfigSym = relPath: config.lib.file.mkOutOfStoreSymlink "${dotsDir}/${relPath}";
in
{
  home.username = "jaym";
  home.homeDirectory = lib.mkForce "/Users/jaym";

  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    curl
    devenv
    fd
    htop
    less
    nixfmt-rfc-style
    ripgrep
    rclone
  ];
  home.sessionVariables = {
    PAGER = "less";
    CLICLOLOR = 1;
    EDITOR = "nvim";
    GOPATH = "$HOME/go";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global = {
      load_dotenv = true;
    };
  };

  programs.bat = {
    enable = true;
    config.theme = "TwoDark";
  };

  programs.fzf = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    icons = "auto";
  };

  programs.git = {
    enable = true;
    userName = "Jay Mundrawala";
    userEmail = "jay@thechamberofunderstanding.com";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
    };
    shellAliases = {
      vim = "nvim";
      nixswitch = "darwin-rebuild switch --flake ~/nix-config/.#";
      nixup = "pushd ~/nix-config; nix flake update; nixswitch; popd";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      golang.go
      mkhl.direnv
      jnoortheen.nix-ide
    ];
  };

  home.file = {
    ".aerospace.toml".source = ../../dotfiles/aerospace.toml;
  };

  xdg.configFile."ghostty/config".source = ../../dotfiles/ghostty/config;
  xdg.configFile."karabiner/karabiner.homemanager.json" = {
    source = ../../dotfiles/karabiner/karabiner.json;
    onChange = ''
      rm -f ${config.xdg.configHome}/karabiner/karabiner.json
      cp ${config.xdg.configHome}/karabiner/karabiner.homemanager.json ${config.xdg.configHome}/karabiner/karabiner.json
      chmod u+w ${config.xdg.configHome}/karabiner/karabiner.json
    '';
  };

  xdg.configFile."${homeDir}/Library/Application Support/Code/User/keybindings.json".source =
    mkConfigSym "vscode/keybindings.json";
}
