{
  lib,
  pkgs,
  config,
  ...
}:

let
  version = "1.0.3";
  pname = "spotify-adblock";

  spotify-adblock = pkgs.rustPlatform.buildRustPackage {
    inherit pname version;
    src = pkgs.fetchFromGitHub {
      owner = "abba23";
      repo = "spotify-adblock";
      rev = "v${version}";
      fetchSubmodules = false;
      sha256 = "sha256-UzpHAHpQx2MlmBNKm2turjeVmgp5zXKWm3nZbEo0mYE=";
    };
    cargoHash = "sha256-oGpe+kBf6kBboyx/YfbQBt1vvjtXd1n2pOH6FNcbF8M=";

    patchPhase = ''
      substituteInPlace src/lib.rs \
        --replace 'config.toml' $out/etc/spotify-adblock/config.toml
    '';

    buildPhase = ''
      make
    '';

    installPhase = ''
      mkdir -p $out/etc/spotify-adblock
      install -D --mode=644 config.toml $out/etc/spotify-adblock
      mkdir -p $out/lib
      install -D --mode=644 --strip target/release/libspotifyadblock.so $out/lib
    '';
  };

  spotifyPatched = pkgs.spotify.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.zip
      pkgs.unzip
    ];
    postInstall = (old.postInstall or "") + ''
      ln -s ${spotify-adblock}/lib/libspotifyadblock.so $libdir
      sed -i "s:^Name=Spotify.*:Name=Spotify-adblock:" "$out/share/spotify/spotify.desktop"
      wrapProgram $out/bin/spotify \
        --set LD_PRELOAD "${spotify-adblock}/lib/libspotifyadblock.so"
    '';
  });
in
{
  options = {
    mynixos.spotify.enable = lib.mkEnableOption "Enable Spotify";
    # This is for educational purposes only. This demonstrates how to override an application.
    mynixos.spotify.adblock.enable = lib.mkEnableOption "Disable ads";
  };

  config = lib.mkIf config.mynixos.spotify.enable {
    environment.systemPackages =
      if config.mynixos.spotify.adblock.enable then [ spotifyPatched ] else [ pkgs.spotify ];

    mynixos.myUnfreePackages = [
      "spotify"
    ];
  };
}
