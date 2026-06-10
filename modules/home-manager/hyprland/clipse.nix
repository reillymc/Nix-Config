{
  pkgs,
  config,
  ...
}:
let
  theme = config.myhome.display.theme;
in
{
  services.clipse = {
    enable = true;
    allowDuplicates = false;
    historySize = 250;
    imageDisplay = {
      scaleX = 9;
      scaleY = 9;
      heightCut = 2;
    };
    keyBindings = {
      "choose" = "enter";
      "clearSelected" = "S";
      "down" = "down";
      "end" = "end";
      "filter" = "/";
      "home" = "home";
      "more" = "?";
      "nextPage" = "right";
      "prevPage" = "left";
      "preview" = " ";
      "quit" = "q";
      "remove" = "x";
      "selectDown" = "ctrl+down";
      "selectSingle" = "s";
      "selectUp" = "ctrl+up";
      "togglePin" = "p";
      "togglePinned" = "tab";
      "up" = "up";
      "yankFilter" = "ctrl+s";
    };
    theme = {
      "useCustomTheme" = true;
      "TitleFore" = theme.color.foreground0;
      "TitleInfo" = theme.color.foreground1;
      "NormalTitle" = theme.color.foreground1;
      "DimmedTitle" = theme.color.foreground2;
      "SelectedTitle" = theme.color.accentPrimary0;
      "NormalDesc" = theme.color.foreground2;
      "DimmedDesc" = theme.color.foreground2;
      "SelectedDesc" = theme.color.accentPrimary1;
      "StatusMsg" = theme.color.accentPrimary0;
      "PinIndicatorColor" = theme.color.accentSecondary0;
      "SelectedBorder" = theme.color.accentPrimary0;
      "SelectedDescBorder" = theme.color.accentPrimary0;
      "FilteredMatch" = theme.color.accentSecondary0;
      "FilterPrompt" = theme.color.accentPrimary0;
      "FilterInfo" = theme.color.foreground1;
      "FilterText" = theme.color.foreground1;
      "FilterCursor" = theme.color.foreground0;
      "HelpKey" = theme.color.accentSecondary0;
      "HelpDesc" = theme.color.foreground1;
      "PageActiveDot" = theme.color.accentPrimary0;
      "PageInactiveDot" = theme.color.foreground2;
      "DividerDot" = theme.color.foreground2;
      "PreviewedText" = theme.color.foreground0;
      "PreviewBorder" = theme.color.foreground1;
    };
  };

  home.packages = with pkgs; [
    wl-clipboard
  ];
}
