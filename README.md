# mitadi.nix

Use this project to integrate [emanote][emanote] as a library for your website:

- `nix run .`: execute the emanote command.
- `nix run .#ghc`: execute the Haskell compiler with emanote available as a library.

… or import the flake and use the `extend` value to add the library to your package set:

```nix
{
  inputs = {
    mitadi.url = "github:TristanCacqueray/mitadi.nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs = inputs:
    let
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
      hspkgs = pkgs.haskellPackages.extend inputs.mitadi.extend;

     in {};
}
```

The package contains a few extra fixes, checkout the [flake.nix](./flake.nix) inputs to
see differences.


## Motivation

I made this project because I couldn't get the upstream flake to work as
a Haskell library. The author uses flake-parts and the haskell-flake which are
a bit too abstract and produce weird bugs, see: https://github.com/srid/emanote/discussions/527

Mitadi.nix only uses the features provided by nixpkgs and it should be straighforward to integrate.

[emanote]: https://emanote.srid.ca
