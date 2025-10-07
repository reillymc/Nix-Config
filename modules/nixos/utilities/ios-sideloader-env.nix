{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    mynixos.utilities.iosSideloaderEnv.enable = lib.mkEnableOption "Enable usbmuxd service and nix-ld with ios-sideloader dependencies. Sideloader currently needs to be installed manually.";
  };

  config = lib.mkIf config.mynixos.utilities.iosSideloaderEnv.enable {
    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };

    # Use nix-ld to run https://github.com/Dadoum/Sideloader. TODO: build Sideloader as part of module
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      libimobiledevice
      libplist
      libadwaita
      harfbuzz
    ];
  };
}
