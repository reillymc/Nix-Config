{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ffmpeg-headless
    ffmpegthumbnailer
    gdk-pixbuf
    libheif
    libheif.out
  ];

  environment.pathsToLink = [
    "share/thumbnailers"
  ];
}
