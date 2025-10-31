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
` [ ] `



*Example:*

```
[
  "bluez_output.00_00_00_00_00_0.1"
  "alsa_output.pci-0000_00_00.1.hdmi-stereo"
]
```

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.monitors



A list of display outputs that should be actively used by the system, e\.g\. in hyprland’s configuration\. Each item should provide all the required keys, e\.g\.



*Type:*
list of (submodule)



*Default:*
` [ ] `



*Example:*

```
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
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.monitors\.\*\.bitdepth



Optional bitdepth, e\.g\. 10\. If null, omitted\.



*Type:*
null or signed integer



*Default:*
` null `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.monitors\.\*\.model



Monitor model name, e\.g\. eiq-495KCSUW



*Type:*
string

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.monitors\.\*\.output



Output name, e\.g\. DP-1



*Type:*
string

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.monitors\.\*\.position



Monitor position, e\.g\. 0x0



*Type:*
string



*Default:*
` "0x0" `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.monitors\.\*\.refreshRate



Refresh rate in Hz



*Type:*
signed integer



*Default:*
` 144 `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.monitors\.\*\.resolution



Resolution, e\.g\. 5120x1440



*Type:*
string



*Default:*
` "5120x1440" `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.monitors\.\*\.scale



Scale factor, e\.g\. 1\.0



*Type:*
floating point number



*Default:*
` 1.0 `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.myUnfreePackages



List of predicates to allow unfree packages\.
These will be merged, letting allowUnfreePredicate be defined in a modular way\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager)



## myhome\.rclone\.filter



rclone filter config\.



*Type:*
string



*Default:*

```
''
  # Exclude everything else
  - *
''
```



*Example:*

```
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
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/utilities/rclone\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/utilities/rclone.nix)



## myhome\.rclone\.remote



rclone remote to back up to\.



*Type:*
string



*Example:*
` "s3-remote:" `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/utilities/rclone\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/utilities/rclone.nix)



## myhome\.vscode\.enable



Whether to enable enables vscode\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/development/vscode\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/development/vscode.nix)



## myhome\.web-apps\.enable



Whether to enable Enable Firefox-based Web Apps integration\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps)



## myhome\.web-apps\.immich\.enable



Whether to enable Immich web app\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/immich\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/immich.nix)



## myhome\.web-apps\.jellyfin\.enable



Whether to enable Jellyfin web app\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/jellyfin\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/jellyfin.nix)



## myhome\.web-apps\.jellyseerr\.enable



Whether to enable Jellyseerr web app\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/jellyseerr\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/jellyseerr.nix)



## myhome\.web-apps\.messenger\.enable



Whether to enable Messenger web app\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/messenger\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/messenger.nix)



## myhome\.web-apps\.navidrome\.enable



Whether to enable Navidrome web app\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/navidrome\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/navidrome.nix)



## myhome\.web-apps\.proton-mail\.enable



Whether to enable Proton Mail web app\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/proton-mail\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/proton-mail.nix)



## myhome\.web-apps\.whatsapp\.enable



Whether to enable WhatsApp web app\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/whatsapp\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/whatsapp.nix)



## myhome\.web-apps\.youtube\.enable



Whether to enable YouTube web app\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/youtube\.nix](file:///nix/store/082vf60ajh89s7467w1n5131sb484qln-source/modules/home-manager/web-apps/apps/youtube.nix)


