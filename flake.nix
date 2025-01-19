{
  description = "mitadi";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    ema.url = "github:srid/ema";
    ema.flake = false;

    # Pull a few fix on top of HEAD:
    # https://github.com/srid/emanote/compare/master...TristanCacqueray:emanote:my-ema
    emanote.url =
      "github:srid/emanote/a91b917fe706a6be9f69eae33cdcb2ba3c95a1b2";
    emanote.flake = false;

    heist-extra.url = "github:srid/heist-extra";
    heist-extra.flake = false;

    unionmount.url = "github:srid/unionmount";
    unionmount.flake = false;

    commonmark-simple.url = "github:srid/commonmark-simple";
    commonmark-simple.flake = false;

    commonmark-wikilink.url =
      # Pull an older version of wikilink, there is a change in HEAD that causes the og:description
      # to contain trailing garbage, like hashtags or duplicated title.
      "github:srid/commonmark-wikilink/471740e7be526676a5b46d6772587cbacd73f546";
    commonmark-wikilink.flake = false;
  };
  outputs = inputs:
    let
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };

      # Add all the inputs package to the haskell package set of nixpkgs
      extend = hpFinal: hpPrev: {
        heist-extra = hpPrev.callCabal2nix "heist-extra" inputs.heist-extra { };
        unionmount = hpPrev.callCabal2nix "unionmount" inputs.unionmount { };
        commonmark-simple =
          hpPrev.callCabal2nix "commonmark-simple" inputs.commonmark-simple { };
        commonmark-wikilink =
          hpPrev.callCabal2nix "commonmark-wikilink" inputs.commonmark-wikilink
          { };
        ema = hpPrev.callCabal2nix "ema" "${inputs.ema}/ema" { };
        # emanote needs access to the stork command at build time
        emanote = let
          pkg = hpFinal.callCabal2nix "emanote" "${inputs.emanote}/emanote" { };
        in pkgs.haskell.lib.overrideCabal pkg
        (_: { executableSystemDepends = [ pkgs.stork ]; });
      };

      hspkgs = pkgs.haskellPackages.extend extend;

    in {
      # Export the emanote binary
      packages.x86_64-linux.default = hspkgs.emanote;
      # Export a ghc to compile a custom emanote command
      packages.x86_64-linux.ghc = hspkgs.ghcWithPackages (p: [ p.emanote ]);
      # Export the package set extension so that it can be applied to downstream set too.
      extend = extend;
    };
}
