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
    from subprocess import call
    import os

    # paths to vscode
    VSCODE = 'code'

    # what names do you want to see in the context menu?
    VSCODENAME = 'Code'

    # always create new window?
    NEWWINDOW = False


    class VSCodeExtension(GObject.GObject, Nautilus.MenuProvider):

        def launch_vscode(self, menu, files, editor):
            safepaths = ""
            args = ""

            for file in files:
                filepath = file.get_location().get_path()
                safepaths += '"' + filepath + '" '

                # If one of the files we are trying to open is a folder
                # create a new instance of vscode
                if os.path.isdir(filepath) and os.path.exists(filepath):
                    args = '--new-window '

            if NEWWINDOW:
                args = '--new-window '

            call(editor + ' ' + args + safepaths + '&', shell=True)

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

    gtk = {
      enable = true;
      gtk3.bookmarks = [
        "file://${config.xdg.userDirs.documents} Documents"
        "file://${config.home.homeDirectory}/Downloads Downloads"
        "file://${config.xdg.userDirs.music} Music"
        "file://${config.xdg.userDirs.pictures} Pictures"
        "file://${config.home.homeDirectory}/Projects Projects"
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
  };
}
