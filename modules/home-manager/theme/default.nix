{
  mode ? "dark",
}:
let
  palette = if mode == "light" then import ./colors/light.nix else import ./colors/dark.nix;
in
{
  mode = mode;
  color = import ./colors.nix palette;
  opacity = import ./opacity.nix;
  radii = import ./radii.nix;
  size = import ./size.nix;
}
