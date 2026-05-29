{
  pkgs,
  ...
}:
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
      "TitleFore" = "#2E3440";
      "TitleBack" = "#ECEFF4";
      "TitleInfo" = "#2E3440";
      "NormalTitle" = "#5E81AC";
      "DimmedTitle" = "#4C566A";
      "SelectedTitle" = "#BF616A";
      "NormalDesc" = "#3B4252";
      "DimmedDesc" = "#434C5E";
      "SelectedDesc" = "#BF616A";
      "StatusMsg" = "#8FBCBB";
      "PinIndicatorColor" = "#D08770";
      "SelectedBorder" = "#88C0D0";
      "SelectedDescBorder" = "#88C0D0";
      "FilteredMatch" = "#A3BE8C";
      "FilterPrompt" = "#D08770";
      "FilterInfo" = "#2E3440";
      "FilterText" = "#3B4252";
      "FilterCursor" = "#BF616A";
      "HelpKey" = "#5E81AC";
      "HelpDesc" = "#2E3440";
      "PageActiveDot" = "#A3BE8C";
      "PageInactiveDot" = "#4C566A";
      "DividerDot" = "#2E3440";
      "PreviewedText" = "#2E3440";
      "PreviewBorder" = "#88C0D0";
    };
  };

  home.packages = with pkgs; [
    wl-clipboard
  ];
}
