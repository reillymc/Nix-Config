{ lib }:

let
  hexByte = n: lib.toUpper (lib.fixedWidthString 2 "0" (lib.toHexString n));

  withAlpha =
    color: opacity:
    let
      alpha = builtins.floor (opacity * 255);
    in
    color + hexByte alpha;

  asPixels = n: lib.toString n + "px";

  toPercentInt = n: builtins.floor (n * 100);

  asPercent = n: lib.toString (toPercentInt n) + "%";

  hexMap = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
    "A" = 10;
    "B" = 11;
    "C" = 12;
    "D" = 13;
    "E" = 14;
    "F" = 15;
  };

  hexByteToInt =
    byte: (hexMap.${builtins.substring 0 1 byte} * 16) + hexMap.${builtins.substring 1 1 byte};

  hexToRgb =
    color:
    let
      hex = lib.removePrefix "#" color;
    in
    {
      r = hexByteToInt (builtins.substring 0 2 hex);
      g = hexByteToInt (builtins.substring 2 2 hex);
      b = hexByteToInt (builtins.substring 4 2 hex);
    };

  asRGB =
    color:
    let
      rgb = hexToRgb color;
    in
    "rgb(${toString rgb.r}, ${toString rgb.g}, ${toString rgb.b})";

  asRGBA =
    color: opacity:
    let
      rgb = hexToRgb color;
    in
    "rgba(${toString rgb.r}, ${toString rgb.g}, ${toString rgb.b}, ${toString opacity})";
in
{
  inherit
    asPercent
    asPixels
    toPercentInt
    withAlpha
    asRGB
    asRGBA
    ;
}
