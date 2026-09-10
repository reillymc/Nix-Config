# Firefox Web Apps

Each web app is a dedicated wrapped Firefox binary + dedicated profile, launched from its own desktop entry (`-no-remote --profile`). Per app: policies, extensions, userscripts, prefs, userChrome. Impermanence-aware.

## Adding a web app

Create `apps/<id>.nix`:

```nix
{
  name = "YouTube";                                 # default: <id>
  url = "https://www.youtube.com/feed/subscriptions";
  # icon = "youtube.svg";                           # default: icons/<id>.svg, asserted to exist
  addons = [                                        # force-installed from AMO
    { id = "uBlock0@raymondhill.net"; slug = "ublock-origin"; }
  ];
  settings = { };                                   # extra profile prefs (user.js)
  userChrome = '' … '';                             # default: webAppSingleMinimal
  policies = { };                                   # per-binary overrides over policies.nix baseline
  grantNotifications = false;                       # pre-grant notifications for the app origin
  savePasswords = false;                            # set signon.rememberSignons
  persistWholeProfile = false;                      # retain whole profile dir (session restore)
  userscripts = [ { name = "…"; hosts = [ "host.example" ]; script = ''…''; } ];
}
```

Register it in the `apps` registry in `default.nix`, add the icon to `icons/`, enable per host with `myhome.web-apps.apps.<id>.enable = true;`. Only `url` is required; `enable` is the only field hosts should set on a built-in. Overriding other built-in fields is unsupported. Custom apps may be defined inline under `myhome.web-apps.apps.<id>` but still need their icon in `icons/`.

## Generated per app

- Binary: `pkgs.firefox.override` with baseline policies → app `policies` → generated `ExtensionSettings` + `3rdparty` managed storage; `extraPrefsFiles` for autoconfig.
- Profile `programs.firefox.profiles.<id>`: `prefs.webApp` + homepage + `settings` + pinned extension UUIDs; `userChrome`.
- Desktop entry `xdg.desktopEntries.<id>` running the wrapped binary.
- Persistence: selective profiles keep `storage/`, `extensions/`, `cookies.sqlite`, `storage.sqlite`, `content-prefs.sqlite`, `permissions.sqlite`, `logins.db`, `key4.db`, `cert9.db`; `persistWholeProfile` keeps the whole profile dir.

## Extensions

`ExtensionSettings` blocks undeclared addons (`"*".installation_mode = "blocked"`); declared addons are `force_installed` via `https://addons.mozilla.org/firefox/downloads/latest/<slug>/latest.xpi` with `updates_disabled = true`. `id` must be the real gecko id (AMO `guid`). Policies are per wrapped binary; global `programs.firefox.policies` stays default-profile-only. Do not use HM `extensions.settings.<id>.settings` seeding (breaks IndexedDB persistence).

Extension UUIDs are pinned deterministically (`mkUuid`, sha256 of addon id), keeping `storage/default/moz-extension+++<uuid>/` stable across profile regeneration. Selective profiles do not persist `extensions.json` (atomic-written), so addons reinstall each boot; `persistWholeProfile` keeps the registry and session.

New Tab Override is force-installed in every webapp; its managed-storage config points new tabs at the app URL and forces `focus_website = true` (focus the web page, not the address bar). Other extensions can be configured the same way via `3rdparty` iff they read `browser.storage.managed`.

## Userscripts

Deployed via enterprise autoconfig (`extraPrefsFiles` → `mozilla.cfg`): a frame script registered with the message manager observes `document-element-inserted`, host-gates, and injects via page-context `eval`. `mozilla.cfg` and frame script must be ES5; injected code may be modern JS. Progress is logged to the `webapps.log` pref (`webapps.step`, `webapps.bootstrap`).

## Constraints

- Release Firefox accepts only AMO-signed addons.
- `document-element-inserted` must be observed in the content process, never the parent.
- `browser.uiCustomization.state` widget ids are sanitized addon ids: lowercase, `@`/`.` → `_`, plus `-browser-action`. Pre-place them in `unified-extensions-area`.
- Escape JS template literals in `''` strings as `''${…}`;
