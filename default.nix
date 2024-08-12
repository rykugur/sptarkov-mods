let pkgs = import <nixpkgs> { };
in { mods = pkgs.callPackage ./lib/readMods.nix { }; }
