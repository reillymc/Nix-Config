# Firefox Web Apps

Each "web app" is a **dedicated wrapped Firefox binary + dedicated profile**, launched from its own desktop entry with `-no-remote --profile`. Per-webapp: policies, extensions, userscripts, prefs, userChrome. Persistence-aware (impermanence).

## Adding a web app

Create `apps/<id>.nix`:

```nix
{ lib, config, pkgs, ... }:
let base = import ../base.nix { inherit lib config pkgs; }; in
base.mkWebAppModule {
  id = "youtube";                                   # also the profile name + autoconfig derivation name
  name = "YouTube";                                 # desktop entry display name
  url = "https://www.youtube.com/feed/subscriptions";
  # icon = "youtube.svg";                           # optional; default "icons/<id>.svg" (asserted to exist)
  addons = [                                        # optional; force-installed from AMO
    { id = "uBlock0@raymondhill.net"; slug = "ublock-origin"; }
    { id = "sponsorBlocker@ajay.app"; slug = "sponsorblock"; }
  ];
  settings = {                                      # optional extra profile prefs (user.js)
    "browser.uiCustomization.state" = { … };        # toolbar layout (see apps/youtube.nix)
  };
  userChrome = '' … '';                             # optional; default = webAppSingleMinimal (collapse until 2nd tab)
  policies = { };                                   # optional per-binary policy overrides (merged over baseline)
  grantNotifications = false;                       # optional: pre-grant web notifications for the app origin
  savePasswords = false;                            # optional: enable password saving for the base domain
  persistWholeProfile = false;                      # optional: retain the whole profile dir (session restore; cf. youtube)
  userscripts = [ { name = "…"; hosts = [ "host.example" ]; script = ''…''; } ];  # optional, see below
}
```

Then `./apps/<id>.nix` must be listed in `default.nix`'s `appModules`, an icon goes into `icons/`, and hosts enable with `myhome.web-apps.<id>.enable = true;`. Persistence is wired automatically in `default.nix`: selective apps keep `storage/`, `extensions/`, `cookies.sqlite`, `storage.sqlite`, `content-prefs.sqlite`, `permissions.sqlite`, `logins.db`, `key4.db`, `cert9.db`; apps with `persistWholeProfile = true` (youtube) retain the entire profile dir — the only way session restore and a stable extensions registry survive reboots (see below).

## What the factory generates

- **Wrapped binary** (`mkWebAppPackage`): `pkgs.firefox.override` merging, in order: baseline policies (`policies.nix`) → app `policies` → generated `ExtensionSettings` + `3rdparty` → plus `extraPrefsFiles` (autoconfig).
- **Profile** `programs.firefox.profiles.<id>`: settings merged `prefs.webApp // { browser.startup.homepage = url; } // settings // UUID-pinning pref`; `userChrome`.
- **Desktop entry** `xdg.desktopEntries.<id>`: execs the wrapped binary.
- **Enable option** `myhome.web-apps.<id>.enable` + icon-existence assertion.
- **Convenience options**: `browser.startup.homepage` defaults to `url`; `grantNotifications` adds `Permissions.Notifications.Allow` with the origin derived from `url`; `savePasswords` sets `signon.rememberSignons`; `persistWholeProfile` opts into full profile-dir persistence. Merged before app-provided `settings`/`policies`, so explicit values win.

## Extension management (policy-based)

`ExtensionSettings` follows the NixOS wiki pattern: `"*".installation_mode = "blocked"` (non-declared addons are uninstalled/blocked) and per declared addon `{ installation_mode = "force_installed"; install_url = "https://addons.mozilla.org/firefox/downloads/latest/<slug>/latest.xpi"; updates_disabled = true; }`.

- Addons are `{ id = "<gecko addon id>"; slug = "<amo slug>"; }` — the id must be the addon's real gecko id (AMO API: `guid`); the slug drives the `latest.xpi` URL. Install-state retention is opt-in: only `persistWholeProfile` profiles (youtube) keep `extensions.json` and skip per-boot re-install (no `onInstalled` pages, offline boots keep working). Selective profiles re-install their addons every boot from AMO (`latest.xpi`, versions float; `updates_disabled` blocks in-browser updates).
- Policy management is **per-binary** — that's why each webapp wraps its own Firefox. Global `programs.firefox.policies` (firefox.nix) stays default-profile-only.
- **Do not** use HM `extensions.settings.<id>.settings` seeding: it force-disables the IndexedDB storage backend → extension data lands on tmpfs and is lost every boot.

## Extension data persistence

`webAppExtensionPrefs` pins `extensions.webextensions.uuids` (deterministic sha256-derived UUIDs via `mkUuid`), keeping `storage/default/moz-extension+++<uuid>/` stable across profile regeneration. That dir is persisted for selective profiles, so extension `storage.local` (uBlock lists, SponsorBlock DB) survives reboots. **Never remove the UUID pref.**

Selective profiles do **not** persist `extensions.json` — it is atomic-written (temp+rename), which neither a symlink nor a bind mount can carry — so their force-installed addons are re-installed each boot (`autoDisableScopes = 14` keeps them enabled). A profile that needs a stable registry and session restore sets `persistWholeProfile = true`; the whole dir persists, so `extensions.json` writes land inside the retained directory.

## New Tab Override

`newtaboverride@agenedia.com` is force-installed in every webapp and configured via the `3rdparty` **managed-storage** policy (`type = custom_url`, `url = <app.url>`) — managed keys override local settings, so new tabs always open the app URL. Declaratively configuring other extensions works the same way **if** the addon reads `browser.storage.managed` (SponsorBlock: no). uBlock is configured this way in `apps/youtube.nix`: `3rdparty.Extensions."uBlock0@raymondhill.net".toOverwrite.filters` (schema: `managed_storage.json` inside the xpi) seeds "My filters" on every launch — idempotent, but reverts hand edits to that pane.

## Userscript injection (no extension)

`userscripts` are deployed via Firefox **enterprise autoconfig**: the nixpkgs wrapper writes `lib/firefox/mozilla.cfg` (shipped `defaults/pref/autoconfig.js` bootstrap, `obscure_value = 0`), and `extraPrefsFiles` contents are appended into it. The generated config is **ES5 only** (the autoconfig JS dialect may reject ES6). `mozilla.cfg` is generated **only for apps that declare `userscripts`**, and its single job is the frame-script bootstrap: registers the embedded frame script with the message manager using a **`data:` URI**. The frame script (content process) observes `document-element-inserted`, host-gates, and injects via `content.wrappedJSObject.eval(code)` — page context, `@grant none` semantics, userscript body unmodified.

Every step is logged to the `webapps.log` pref (append-style history, first entry = running FF version), plus `webapps.step` (last step) and `webapps.bootstrap` (final state).

## Hard constraints (do not fight these)

- **Signing**: release Firefox rejects unsigned extensions in every scope/install path — local xpi wrappers are impossible; only AMO-signed addons.
- **Fission**: `document-element-inserted` must be observed in the content process (frame script), never the parent.
- **ES5** in `mozilla.cfg` + frame script; injected page-context code may be modern JS.
- **`browser.uiCustomization.state` widget ids are sanitized** addon ids: lowercase, `@`/`.` → `_`, plus `-browser-action` (e.g. `ublock0_raymondhill_net-browser-action`). Raw addon-id forms silently fail to match and Firefox auto-pins the widget to the nav-bar. Pre-place ids in `unified-extensions-area` to keep buttons out of the toolbar.
- **Nix**: escape JS template literals in `''` strings as `''${…}`;
