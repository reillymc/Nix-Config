{
  lib,
  config,
  pkgs,
  ...
}:
let
  base = import ../base.nix { inherit lib config pkgs; };
in
base.mkWebAppModule {
  id = "jellyfin";
  name = "Jellyfin";
  url = "https://jellyfin.homelab.reillymc.com/web";
  # Tampermonkey is force-installed so the video zoom userscript
  # (apps/jellyfin.md) can be pasted into its dashboard once; it then
  # persists via the pinned-UUID profile storage.
  addons = [
    {
      id = "firefox@tampermonkey.net";
      slug = "tampermonkey";
    }
  ];
}
