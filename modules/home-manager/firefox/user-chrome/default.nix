let
  webAppSingleMinimal = ''
    #navigator-toolbox {
      visibility: collapse !important;
      min-height: 0 !important;
    }

    :root:has(#tabbrowser-tabs tab:nth-of-type(2)) #navigator-toolbox {
      visibility: visible !important;
    }
  '';
in
{
  inherit
    webAppSingleMinimal
    ;
}
