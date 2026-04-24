{ lib, ... }:

{
  options = {
    myhome = {
      myUnfreePackages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          List of predicates to allow unfree packages.
          These will be merged, letting allowUnfreePredicate be defined in a modular way.
        '';
      };
    };
  };

}
