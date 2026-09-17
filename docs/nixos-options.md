# NixOS Configuration Options

## mynixos\.docker\.enable

Whether to enable Docker\.



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
 - [modules/nixos/utilities/docker\.nix](../modules/nixos/utilities/docker.nix)



## mynixos\.gnome\.enable



Whether to enable GNOME Desktop Environment\.



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
 - [modules/nixos/gnome](../modules/nixos/gnome)



## mynixos\.hardware\.logitech\.enable



Whether to enable Logitech device support\.



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
 - [modules/nixos/hardware/logitech](../modules/nixos/hardware/logitech)



## mynixos\.hardware\.logitech\.device\.m720\.enable



Whether to enable Logitech M720 mouse support\.



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
 - [modules/nixos/hardware/logitech/devices/m720\.nix](../modules/nixos/hardware/logitech/devices/m720.nix)



## mynixos\.hardware\.logitech\.device\.mx4\.enable



Whether to enable Logitech MX Master 4 mouse support\.



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
 - [modules/nixos/hardware/logitech/devices/mx4\.nix](../modules/nixos/hardware/logitech/devices/mx4.nix)



## mynixos\.hardware\.logitech\.devices



List of Logitech device configurations as strings (logid\.cfg entries)



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/nixos/hardware/logitech](../modules/nixos/hardware/logitech)



## mynixos\.hyprland\.enable



Whether to enable Hyprland\.



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
 - [modules/nixos/hyprland](../modules/nixos/hyprland)



## mynixos\.ly\.enable



Whether to enable ly display manager\.



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
 - [modules/nixos/services/ly\.nix](../modules/nixos/services/ly.nix)



## mynixos\.nautilus\.enable



Whether to enable Nautilus\.



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
 - [modules/nixos/utilities/nautilus\.nix](../modules/nixos/utilities/nautilus.nix)



## mynixos\.spotify\.enable



Whether to enable Spotify\.



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
 - [modules/nixos/entertainment/spotify\.nix](../modules/nixos/entertainment/spotify.nix)



## mynixos\.spotify\.adblock\.enable



Whether to enable Spotify ad blocking\.



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
 - [modules/nixos/entertainment/spotify\.nix](../modules/nixos/entertainment/spotify.nix)



## mynixos\.steam\.enable



Whether to enable Steam\.



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
 - [modules/nixos/entertainment/steam\.nix](../modules/nixos/entertainment/steam.nix)



## mynixos\.theme\.schedule



Configuration for automatically switching system theme\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/nixos/theme\.nix](../modules/nixos/theme.nix)



## mynixos\.theme\.schedule\.darkTime



Time of day to switch to dark theme (HH:MM)\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/nixos/theme\.nix](../modules/nixos/theme.nix)



## mynixos\.theme\.schedule\.lightTime



Time of day to switch to light theme (HH:MM)\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/nixos/theme\.nix](../modules/nixos/theme.nix)



## mynixos\.unfreePackages



List of unfree package names to allow



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/nixos](../modules/nixos)



## mynixos\.utilities\.iosSideloaderEnv\.enable



Whether to enable usbmuxd and nix-ld for iOS sideloading (the sideloader itself is installed manually)\.



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
 - [modules/nixos/utilities/ios-sideloader-env\.nix](../modules/nixos/utilities/ios-sideloader-env.nix)



## mynixos\.via\.enable



Whether to enable VIA keyboard configurer\.



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
 - [modules/nixos/utilities/via\.nix](../modules/nixos/utilities/via.nix)


