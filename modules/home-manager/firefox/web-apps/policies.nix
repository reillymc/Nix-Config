let
  # Enterprise policies applied to every webapp binary (each webapp launches
  # its own wrapped Firefox, so per-binary policies are per-webapp). Mirrors
  # the privacy/declutter subset of the global `programs.firefox.policies'
  # (which stays default-profile-only); per-app overrides/extensions go in
  # the app module's `app.policies' attrset.
  webAppPolicies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    UserMessaging = {
      ExtensionRecommendations = false;
      UrlbarInterventions = false;
      SkipOnboarding = true;
      MoreFromMozilla = false;
      FirefoxLabs = false;
    };
    FirefoxSuggest = {
      WebSuggestions = false;
      SponsoredSuggestions = false;
      ImproveSuggest = false;
      Locked = true;
    };
    NetworkPrediction = false;
  };
in
{
  inherit webAppPolicies;
}
