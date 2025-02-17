{ pkgs, config, ... }:
{
  system.stateVersion = 4;

  programs.zsh.enable = true;
  environment.shells = [
    pkgs.bash
    pkgs.zsh
  ];
  environment.systemPackages = [
    pkgs.coreutils
    pkgs.neovim
    pkgs.trippy
  ];
  environment.extraInit = ''
    eval $(/opt/homebrew/bin/brew shellenv)
  '';

  nix.settings.trusted-users = [ "jaym" ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  services.nix-daemon.enable = true;

  system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
  system.defaults.NSGlobalDomain.KeyRepeat = 1;

  # Enable sudo authentication with Touch ID
  security.pam.enableSudoTouchIdAuth = true;

  system.defaults.dock.autohide = true;
  system.defaults.dock.expose-group-apps = true;
  system.defaults.dock.orientation = "bottom";
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder.ShowStatusBar = true;

  system.defaults.NSGlobalDomain._HIHideMenuBar = false;

  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = { };
    brews = [
    ];
    casks = [
      "aerospace"
      "ghostty"
      "karabiner-elements"
      "podman-desktop"
      "raycast"
      "vlc"
      "yubico-authenticator"
    ];
    taps = [ "nikitabobko/tap" ];
    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
  };
}
