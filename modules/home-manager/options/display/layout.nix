{ lib, ... }:

{
  options.myhome.display.popupify.titles = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "List of window title substrings to always render as popups (floating)";
    default = [
      "Extension: (Bitwarden Password Manager) - — Mozilla Firefox"
      "Extension: (Bitwarden Password Manager) - Bitwarden — Default — Mozilla Firefox"
    ];
  };
}
