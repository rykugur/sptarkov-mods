{ pkgs, ... }:
let
  modsDir = ../mods;
  readJSONFiles = dir:
    let
      files = builtins.readDir dir;
      isJSON = fileName: pkgs.lib.strings.hasSuffix ".json" fileName;
      readJSON = fileName:
        builtins.fromJSON (builtins.readFile "${dir}/${fileName}");
    in pkgs.lib.filterAttrs (_: name: isJSON name)
    (builtins.mapAttrs (_: name: readJSON name) files);
in readJSONFiles modsDir
