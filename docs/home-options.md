# Home Manager Configuration Options

## myhome\.audio\.devices

A list of audio outputs that should be actively used by the system, e\.g\. in audio output cycle script\.
Order determines device priority\. E\.g\. first device will be default if connected, else second and so on\.
The device is listed by the PipeWire node name\. This value can be found using ` wpctl `:

 1. Run ` wpctl status ` and find desired device\. Note the numeric id\.
 2. Run ` wpctl inspect <numberic id> ` and copy the value from the ` node.name ` property



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "bluez_output.00_00_00_00_00_0.1"
  "alsa_output.pci-0000_00_00.1.hdmi-stereo"
]
```

*Declared by:*
 - [modules/home-manager/audio/devices\.nix](../modules/home-manager/audio/devices.nix)



## myhome\.display\.brightness



Configuration for automatically adjusting monitor brightness on schedule\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/display/brightness\.nix](../modules/home-manager/display/brightness.nix)



## myhome\.display\.brightness\.maxTime



Time of day when ‘day’ (max brightness) window starts (HH:MM)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/display/brightness\.nix](../modules/home-manager/display/brightness.nix)



## myhome\.display\.brightness\.minTime



Time of day when ‘night’ (min brightness) window starts (HH:MM)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/display/brightness\.nix](../modules/home-manager/display/brightness.nix)



## myhome\.display\.brightness\.step



Brightness increment applied per adjustment\.



*Type:*
signed integer



*Default:*

```nix
20
```

*Declared by:*
 - [modules/home-manager/display/brightness\.nix](../modules/home-manager/display/brightness.nix)



## myhome\.display\.monitors



A list of display outputs that should be actively used by the system, e\.g\. in hyprland’s configuration\. Each item should provide all the required keys, e\.g\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```



*Example:*

```nix
''
  [
    {
      output = "DP-1";
      model = "eiq-495KCSUW";
      resolution = "5120x1440";
      refreshRate = 144;
      position = "0x0";
      scale = 1.0;
      bitdepth = 10;
    }
  ]
''
```

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.monitors\.\*\.bitdepth



Optional bitdepth, e\.g\. 10\. If null, omitted\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.monitors\.\*\.control



Optional brightness control method for this monitor\.
Use “brightnessctl” for internal laptop panels and “ddcutil” for external DDC/CI monitors\.
If null, internal panels are auto-detected and will use brightnessctl\.



*Type:*
null or one of “ddcutil”, “brightnessctl”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.monitors\.\*\.isUltrawide



Whether the monitor is ultrawide or not\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.monitors\.\*\.model



Monitor model name, e\.g\. eiq-495KCSUW



*Type:*
string

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.monitors\.\*\.output



Output name, e\.g\. DP-1



*Type:*
string

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.monitors\.\*\.position



Monitor position, e\.g\. 0x0



*Type:*
string



*Default:*

```nix
"0x0"
```

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.monitors\.\*\.refreshRate



Refresh rate in Hz



*Type:*
signed integer



*Default:*

```nix
144
```

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.monitors\.\*\.resolution



Resolution, e\.g\. 5120x1440



*Type:*
string



*Default:*

```nix
"5120x1440"
```

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.monitors\.\*\.scale



Scale factor, e\.g\. 1\.0



*Type:*
floating point number



*Default:*

```nix
1.0
```

*Declared by:*
 - [modules/home-manager/display/monitors\.nix](../modules/home-manager/display/monitors.nix)



## myhome\.display\.nightShift



Configuration for automatically adjusting monitor temperature on schedule\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/display/night-shift\.nix](../modules/home-manager/display/night-shift.nix)



## myhome\.display\.nightShift\.clearTime



Time of day when ‘day’ (normal color temperature) starts (HH:MM)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/display/night-shift\.nix](../modules/home-manager/display/night-shift.nix)



## myhome\.display\.nightShift\.shiftTime



Time of day when ‘night’ (night shift temperature) window starts (HH:MM)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/display/night-shift\.nix](../modules/home-manager/display/night-shift.nix)



## myhome\.display\.popupify\.titles



List of window title substrings to always render as popups (floating)



*Type:*
list of string



*Default:*

```nix
[
  "Extension: (Bitwarden Password Manager) - — Mozilla Firefox"
  "Extension: (Bitwarden Password Manager) - Bitwarden — Default — Mozilla Firefox"
  "Pay with PayPal — Default — Mozilla Firefox:"
]
```

*Declared by:*
 - [modules/home-manager/display/layout\.nix](../modules/home-manager/display/layout.nix)



## myhome\.display\.theme



Object containing active theme



*Type:*
attribute set



*Default:*

```nix
{
  color = {
    accentPrimary0 = "#f1aa53";
    accentPrimary1 = "#e8b679";
    accentSecondary0 = "#f1c03b";
    accentSecondary1 = "#edcb51";
    background0 = "#11111b";
    background1 = "#33333b";
    black = "#000000";
    danger = "#f38ba8";
    foreground0 = "#f8f1e5";
    foreground1 = "#e1c1af";
    foreground2 = "#988181";
    success = "#a6e3a1";
    warning = "#f9e2af";
    white = "#ffffff";
  };
  mode = "dark";
  opacity = {
    active = 1.0;
    elementHeavy = 0.6;
    elementLight = 0.4;
    inactive = 0.8;
    overlay = 0.75;
  };
  radii = {
    loose = 16;
    pill = 9999;
    round = 12;
    soft = 8;
    tight = 4;
  };
  size = {
    popup = {
      large = {
        height = 0.75;
        width = 1;
      };
      regular = {
        height = 0.5;
        width = 0.5;
      };
    };
  };
}
```

*Declared by:*
 - [modules/home-manager/display/theme\.nix](../modules/home-manager/display/theme.nix)



## myhome\.healthchecks\.enable



Whether to enable Healthchecks pings for systemd user services\.
Defaults to ` mynixos.healthchecks.enable ` when Home Manager runs as a
NixOS module\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/healthchecks\.nix](../modules/home-manager/healthchecks.nix)



## myhome\.healthchecks\.baseUrl



Base ping URL, without the project ping key or slug\. Endpoints are
derived as ` <baseUrl>/<pingKey>/<slug>[/start|/fail] `\.

Defaults to ` mynixos.healthchecks.baseUrl ` when Home Manager runs as a
NixOS module\.



*Type:*
string



*Example:*

```nix
"https://healthchecks.homelab.reillymc.com/ping"
```

*Declared by:*
 - [modules/home-manager/healthchecks\.nix](../modules/home-manager/healthchecks.nix)



## myhome\.healthchecks\.checks



Systemd user services to hook up to Healthchecks\. Each entry is either
a service name (also used as the slug) or an attribute set accepting
` service `, ` slug `, ` start `, and ` logs `\.



*Type:*
list of (string or (submodule))



*Default:*

```nix
[ ]
```



*Example:*

```nix
[ "restic-backups-daily" ]
```

*Declared by:*
 - [modules/home-manager/healthchecks\.nix](../modules/home-manager/healthchecks.nix)



## myhome\.healthchecks\.pingKeyFile



Runtime path to the age-decrypted project ping key\. The key is read at
ping time and never embedded in the Nix store or unit files\.

Defaults to ` mynixos.healthchecks.pingKeyFile ` when Home Manager runs
as a NixOS module\.



*Type:*
string



*Example:*

```nix
"/run/agenix/healthchecks/ping-key"
```

*Declared by:*
 - [modules/home-manager/healthchecks\.nix](../modules/home-manager/healthchecks.nix)



## myhome\.healthchecks\.slugPrefix



Prefix prepended (with a hyphen) to every slug\. Namespaces checks when
several users share one Healthchecks project, since slugs must be
unique within a project\.



*Type:*
string



*Default:*

```nix
config.home.username
```

*Declared by:*
 - [modules/home-manager/healthchecks\.nix](../modules/home-manager/healthchecks.nix)



## myhome\.notify\.enable



Whether to enable desktop notifications for systemd user services\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/notify\.nix](../modules/home-manager/notify.nix)



## myhome\.notify\.services



Systemd user services to show desktop notifications for\. Each entry is
either a service name (notified on failure) or an attribute set
accepting ` service `, ` failure `, and ` success `\.



*Type:*
list of (string or (submodule))



*Default:*

```nix
[ ]
```



*Example:*

```nix
[ "restic-backups-daily" ]
```

*Declared by:*
 - [modules/home-manager/notify\.nix](../modules/home-manager/notify.nix)



## myhome\.ssh-mist\.enable



Whether to enable SSH agent forwarding + confirmation for the mist\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/development/ssh-mist\.nix](../modules/home-manager/development/ssh-mist.nix)



## myhome\.state\.backup\.enable



Whether to enable restic backups of \`myhome\.state’ entries\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/state/backup\.nix](../modules/home-manager/state/backup.nix)



## myhome\.state\.backup\.settings



Options forwarded verbatim to ` services.restic.backups.daily' (e.g.  `repositoryFile’, ` passwordFile',  `environmentFile’, ` repository',  `passwordCommand’)\. Baked defaults (` initialize',  `pruneOpts’,
` checkOpts',  `timerConfig’, ` exclude') are overridden by keys set here.  `paths’ is derived from \`myhome\.state’ and is always forced\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/state/backup\.nix](../modules/home-manager/state/backup.nix)



## myhome\.state\.directories



Directories (relative to ` home.homeDirectory') to persist via impermanence and back up via  `myhome\.state\.backup’\.

Each entry is either a path string or an attribute set accepting
` directory',  `persist’, and \`backup’\.



*Type:*
list of (string or (submodule))



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/state](../modules/home-manager/state)



## myhome\.state\.files



Files (relative to ` home.homeDirectory') to persist via impermanence and back up via  `myhome\.state\.backup’\.

Each entry is either a path string or an attribute set accepting
` file',  `persist’, and \`backup’\.



*Type:*
list of (string or (submodule))



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/state](../modules/home-manager/state)



## myhome\.state\.persist



Store-level impermanence options forwarded verbatim to
` home.persistence.main' ( `persistentStoragePath’, ` hideMounts',  `allowTrash’, ` enable', ...).  `persistentStoragePath’ defaults to
\`“/persist”'\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/state](../modules/home-manager/state)



## myhome\.unfreePackages



List of predicates to allow unfree packages\.
These will be merged, letting allowUnfreePredicate be defined in a modular way\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/unfree-packages\.nix](../modules/home-manager/unfree-packages.nix)



## myhome\.vscode\.enable



Whether to enable VSCode\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/development/vscode\.nix](../modules/home-manager/development/vscode.nix)



## myhome\.vscode\.configDir



Absolute path to a live checkout of this repo; enables nixd NixOS/Home Manager option evaluation\. Set to null to disable\.



*Type:*
null or string



*Default:*

```nix
"~/Projects/Nix-Config"
```

*Declared by:*
 - [modules/home-manager/development/vscode\.nix](../modules/home-manager/development/vscode.nix)



## myhome\.web-apps\.enable



Whether to enable Firefox-based Web Apps integration\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps



Firefox web apps\. Built-ins are provided as definitions below (overridable); custom apps can be added\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.enable



Whether to enable ‹name› web app\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.addons



AMO addons to install into the app profile\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.addons\.\*\.id



Addon’s real gecko id (AMO API guid)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.addons\.\*\.slug



AMO slug, drives the latest\.xpi install URL\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.grantNotifications



Pre-grant web notifications for the app origin\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.icon



Icon file in icons/ (asserted to exist)\.



*Type:*
string



*Default:*

```nix
"‹name›.svg"
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.name



Desktop entry display name\.



*Type:*
string



*Default:*

```nix
"‹name›"
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.persistWholeProfile



Retain the whole profile dir (saved logins, extension registry, session restore)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.policies



Per-binary policy overrides, merged over the baseline\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.savePasswords



Enable password saving for the app\. Pair with ` persistWholeProfile': Firefox writes its login store ( `logins\.json’) atomically, so saved
logins only survive reboots with whole-profile persistence\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.search



Firefox search config for the profile (force/default/engines); empty disables\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.settings



Extra profile prefs (user\.js), merged over defaults\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.url



App URL\. Also the new-tab URL and default homepage\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.userChrome



Custom userChrome; defaults to webAppSingleMinimal\.



*Type:*
null or strings concatenated with “\\n”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.userscripts



Userscripts to install into the app profile\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.userscripts\.\*\.hosts



Hosts the userscript applies to\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.userscripts\.\*\.name



Name of the userscript\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)



## myhome\.web-apps\.apps\.\<name>\.userscripts\.\*\.script



Userscript source\.



*Type:*
strings concatenated with “\\n”

*Declared by:*
 - [modules/home-manager/firefox/web-apps](../modules/home-manager/firefox/web-apps)


