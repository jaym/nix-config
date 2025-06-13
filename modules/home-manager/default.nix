{
  config,
  pkgs,
  lib,
  mcp-servers-nix,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  flakeDir = "${homeDir}/nix-config";
  dotsDir = "${flakeDir}/dotfiles";
  mkConfigSym = relPath: config.lib.file.mkOutOfStoreSymlink "${dotsDir}/${relPath}";
in
{
  imports = [
    ./mcp
  ];

  home.username = "jaym";
  home.homeDirectory = 
    if pkgs.stdenv.isDarwin 
    then "/Users/jaym" 
    else "/home/jaym";

  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    curl
    devenv
    fd
    gh
    htop
    less
    nixd
    nixfmt-rfc-style
    ripgrep
    rclone
    terraform
  ];
  home.sessionVariables = {
    PAGER = "less";
    CLICLOLOR = 1;
    EDITOR = "nvim";
    GOPATH = "$HOME/go";
    CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
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
      nixswitch = if pkgs.stdenv.isDarwin 
        then "darwin-rebuild switch --flake ~/nix-config/.#"
        else "nix run home-manager -- switch --flake .";
      nixup = "pushd ~/nix-config; nix flake update; nixswitch; popd";
      ag = "rg";
    };
    initExtra = ''
      bindkey '^A' beginning-of-line # Move back word in lin
      bindkey '^E' end-of-line # Move next word in line

      export GOPATH="$HOME/workspace/godev"
      export PATH=$HOME/.cargo/bin:$GOPATH/bin:$HOME/.mix/escripts/:$HOME/.local/bin:$PATH
    '';
  };

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    keys = [ "id_ed25519" ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      search_mode = "fulltext";
      style = "compact";
    };
    flags = [ "--disable-up-arrow" ];
  };

  home.file = lib.mkIf pkgs.stdenv.isDarwin {
    ".aerospace.toml".source = ../../dotfiles/aerospace.toml;
  };

  xdg.configFile = {
    "ghostty/config".source = ../../dotfiles/ghostty/config;
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    "karabiner/karabiner.homemanager.json" = {
      source = ../../dotfiles/karabiner/karabiner.json;
      onChange = ''
        rm -f ${config.xdg.configHome}/karabiner/karabiner.json
        cp ${config.xdg.configHome}/karabiner/karabiner.homemanager.json ${config.xdg.configHome}/karabiner/karabiner.json
        chmod u+w ${config.xdg.configHome}/karabiner/karabiner.json
      '';
    };
    "${homeDir}/Library/Application Support/Code/User/keybindings.json".source =
      mkConfigSym "vscode/keybindings.json";
  };
}
