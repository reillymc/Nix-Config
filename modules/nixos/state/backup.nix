{
  lib,
  ...
}:
let
  stateLib = import ../../../lib/state.nix { inherit lib; };
in
{
  imports = [
    (stateLib.mkBackup { prefix = "mynixos"; })
  ];
}
