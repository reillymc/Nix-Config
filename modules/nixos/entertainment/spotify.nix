{
  config,
  lib,
  pkgs,
  ...
}:

let
  spotifyAdblock = pkgs.rustPlatform.buildRustPackage rec {
    pname = "spotify-adblock";
    version = "1.0.3";
    src = pkgs.fetchFromGitHub {
      owner = "abba23";
      repo = "spotify-adblock";
      rev = "v${version}";
      sha256 = "sha256-UzpHAHpQx2MlmBNKm2turjeVmgp5zXKWm3nZbEo0mYE=";
    };
    cargoHash = "sha256-oGpe+kBf6kBboyx/YfbQBt1vvjtXd1n2pOH6FNcbF8M=";
  };

  spotifyWithAdblock = pkgs.writeShellScriptBin "spotify-adblock" ''
    exec env LD_PRELOAD=${spotifyAdblock}/lib/libspotifyadblock.so ${pkgs.spotify}/bin/spotify
  '';

  desktopEntry = pkgs.makeDesktopItem {
    name = "spotify-adblock";
    desktopName = "Spotify (Adblock)";
    exec = "${spotifyWithAdblock}/bin/spotify-adblock";
    icon = "spotify-client";
    categories = [
      "Audio"
      "Music"
      "Player"
    ];
    comment = "Spotify with adblock enabled";
    terminal = false;
  };
in
{
  options = {
    mynixos.spotify.enable = lib.mkEnableOption "Enable Spotify";
    # This is for educational purposes only. This demonstrates how to override an application.
    mynixos.spotify.adblock.enable = lib.mkEnableOption "Disable ads";
  };

  config = lib.mkIf config.mynixos.spotify.enable {
    environment.systemPackages =
      with pkgs;
      [
        spotify
      ]
      ++ lib.optionals config.mynixos.spotify.adblock.enable [
        spotifyAdblock
        desktopEntry
      ];
  };
}
