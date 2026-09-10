{ lib }:
{
  mkProfileId =
    name:
    let
      hex = builtins.hashString "sha1" name;
      shortHex = builtins.substring 0 8 hex;
      id = lib.fromHexString shortHex;
    in
    id;

  mkUuid =
    addonId:
    let
      hex = builtins.hashString "sha256" addonId;
    in
    lib.concatStringsSep "-" [
      (builtins.substring 0 8 hex)
      (builtins.substring 8 4 hex)
      (builtins.substring 12 4 hex)
      (builtins.substring 16 4 hex)
      (builtins.substring 20 12 hex)
    ];
}
