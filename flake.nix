{
  description = "SPTarkov Mods Flake";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }: {
    # imports = [ ./lib ];
    #
    # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    #
    # packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

    packages.x86_64-linux = { sptarkov-mods = import ./lib/readMods.nix; };
  };
}
