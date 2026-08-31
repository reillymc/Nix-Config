{ lib, ... }:

{
  options.mynixos.microvm.guest.enable = lib.mkEnableOption ''
    microvm guest deployment for this host. Set by microvm-base.nix when the
    host is wrapped in a microvm guest toplevel; lets hosts guard config that
    only applies to regular (bare-metal) deployments, e.g. root filesystem
    placeholders.
  '';
}
