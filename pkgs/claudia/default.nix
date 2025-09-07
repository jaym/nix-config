{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  webkitgtk_4_1,
  openssl,
  glib-networking,
  gtk3,
  wrapGAppsHook3,
  bun,
  cargo,
  perl,
  nodejs,
  nodePackages,
}:
let
  pname = "claudia";
  version = "0.1.0";
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "getAsterisk";
    repo = "claudia";
    rev = "v0.1.0";
    #sha256 = "0r7wk6dkl98ip6ismr9qn9ng71cqlabsqagw4qk8dqayfamc8fhw";
    sha256 = "j0i31VPlmFfNpQIlRDwTCfzeNL5pol+tmAmQVO+xfiY=";
  };

  cargoHash = "sha256-kptlN7zKnU9952mbDXW/8Pqv8+lXRhx+3utUTb/e8fY=";

  # The Cargo.lock is in src-tauri directory
  sourceRoot = "source/src-tauri";

  env = {
    # Get openssl-sys to use pkg-config
    OPENSSL_NO_VENDOR = 1;
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    bun
    cargo
    openssl.dev
    perl
    nodejs
    nodePackages.npm
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    webkitgtk_4_1
    openssl
    glib-networking
    gtk3
  ];

  # Build frontend and prepare Claude Code binary
  preBuild = ''
    # Create a stub binary to satisfy the build requirement
    mkdir -p binaries
    echo '#!/bin/sh' > binaries/claude-code-x86_64-unknown-linux-gnu
    echo 'echo "Claude Code CLI stub - install real binary separately"' >> binaries/claude-code-x86_64-unknown-linux-gnu
    chmod +x binaries/claude-code-x86_64-unknown-linux-gnu

    cd ..

    # Install dependencies
    bun install --frozen-lockfile

    # Build frontend
    bun run build
    cd src-tauri
  '';

  # Use regular cargo build instead of tauri build
  buildPhase = ''
    cargo build --release
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp target/release/claudia $out/bin/
  '';

  meta = with lib; {
    description = "Claude desktop app built with Tauri";
    homepage = "https://github.com/getAsterisk/claudia";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
