{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.mynixos.nautilus.enable = lib.mkEnableOption "Nautilus";

  config = lib.mkIf config.mynixos.nautilus.enable {

    nixpkgs.overlays = [
      (final: prev: {
        nautilus = prev.nautilus.overrideAttrs (nprev: {
          buildInputs =
            nprev.buildInputs
            ++ (with pkgs.gst_all_1; [
              gst-plugins-base
              gst-plugins-good
              gst-plugins-bad
              gst-plugins-ugly
            ]);
        });
      })
    ];

    environment.systemPackages = with pkgs; [
      nautilus-python
    ];

    programs.nautilus-open-any-terminal = {
      enable = false; # TODO: enable when env var conflict is fixed
      terminal = "ghostty"; # TODO: make dynamic based on terminal enabled
    };

    # Enable trash, recents
    services.gvfs.enable = true;
  };

}
