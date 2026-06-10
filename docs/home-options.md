# Home Manager Modules Options

## _module\.args

Additional arguments passed to each module in addition to ones
like ` lib `, ` config `,
and ` pkgs `, ` modulesPath `\.

This option is also available to all submodules\. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules\. The sole exception to
this is the argument ` name ` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute\.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:

 - ` lib `: The nixpkgs library\.

 - ` config `: The results of all options after merging the values from all modules together\.

 - ` options `: The options declared in all modules\.

 - ` specialArgs `: The ` specialArgs ` argument passed to ` evalModules `\.

 - All attributes of ` specialArgs `
   
   Whereas option values can generally depend on other option values
   thanks to laziness, this does not apply to ` imports `, which
   must be computed statically before anything else\.
   
   For this reason, callers of the module system can provide ` specialArgs `
   which are available during import resolution\.
   
   For NixOS, ` specialArgs ` includes
   ` modulesPath `, which allows you to import
   extra modules from the nixpkgs package tree without having to
   somehow make the module aware of the location of the
   ` nixpkgs ` or NixOS directories\.
   
   ```
   { modulesPath, ... }: {
     imports = [
       (modulesPath + "/profiles/minimal.nix")
     ];
   }
   ```

For NixOS, the default value for this option includes at least this argument:

 - ` pkgs `: The nixpkgs package set according to
   the ` nixpkgs.pkgs ` option\.



*Type:*
lazy attribute set of raw value



*Default:*

```nix
{ }
```

*Declared by:*
 - [\<nixpkgs/lib/modules\.nix>](https://github.com/NixOS/nixpkgs/blob//lib/modules.nix)



## myhome\.audio\.devices



A list of audio outputs that should be actively used by the system, e\.g\. in audio output cycle script\.
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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/audio/devices\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/audio/devices.nix)



## myhome\.display\.brightness



Configuration for automatically adjusting monitor brightness on schedule\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/brightness\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/brightness.nix)



## myhome\.display\.brightness\.maxTime



Time of day when ‘day’ (max brightness) window starts (HH:MM)\.



*Type:*
string

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/brightness\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/brightness.nix)



## myhome\.display\.brightness\.minTime



Time of day when ‘night’ (min brightness) window starts (HH:MM)\.



*Type:*
string

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/brightness\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/brightness.nix)



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



## myhome\.display\.monitors\.\*\.bitdepth



Optional bitdepth, e\.g\. 10\. If null, omitted\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



## myhome\.display\.monitors\.\*\.isUltrawide



Whether the monitor is ultrawide or not\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



## myhome\.display\.monitors\.\*\.model



Monitor model name, e\.g\. eiq-495KCSUW



*Type:*
string

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



## myhome\.display\.monitors\.\*\.output



Output name, e\.g\. DP-1



*Type:*
string

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



## myhome\.display\.monitors\.\*\.position



Monitor position, e\.g\. 0x0



*Type:*
string



*Default:*

```nix
"0x0"
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



## myhome\.display\.monitors\.\*\.refreshRate



Refresh rate in Hz



*Type:*
signed integer



*Default:*

```nix
144
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



## myhome\.display\.monitors\.\*\.resolution



Resolution, e\.g\. 5120x1440



*Type:*
string



*Default:*

```nix
"5120x1440"
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



## myhome\.display\.monitors\.\*\.scale



Scale factor, e\.g\. 1\.0



*Type:*
floating point number



*Default:*

```nix
1.0
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/monitors.nix)



## myhome\.display\.nightShift



Configuration for automatically adjusting monitor temperature on schedule\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/night-shift\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/night-shift.nix)



## myhome\.display\.nightShift\.clearTime



Time of day when ‘day’ (normal color temperature) starts (HH:MM)\.



*Type:*
string

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/night-shift\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/night-shift.nix)



## myhome\.display\.nightShift\.shiftTime



Time of day when ‘night’ (night shift temperature) window starts (HH:MM)\.



*Type:*
string

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/night-shift\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/night-shift.nix)



## myhome\.display\.popupify\.titles



List of window title substrings to always render as popups (floating)



*Type:*
list of string



*Default:*

```nix
[
  "Extension: (Bitwarden Password Manager) - — Mozilla Firefox"
]
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/layout\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/layout.nix)



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/theme\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/display/theme.nix)



## myhome\.myUnfreePackages



List of predicates to allow unfree packages\.
These will be merged, letting allowUnfreePredicate be defined in a modular way\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/unfree-packages\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/options/unfree-packages.nix)



## myhome\.rclone\.filter



rclone filter config\.



*Type:*
string



*Default:*

```nix
''
  # Exclude everything else
  - *
''
```



*Example:*

```nix
''
  # Exclude
  - node_modules/
  - logs/
  
  # Include
  + /Documents/**
  + /Pictures/**
  
  # Exclude everything else
  - *
''
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/utilities/rclone\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/utilities/rclone.nix)



## myhome\.rclone\.remote



rclone remote to back up to\.



*Type:*
string



*Example:*

```nix
"s3-remote:"
```

*Declared by:*
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/utilities/rclone\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/utilities/rclone.nix)



## myhome\.vscode\.enable



Whether to enable enables vscode\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/development/vscode\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/development/vscode.nix)



## myhome\.web-apps\.enable



Whether to enable Enable Firefox-based Web Apps integration\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps)



## myhome\.web-apps\.immich\.enable



Whether to enable Immich web app\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/immich\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/immich.nix)



## myhome\.web-apps\.jellyfin\.enable



Whether to enable Jellyfin web app\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/jellyfin\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/jellyfin.nix)



## myhome\.web-apps\.jellyseerr\.enable



Whether to enable Seerr web app\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/seerr\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/seerr.nix)



## myhome\.web-apps\.messenger\.enable



Whether to enable Messenger web app\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/messenger\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/messenger.nix)



## myhome\.web-apps\.navidrome\.enable



Whether to enable Navidrome web app\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/navidrome\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/navidrome.nix)



## myhome\.web-apps\.paperless\.enable



Whether to enable Paperless web app\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/paperless\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/paperless.nix)



## myhome\.web-apps\.proton-mail\.enable



Whether to enable Proton Mail web app\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/proton-mail\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/proton-mail.nix)



## myhome\.web-apps\.whatsapp\.enable



Whether to enable WhatsApp web app\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/whatsapp\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/whatsapp.nix)



## myhome\.web-apps\.youtube\.enable



Whether to enable YouTube web app\.



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
 - [/nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/youtube\.nix](file:///nix/store/4kgh69axccv2lzn3a5dc0np27h91i3kg-source/modules/home-manager/web-apps/apps/youtube.nix)


