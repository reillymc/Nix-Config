{
  lib,
  theme,
  ...
}:
{
  options.myhome.display.theme = lib.mkOption {
    type = lib.types.attrs;
    default = import ../../theme { mode = theme; };
  };
}
