{
  lib,
  theme ? "dark",
  ...
}:
{
  options.myhome.display.theme = lib.mkOption {
    type = lib.types.attrs;
    default = import ../../theme { mode = theme; };
    description = "Object containing active theme";
  };
}
