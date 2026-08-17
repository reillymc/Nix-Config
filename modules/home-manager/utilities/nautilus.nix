{
  lib,
  mynixos,
  config,
  ...
}:
let
  openInCodeScript = ''
    # Source: https://github.com/jamescalderon/code-nautilus

    from gi.repository import Nautilus, GObject
    from subprocess import Popen
    import os

    # paths to vscode
    VSCODE = 'code'

    # what names do you want to see in the context menu?
    VSCODENAME = 'Code'

    # always create new window?
    NEWWINDOW = False


    class VSCodeExtension(GObject.GObject, Nautilus.MenuProvider):

        def launch_vscode(self, menu, files, editor):
            args = [editor]

            for file in files:
                filepath = file.get_location().get_path()

                # If one of the files we are trying to open is a folder
                # create a new instance of vscode
                if os.path.isdir(filepath) and os.path.exists(filepath):
                    args.append('--new-window')
                    break

            if NEWWINDOW:
                args.append('--new-window')

            args.extend(file.get_location().get_path() for file in files)

            Popen(args)

        def get_file_items(self, *args):
            files = args[-1]

            item_code = Nautilus.MenuItem(
                name='VSCodeOpen',
                label='Open in ' + VSCODENAME,
                tip='Opens the selected files with ' + VSCODENAME
            )
            item_code.connect('activate', self.launch_vscode, files, VSCODE)

            return [item_code]

        def get_background_items(self, *args):
            file_ = args[-1]

            item_code = Nautilus.MenuItem(
                name='VSCodeOpenBackground',
                label='Open in ' + VSCODENAME,
                tip='Opens the current directory in ' + VSCODENAME
            )
            item_code.connect('activate', self.launch_vscode, [file_], VSCODE)

            return [item_code]
  '';

  setWallpaperScript = ''
    from gi.repository import Nautilus, GObject
    from subprocess import call
    import os
    import shutil

    WALLPAPER_DIR = os.path.expanduser('~/.local/share')

    class SetWallpaperExtension(GObject.GObject, Nautilus.MenuProvider):

        def set_wallpaper(self, menu, files, variant):
            src = files[0].get_location().get_path()
            dst = os.path.join(WALLPAPER_DIR, variant)
            shutil.copy2(src, dst)
            call(['systemctl', '--user', 'restart', 'hyprpaper'])

        def get_file_items(self, *args):
            files = args[-1]

            images = [
                f for f in files
                if f.get_mime_type() and f.get_mime_type().startswith('image/')
            ]
            if not images:
                return []

            item_wallpaper = Nautilus.MenuItem(
                name='SetWallpaper',
                label='Set as Wallpaper',
                tip='Sets the selected image as the Hyprland wallpaper'
            )

            menu = Nautilus.Menu()
            item_light = Nautilus.MenuItem(
                name='SetWallpaperLight',
                label='Light',
                tip='Set as the light theme wallpaper'
            )
            item_light.connect('activate', self.set_wallpaper, images, 'wallpaper')
            menu.append_item(item_light)

            item_dark = Nautilus.MenuItem(
                name='SetWallpaperDark',
                label='Dark',
                tip='Set as the dark theme wallpaper'
            )
            item_dark.connect('activate', self.set_wallpaper, images, 'wallpaper-dark')
            menu.append_item(item_dark)

            item_wallpaper.set_submenu(menu)
            return [item_wallpaper]
  '';
in
{
  config = lib.mkIf mynixos.nautilus.enable {
    home.sessionVariables = {
      NAUTILUS_EXTENSION_DIR = "${config.home.homeDirectory}/.local/share/nautilus-python";
    };

    home.file.".local/share/nautilus-python/extensions/code-nautilus.py" = {
      text = openInCodeScript;
      executable = true;
    };

    home.file.".local/share/nautilus-python/extensions/set-wallpaper-nautilus.py" = {
      text = setWallpaperScript;
      executable = true;
    };

    gtk = {
      enable = true;
      gtk3.bookmarks = [
        "file://${config.xdg.userDirs.documents} Documents"
        "file://${config.xdg.userDirs.download} Downloads"
        "file://${config.xdg.userDirs.music} Music"
        "file://${config.xdg.userDirs.pictures} Pictures"
        "file://${config.xdg.userDirs.projects} Projects"
        "file://${config.home.homeDirectory}/Resources Resources"
        "file://${config.xdg.userDirs.videos} Videos"
      ];
    };

    home.file = {
      "Templates/Text File.txt".text = "";
      "Templates/Shell Script.sh".text = "";
      "Templates/Writer Document.odt".source = ../../../resources/templates/WriterDocument.odt;
      "Templates/Calc Spreadsheet.odt".source = ../../../resources/templates/CalcSpreadsheet.ods;
    };

    home.file."Resources/.directory".text = ''
      [Desktop Entry]
      Type=Directory
      Icon=${mynixos.configDir}/resources/icons/folders/folder-shoe-box.svg
    '';
    home.file."Games/.directory".text = ''
      [Desktop Entry]
      Type=Directory
      Icon=${mynixos.configDir}/resources/icons/folders/folder-input-gaming.svg
    '';
  };
}
