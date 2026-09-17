# NixOS Modules Options

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



## mynixos\.configDir



Path to configuration location\. Used for utility scripts and resources\.



*Type:*
absolute path



*Default:*

```nix
"/etx/nixos"
```

*Declared by:*
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos)



## mynixos\.docker\.enable



Whether to enable enables docker\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/utilities/docker\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/utilities/docker.nix)



## mynixos\.gnome\.enable



Whether to enable enables gnome\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/gnome](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/gnome)



## mynixos\.hardware\.logitech\.enable



Whether to enable Enable Logitech device support\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hardware/logitech](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hardware/logitech)



## mynixos\.hardware\.logitech\.device\.m720\.enable



Whether to enable Enable Logitech M720 mouse support\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hardware/logitech/devices/m720\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hardware/logitech/devices/m720.nix)



## mynixos\.hardware\.logitech\.device\.mx4\.enable



Whether to enable Enable Logitech MX Master 4 mouse support\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hardware/logitech/devices/mx4\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hardware/logitech/devices/mx4.nix)



## mynixos\.hardware\.logitech\.devices



List of Logitech device configurations as strings (logid\.cfg entries)



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hardware/logitech](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hardware/logitech)



## mynixos\.hyprland\.enable



Whether to enable enables hyprland\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hyprland](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/hyprland)



## mynixos\.ly\.enable



Whether to enable Enable ly display manager\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/services/ly\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/services/ly.nix)



## mynixos\.myUnfreePackages



List of unfree package names to allow



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos)



## mynixos\.nautilus\.enable



Whether to enable Enable Nautilus\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/utilities/nautilus\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/utilities/nautilus.nix)



## mynixos\.spotify\.enable



Whether to enable Enable Spotify\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/entertainment/spotify\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/entertainment/spotify.nix)



## mynixos\.spotify\.adblock\.enable



Whether to enable Disable ads\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/entertainment/spotify\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/entertainment/spotify.nix)



## mynixos\.steam\.enable



Whether to enable enables steam\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/entertainment/steam\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/entertainment/steam.nix)



## mynixos\.theme\.schedule



Configuration for automatically switching system theme\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/theme\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/theme.nix)



## mynixos\.theme\.schedule\.darkTime



Time of day to switch to dark theme (HH:MM)\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/theme\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/theme.nix)



## mynixos\.theme\.schedule\.lightTime



Time of day to switch to light theme (HH:MM)\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/theme\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/theme.nix)



## mynixos\.utilities\.iosSideloaderEnv\.enable



Whether to enable Enable usbmuxd service and nix-ld with ios-sideloader dependencies\. Sideloader currently needs to be installed manually…



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/utilities/ios-sideloader-env\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/utilities/ios-sideloader-env.nix)



## mynixos\.via\.enable



Whether to enable enables via\.



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
 - [/nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/utilities/via\.nix](file:///nix/store/0x6r8nlayjdl4xk2xxr10ifbb5qrbvy5-source/modules/nixos/utilities/via.nix)


